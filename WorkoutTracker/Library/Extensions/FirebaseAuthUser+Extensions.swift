//  swiftlint:disable:this file_name
//  FirebaseAuthUser+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FirebaseAuth

extension FirebaseAuth.User {
    func toAppUser() -> AppUser {
        AppUser(
            id: uid,
            displayName: displayName ?? email ?? uid,
            email: email ?? "",
            imageUrl: photoURL
        )
    }
}
