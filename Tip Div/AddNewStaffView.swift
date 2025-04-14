import SwiftUI

struct AddNewStaffView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var role: StaffRole = .waiter
    @State private var showSuccessMessage = false
    var loggedInUser: Staff
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Picker("Role", selection: $role) {
                    ForEach(StaffRole.allCases, id: \.self) { role in
                        if role != .owner || loggedInUser.role == .owner {
                            Text(role.rawValue).tag(role)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button("Add Staff") {
                    staffManager.addStaff(name: name, username: username, password: password, role: role)
                    showSuccessMessage = true
                    clearForm()
                }
                .padding()
            }
            .navigationTitle("Add Staff")
            
            if showSuccessMessage {
                Text("Staff added successfully!")
                    .foregroundColor(.green)
                    .padding()
            }
            
            List {
                ForEach(staffManager.staffList) { staff in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(staff.name)
                            Text(staff.role.rawValue).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                        if staff.username != "admin" && staff.username != "owner" { // Prevent deleting admin and owner
                            Button(action: {
                                deleteStaff(staff: staff)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteStaff(staff: Staff) {
        staffManager.deleteStaff(staff)
    }
    
    private func clearForm() {
        name = ""
        username = ""
        password = ""
        role = .waiter
    }
}
