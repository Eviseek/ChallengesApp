//
//  NetworkMonitorService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import Foundation
import Network

protocol NetworkMonitorService {
    var isConnected: Bool { get }
}

@Observable
final class NetworkMonitorServiceImpl: NetworkMonitorService {

    private var pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    // Assume offline until NWPathMonitor confirms a satisfied path, so an offline cold
    // launch surfaces the friendly `.offline` error rather than a generic `.fetchFailed`.
    var isConnected: Bool = false

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isConnected = path.status == .satisfied
            }
        }

        pathMonitor.start(queue: monitorQueue)
    }
}
