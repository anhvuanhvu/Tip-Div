import SwiftUI

struct AdminView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var showCalculateTip = false
    @State private var showAddNewStaff = false
    @State private var showEditTipHistory = false
    
    var loggedInUser: Staff
    
    var body: some View {
        VStack {
            Button("Calculate Tips") {
                showCalculateTip = true
            }
            .padding()
            .sheet(isPresented: $showCalculateTip) {
                CalculateTipView(staffManager: staffManager)
            }
            
            Button("Add New Staff") {
                showAddNewStaff = true
            }
            .padding()
            .sheet(isPresented: $showAddNewStaff) {
                AddNewStaffView(staffManager: staffManager, loggedInUser: loggedInUser)
            }

            if loggedInUser.role == .owner {
                Button("Edit Tip History") {
                    showEditTipHistory = true
                }
                .padding()
                .sheet(isPresented: $showEditTipHistory) {
                    EditTipHistoryView(staffManager: staffManager)
                }
            }
        }
        .padding()
    }
}
