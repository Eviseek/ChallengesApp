//  
//  DataCacheModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 04.03.2026.
//

nonisolated struct DataCacheModel: Equatable, Sendable {
    var currentUser: AppUser
    var exercises: [Exercise]
    var exercisesLoaded: Bool = false
    var workouts: [Workout]
    var currentWorkout: Workout?
    var challenges: [Challenge]

    init(
        currentUser: AppUser,
        exercises: [Exercise] = [],
        exercisesLoaded: Bool = false,
        workouts: [Workout] = [],
        currentWorkout: Workout? = nil,
        challenges: [Challenge] = []
    ) {
        self.currentUser = currentUser
        self.exercises = exercises
        self.exercisesLoaded = exercisesLoaded
        self.workouts = workouts
        self.currentWorkout = currentWorkout
        self.challenges = challenges
    }
}
