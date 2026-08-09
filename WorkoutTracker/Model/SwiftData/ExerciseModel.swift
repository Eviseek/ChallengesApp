//
//  ExerciseModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 19.05.2026.
//

import SwiftData
import SwiftUI
import UIKit

@Model
class ExerciseModel {
    @Attribute(.unique)
    var id: String

    var name: LocalizedString
    var muscleGroup: MuscleGroup
    var type: ExerciseType
    var desc: LocalizedString?

    init(id: String, name: LocalizedString, muscleGroup: MuscleGroup, type: ExerciseType, desc: LocalizedString? = nil) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.type = type
        self.desc = desc
    }
}
