//
//  StateView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import SwiftUI

struct StateView<Empty: View, Content: View>: View {
    let state: StateViewState
    let retryAction: () -> Void
    let emptyStateView: () -> Empty
    let content: () -> Content

    init(
        state: StateViewState,
        retryAction: @escaping () -> Void,
        @ViewBuilder emptyStateView: @escaping () -> Empty,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.state = state
        self.retryAction = retryAction
        self.emptyStateView = emptyStateView
        self.content = content
    }

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
            case .error(let error):
                FullscreenErrorView(
                    icon: error == .offline ? "wifi.slash" : "exclamationmark.triangle",
                    title: error.title,
                    description: error.message,
                    action: retryAction
                )
            case .empty:
                emptyStateView()
            case .content:
                content()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG
#Preview("Loading") {
    StateView(
        state: .loading,
        retryAction: {},
        emptyStateView: { EmptyView() },
        content: { Text("Content") }
    )
}

#Preview("Offline") {
    StateView(
        state: .error(.offline),
        retryAction: {},
        emptyStateView: { EmptyView() },
        content: { Text("Content") }
    )
}

#Preview("Error") {
    StateView(
        state: .error(.fetchFailed),
        retryAction: {},
        emptyStateView: { EmptyView() },
        content: { Text("Content") }
    )
}

#Preview("Empty") {
    StateView(
        state: .empty,
        retryAction: {},
        emptyStateView: { Text("Nothing here yet") },
        content: { Text("Content") }
    )
}
#endif
