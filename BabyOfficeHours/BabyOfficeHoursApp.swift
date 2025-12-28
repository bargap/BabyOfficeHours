import SwiftUI
import BabyOfficeHoursFeature
import FirebaseCore

@main
struct BabyOfficeHoursApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
