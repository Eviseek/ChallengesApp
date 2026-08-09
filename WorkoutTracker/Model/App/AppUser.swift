//
//  AppUser.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

nonisolated struct AppUser: Equatable, Codable {
    let id: String
    let displayName: String
    let email: String
    let imageUrl: URL?
}
