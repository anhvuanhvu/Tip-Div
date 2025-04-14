import SwiftUI

struct LoginView: View {
    @ObservedObject var staffManager: StaffManager
    @Binding var loggedInUser: Staff?
    @Binding var isAdmin: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
            
            Button("Login") {
                if let user = staffManager.staffList.first(where: { $0.username == username && $0.password == password }) {
                    loggedInUser = user
                    isAdmin = user.role == .manager || user.role == .owner
                } else {
                    showError = true
                }
            }
            .padding()

            if showError {
                Text("Invalid credentials")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}
