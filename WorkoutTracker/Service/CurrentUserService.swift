//
//  CurrentUserService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.06.2026.
//

import FuturedArchitecture

protocol CurrentUserService {
    var currentUser: AppUser { get }
}

final class CurrentUserServiceImpl: CurrentUserService {

    // MARK: - Public Properties

    var currentUser: AppUser {
        dataCache.value.currentUser
    }

    // MARK: - Private Properties

    private let dataCache: DataCache<DataCacheModel>

    // MARK: - Init

    init(dataCache: DataCache<DataCacheModel>) {
        self.dataCache = dataCache
    }
}
