import SwiftUI

/// Root view that switches between onboarding and main content
public struct ContentView: View {
    @State private var appState = AppState()

    public var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                BabyListView()
            } else {
                OnboardingView()
            }
        }
        .environment(appState)
    }

    public init() {}
}
