import SwiftUI

struct ContentView: View {
    @StateObject private var staffManager = StaffManager()
    @State private var loggedInUser: Staff? = nil
    @State private var isAdmin = false

    var body: some View {
        NavigationView {
            if let user = loggedInUser {
                if isAdmin {
                    AdminView(staffManager: staffManager, loggedInUser: user)
                        .navigationTitle("Admin Dashboard")
                        .navigationBarItems(trailing:
                            Button("Logout") {
                                logout()
                            }
                        )
                } else {
                    StaffView(loggedInUser: user, staffManager: staffManager)
                        .navigationTitle("Staff Dashboard")
                        .navigationBarItems(trailing:
                            Button("Logout") {
                                logout()
                            }
                        )
                }
            } else {
                LoginView(staffManager: staffManager, loggedInUser: $loggedInUser, isAdmin: $isAdmin)
                    .navigationTitle("Login")
            }
        }
    }

    private func logout() {
        loggedInUser = nil
        isAdmin = false // Reset the admin state on logout
    }
}
