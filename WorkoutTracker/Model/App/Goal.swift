//
//  Goal.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

nonisolated struct Goal: Equatable {
    nonisolated enum GoalType: Equatable {
        case totalVolume(unit: WeightUnit)
        case totalDuration              // always seconds
        case workoutCount              // always count
    }

    nonisolated enum WeightUnit: Equatable {
        case kg, lbs // swiftlint:disable:this identifier_name
    }

    let type: GoalType
    let exercises: [Exercise]
}

extension Goal {
    init(from db: GoalDB, exercises: [Exercise]) { // swiftlint:disable:this identifier_name
        let type: GoalType = switch db.type {
        case .totalVolume:
                .totalVolume(unit: db.unit == .lbs ? .lbs : .kg)
        case .totalDuration:
                .totalDuration
        case .workoutCount:
                .workoutCount
        }
        self.init(type: type, exercises: exercises.filter { db.exerciseIds.contains($0.id) })
    }
}

// MARK: Goal description to be shown in UI

extension Goal {
    var description: String {
        let typeString: String = switch type {
        case .totalVolume(let unit):
            LocalizedText.totalVolume(unit: unit.displayName)
        case .totalDuration:
            String(localized: "Total duration")
        case .workoutCount:
            String(localized: "Workout count")
        }

        let exerciseString = exercises.map(\.localizedName).formatted(.list(type: .and))

        return exercises.isEmpty
            ? typeString
            : LocalizedText.goalDescription(type: typeString, exercises: exerciseString)
    }
}

extension Goal.WeightUnit {
    var displayName: String {
        switch self {
        case .kg:
            String(localized: "kg")
        case .lbs:
            String(localized: "lb")
        }
    }
}

extension Goal.GoalType {
    func formattedParticipantValue(_ value: Double) -> String {
        switch self {
        case .totalVolume(let unit):
            LocalizedText.weight(value: Int(value), unit: unit.displayName)
        case .totalDuration:
            LocalizedText.minutes(Int(value) / 60)   // value is in seconds
        case .workoutCount:
            LocalizedText.workouts(Int(value))
        }
    }
}
