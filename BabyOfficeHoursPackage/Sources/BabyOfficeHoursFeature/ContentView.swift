import SwiftUI

/// Root view that switches between onboarding and main content
public struct ContentView: View {
    @State private var appState = AppState()

    public var body: some View {
        Group {
            if appState.isLoading {
                // Loading state while connecting to Firebase
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Connecting...")
                        .foregroundStyle(.secondary)
                }
            } else if appState.hasCompletedOnboarding {
                BabyListView()
            } else {
                OnboardingView()
            }
        }
        .environment(appState)
        .task {
            await appState.initialize()
        }
    }

    public init() {}
}
