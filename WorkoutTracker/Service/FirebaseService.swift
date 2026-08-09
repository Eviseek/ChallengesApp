//
//  FirebaseService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import Firebase
import FirebaseFirestore
import OSLog

protocol FirebaseService {
    func configure()
    func fetchAllExercises() async throws(AppError) -> [Exercise]
    func fetchWorkouts(with exercises: [Exercise], userId: String) async throws(AppError) -> [Workout]
    func saveWorkout(_ workout: Workout, userId: String) async throws(AppError)
    func removeWorkout(_ workout: Workout, userId: String) async throws(AppError)
    func saveUserToDb(_ user: AppUser) async throws(AppError)
    func fetchChallenges(with exercises: [Exercise]) async throws(AppError) -> [Challenge]
    func fetchParticipants(for challenge: Challenge, currentUserId: String) async throws(AppError) -> [Participant]
    func saveContributions(_ contributions: [Contribution], for challenge: Challenge, userId: String, displayName: String) async throws(AppError)
    func userExists(withId id: String) async throws(AppError) -> Bool
}

// Firestore collection and field names, centralized so a typo can't fail silently.
private enum Collections {
    static let exercises = "exercises"
    static let workouts = "workouts"
    static let challenges = "challenges"
    static let participants = "participants"
    static let users = "users"

    // Field names must match the `ParticipantDB` coding keys.
    enum Field {
        static let userId = "userId"
        static let value = "value"
        static let displayName = "displayName"
        static let challengeId = "challengeId"
        static let contributions = "contributions"
    }
}

final class ProductionFirebaseService: FirebaseService {

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "FirebaseService")
    private let networkService: NetworkMonitorService
    private var database: Firestore?

    // MARK: - Public Methods

    init(networkService: NetworkMonitorService) {
        self.networkService = networkService
    }

    func configure() {
        FirebaseApp.configure()
        database = Firestore.firestore()
    }

    func fetchAllExercises() async throws(AppError) -> [Exercise] {
        try await perform(onError: .fetchFailed) { database in
            let snapshot = try await database.collection(Collections.exercises).getDocuments()
            let fetched = try snapshot.documents.map { try $0.data(as: ExerciseDB.self) }
            return fetched.compactMap {
                guard let id = $0.id else {
                    assertionFailure("Fetched exercise without ID.")
                    return nil
                }
                return Exercise(id: id, name: $0.name.localizedString, muscleGroup: $0.muscleGroup, type: $0.type, description: $0.description?.localizedString)
            }
        }
    }

    func fetchWorkouts(with exercises: [Exercise], userId: String) async throws(AppError) -> [Workout] {
        try await perform(onError: .fetchFailed) { database in
            let snapshot = try await database.collection(Collections.workouts).whereField(Collections.Field.userId, isEqualTo: userId).getDocuments()
            let fetched = try snapshot.documents.map { try $0.data(as: WorkoutDB.self) }

            let exerciseLookup = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

            return fetched.compactMap { workoutDB in
                let sets = workoutDB.exerciseSets.compactMap { setDB -> ExerciseSet? in
                    guard let exercise = exerciseLookup[setDB.exerciseId] else {
                        return nil
                    }
                    return setDB.asExerciseSet(exercise: exercise)
                }
                return Workout(id: workoutDB.id, name: workoutDB.name, date: workoutDB.date, state: workoutDB.state ?? .running, duration: workoutDB.duration, exerciseSets: sets)
            }
        }
    }

    func fetchChallenges(with exercises: [Exercise]) async throws(AppError) -> [Challenge] {
        try await perform(onError: .fetchFailed) { database in
            let snapshot = try await database.collection(Collections.challenges).getDocuments()
            let fetched = try snapshot.documents.map { try $0.data(as: ChallengeDB.self) }
            return fetched.compactMap { Challenge(from: $0, exercises: exercises) }
        }
    }

    func fetchParticipants(for challenge: Challenge, currentUserId: String) async throws(AppError) -> [Participant] {
        try await perform(onError: .fetchFailed) { database in
            let snapshot = try await database.collection(Collections.challenges).document(challenge.id).collection(Collections.participants).order(by: Collections.Field.value, descending: true).getDocuments()
            let fetched = try snapshot.documents.map { try $0.data(as: ParticipantDB.self) }
            return fetched.compactMap { Participant(from: $0, currentUserId: currentUserId) }
        }
    }

    // Merge contributions atomically: each new entry is written under its own composite
    // key (so unrelated entries are never touched) and the running total is bumped with a
    // server-side `FieldValue.increment`. Because both the per-key writes and the increment
    // are applied atomically on the server, two devices writing concurrently can't clobber
    // each other's contributions the way a read-merge-write of the whole document could.
    // `merge: true` also creates the participant document on first save.
    func saveContributions(_ contributions: [Contribution], for challenge: Challenge, userId: String, displayName: String) async throws(AppError) {
        try await perform(onError: .saveFailed) { database in
            let participantRef = database.collection(Collections.challenges).document(challenge.id).collection(Collections.participants).document(userId)

            var contributionsMap: [String: Any] = [:]
            for contribution in contributions {
                contributionsMap[contribution.id] = try Firestore.Encoder().encode(ContributionDB(from: contribution))
            }
            let delta = contributions.map(\.contribution).reduce(0, +)

            let data: [String: Any] = [
                Collections.Field.displayName: displayName,
                Collections.Field.challengeId: challenge.id,
                Collections.Field.value: FieldValue.increment(delta),
                Collections.Field.contributions: contributionsMap
            ]
            try await participantRef.setData(data, merge: true)
        }
    }

    func saveWorkout(_ workout: Workout, userId: String) async throws(AppError) {
        try await perform(onError: .saveFailed) { database in
            let workoutDB = workout.workoutDB(userId: userId)
            let encoded = try Firestore.Encoder().encode(workoutDB)
            try await database.collection(Collections.workouts).document(workout.id).setData(encoded)
        }
    }

    func removeWorkout(_ workout: Workout, userId: String) async throws(AppError) {
        try await perform(onError: .deleteFailed) { database in
            try await database.collection(Collections.workouts).document(workout.id).delete()
        }
    }

    func saveUserToDb(_ user: AppUser) async throws(AppError) {
        try await perform(onError: .saveFailed) { database in
            let encoded = try Firestore.Encoder().encode(user)
            try await database.collection(Collections.users).document(user.id).setData(encoded)
        }
    }

    func userExists(withId id: String) async throws(AppError) -> Bool {
        try await perform(onError: .fetchFailed) { database in
            try await database.collection(Collections.users).document(id).getDocument().exists
        }
    }

    // MARK: - Private Methods

    // Shared boilerplate for every endpoint: enforce connectivity, require a configured
    // database, and map any thrown error to a typed AppError after logging it.
    private func perform<T>(
        onError: AppError,
        function: String = #function,
        _ work: (Firestore) async throws -> T
    ) async throws(AppError) -> T {
        guard networkService.isConnected else { throw AppError.offline }
        guard let database else { fatalError("Database not configured") }
        do {
            return try await work(database)
        } catch {
            logger.error("\(function) failed: \(error)")
            throw onError
        }
    }
}
