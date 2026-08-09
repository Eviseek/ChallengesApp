//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 20.02.2026.
//

import Foundation

nonisolated struct Workout: Equatable, Hashable, Codable {
    var id: String = UUID().uuidString
    var name: String = String(localized: .myAmazingWorkout)
    var date: Date = Date()
    var state: WorkoutState = .running
    var duration: Int = 0       // seconds
    var exerciseSets: [ExerciseSet] = []
}

enum WorkoutState: String, Codable {
    case running
    case paused

    var statusText: String {
        switch self {
        case .running:
            String(localized: "In progress")
        case .paused:
            String(localized: "Paused")
        }
    }
}

extension Workout {
    func workoutDB(userId: String) -> WorkoutDB {
        WorkoutDB(
            id: id,
            userId: userId,
            name: name,
            date: date,
            state: state,
            duration: duration,
            exerciseSets: exerciseSets.asExerciseSetDBArray
        )
    }
}

extension Workout {
    var summary: WorkoutSummary {
        // Group sets by exercise ID for fast count lookup.
        // Dictionary iteration order is not guaranteed, so this is used only as a lookup table.
        let grouped = Dictionary(grouping: exerciseSets) { $0.exercise.id }

        // Walk exerciseSets in insertion order to get a stable, deduplicated list of exercise IDs.
        // Set.insert returns (inserted: Bool), so filtering by .inserted keeps only the first occurrence.
        var seen = Set<String>()
        let orderedExerciseIds = exerciseSets.map { $0.exercise.id }.filter { seen.insert($0).inserted }

        // For each exercise ID, look up all its sets in `grouped` to get the name and total set count.
        // The exercise object is read from the first set — all sets share the same exercise, so any will do.
        let exerciseSummaries = orderedExerciseIds.compactMap { id -> ExerciseSetSummary? in
            guard let exercise = grouped[id]?.first?.exercise else { return nil }
            return ExerciseSetSummary(exerciseName: exercise.localizedName, totalSets: grouped[id]?.count ?? 0)
        }
        return WorkoutSummary(
            workoutName: name,
            formattedDate: date.workoutDisplayFormat,
            exerciseSummaries: exerciseSummaries
        )
    }
}

// MARK: - Accessibility

extension WorkoutState {
    var displayText: String {
        switch self {
        case .running:
            String(localized: "In progress")
        case .paused:
            String(localized: "Paused")
        }
    }
}

extension Workout {
    var accessibilityLabel: String {
        LocalizedText.nameStatusDuration(name: name, status: state.displayText, duration: duration.asTimeString())
    }
}

// MARK: - Collection Stats

extension [Workout] {
    var totalDuration: Int {
        reduce(0) { $0 + $1.duration }
    }

    var uniqueExerciseCount: Int {
        Set(flatMap { $0.exerciseSets.map(\.exercise.id) }).count
    }

    var heaviestLift: Double? {
        flatMap(\.exerciseSets).compactMap(\.weight).max()
    }
}

// MARK: - Mutations

extension Workout {
    mutating func updateName(_ name: String) {
        self.name = name
    }

    @discardableResult
    mutating func addSet(for exercise: Exercise) -> UUID {
        let newSet = ExerciseSet(exercise: exercise)
        exerciseSets.append(newSet)
        return newSet.id
    }

    mutating func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?) {
        guard let index = flatIndex(for: exercise, at: setIndex) else {
            assertionFailure("Invalid setIndex \(setIndex) for exercise \(exercise)")
            return
        }
        exerciseSets[index].reps = reps
        exerciseSets[index].weight = weight
    }

    mutating func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?) {
        guard let index = flatIndex(for: exercise, at: setIndex) else {
            assertionFailure("Invalid setIndex \(setIndex) for exercise \(exercise)")
            return
        }
        exerciseSets[index].duration = duration
    }

    mutating func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?) {
        guard let index = flatIndex(for: exercise, at: setIndex) else {
            assertionFailure("Invalid setIndex \(setIndex) for exercise \(exercise)")
            return
        }
        exerciseSets[index].notes = notes
    }

    mutating func deleteSet(for exercise: Exercise, at setIndex: Int) {
        guard let index = flatIndex(for: exercise, at: setIndex) else {
            assertionFailure("Invalid setIndex \(setIndex) for exercise \(exercise)")
            return
        }
        exerciseSets.remove(at: index)
    }

    mutating func removeExercise(_ exercise: Exercise) {
        exerciseSets.removeAll { $0.exercise == exercise }
    }

    private func flatIndex(for exercise: Exercise, at setIndex: Int) -> Int? {
        let matchingIndices = exerciseSets.indices.filter { exerciseSets[$0].exercise == exercise }
        guard setIndex < matchingIndices.count else { return nil }
        return matchingIndices[setIndex]
    }
}

// MARK: Mock Data

#if DEBUG
extension Workout {
    static let mockData: [Workout] = [

        // Push Day
        Workout(
            name: "Push Day",
            date: Date().addingTimeInterval(-60 * 60 * 24 * 2),
            duration: 3_600,
            exerciseSets: [
                ExerciseSet(exercise: .benchPress, reps: 8, weight: 80, duration: nil, notes: "Felt strong"),
                ExerciseSet(exercise: .benchPress, reps: 6, weight: 85, duration: nil, notes: nil),
                ExerciseSet(exercise: .benchPress, reps: 5, weight: 87.5, duration: nil, notes: "PR attempt"),
                ExerciseSet(exercise: .inclinePress, reps: 10, weight: 60, duration: nil, notes: nil),
                ExerciseSet(exercise: .overheadPress, reps: 8, weight: 50, duration: nil, notes: nil)
            ]
        ),

        // Pull Day
        Workout(
            name: "Pull Day",
            date: Date().addingTimeInterval(-60 * 60 * 24 * 1),
            duration: 3_600,
            exerciseSets: [
                ExerciseSet(exercise: .deadlift, reps: 5, weight: 120, duration: nil, notes: "New PR"),
                ExerciseSet(exercise: .deadlift, reps: 5, weight: 120, duration: nil, notes: nil),
                ExerciseSet(exercise: .pullUp, reps: 10, weight: nil, duration: nil, notes: "Bodyweight"),
                ExerciseSet(exercise: .pullUp, reps: 8, weight: nil, duration: nil, notes: nil),
                ExerciseSet(exercise: .bicepCurl, reps: 12, weight: 15, duration: nil, notes: nil)
            ]
        ),

        // Legs & Core
        Workout(
            name: "Legs & Core",
            date: Date(),
            duration: 3_600,
            exerciseSets: [
                ExerciseSet(exercise: .squat, reps: 8, weight: 100, duration: nil, notes: nil),
                ExerciseSet(exercise: .squat, reps: 6, weight: 105, duration: nil, notes: nil),
                ExerciseSet(exercise: .legPress, reps: 12, weight: 150, duration: nil, notes: nil),
                ExerciseSet(exercise: .plank, reps: nil, weight: nil, duration: 60, notes: "60 sec hold"),
                ExerciseSet(exercise: .plank, reps: nil, weight: nil, duration: 45, notes: "Struggled")
            ]
        ),

        // Cardio
        Workout(
            name: "Cardio Session",
            date: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            duration: 3_600,
            exerciseSets: [
                ExerciseSet(exercise: .treadmill, reps: nil, weight: nil, duration: 1_200, notes: "5km"),
                ExerciseSet(exercise: .treadmill, reps: nil, weight: nil, duration: 1_200, notes: "Cool down")
            ]
        )
    ]
}
#endif
