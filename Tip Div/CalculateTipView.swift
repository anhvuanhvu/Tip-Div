import SwiftUI

struct CalculateTipView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var selectedDate = Date()
    @State private var creditTip: Double = 0
    @State private var cashTip: Double = 0
    @State private var selectedStaff: [Staff] = []
    @State private var showConfirmation = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var staffEarnings: [UUID: Double] = [:]
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .padding()
            
            Text("Credit Tip")
                .font(.headline)
                .padding(.top)
            
            TextField("Credit Tip", value: $creditTip, formatter: NumberFormatter())
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Cash Tip")
                .font(.headline)
                .padding(.top)
            
            TextField("Cash Tip", value: $cashTip, formatter: NumberFormatter())
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Select Staff")
                .font(.headline)
                .padding(.top)
            
            List(staffManager.staffList.filter { $0.role != .manager && $0.role != .owner }) { staff in
                MultipleSelectionRow(staff: staff, isSelected: selectedStaff.contains(where: { $0.id == staff.id })) {
                    if selectedStaff.contains(where: { $0.id == staff.id }) {
                        selectedStaff.removeAll { $0.id == staff.id }
                    } else {
                        selectedStaff.append(staff)
                    }
                }
            }
            .padding(.bottom)
            
            Button("Calculate Tips") {
                calculateTips()
            }
            .padding()
            
            if showConfirmation {
                VStack {
                    Text("Tip Breakdown")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(selectedStaff) { staff in
                        Text("\(staff.name): \(staffEarnings[staff.id] ?? 0.0, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Button("Commit") {
                            confirmTips()
                        }
                        .padding()
                        
                        Button("Cancel") {
                            showConfirmation = false
                        }
                        .padding()
                    }
                    
                    if showAlert {
                        Text(alertMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
        .padding()
    }
    
    private func calculateTips() {
        guard !selectedStaff.isEmpty else {
            alertMessage = "Please select at least one staff member."
            showAlert = true
            return
        }
        
        let totalTip = (creditTip * 0.8) + cashTip
        let tipPerStaff = totalTip / Double(selectedStaff.count)
        staffEarnings = Dictionary(uniqueKeysWithValues: selectedStaff.map { ($0.id, tipPerStaff) })
        showConfirmation = true
        showAlert = false
    }
    
    private func confirmTips() {
        guard !tipsAlreadyCommitted(for: selectedDate) else {
            alertMessage = "Tips for this date have already been committed."
            showAlert = true
            return
        }
        
        var staffTipCounts: [UUID: Int] = [:]
        
        for staff in selectedStaff {
            if let earnings = staffEarnings[staff.id] {
                let currentTipCount = staff.tipHistory.filter {
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }.count
                
                if currentTipCount >= 2 {
                    alertMessage = "\(staff.name) has already received tips for 2 shifts on this date."
                    showAlert = true
                    return
                }
                
                staffManager.updateStaffEarnings(for: staff, earnings: earnings, date: selectedDate)
                staffTipCounts[staff.id, default: 0] += 1
            }
        }
        
        showConfirmation = false
        showAlert = false
        alertMessage = "Tips committed successfully!"
    }
    
    private func tipsAlreadyCommitted(for date: Date) -> Bool {
        for staff in staffManager.staffList {
            if staff.tipHistory.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                return true
            }
        }
        return false
    }
}

struct MultipleSelectionRow: View {
    var staff: Staff
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(staff.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
