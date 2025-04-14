import SwiftUI

struct EditTipHistoryView: View {
    @ObservedObject var staffManager: StaffManager
    @State private var selectedStaff: Staff?
    @State private var selectedDate = Date()
    @State private var selectedTip: Tip?
    @State private var newTipAmount = ""
    @State private var newTipDate = Date()
    @State private var showSuccessMessage = false

    var body: some View {
        VStack {
            List(staffManager.staffList) { staff in
                Button(action: {
                    selectedStaff = staff
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(staff.name)
                            Text(staff.role.rawValue).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                        if staff.role != .manager && staff.role != .owner {
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

            if let staff = selectedStaff {
                Text("Tip History for \(staff.name)")
                    .font(.headline)
                    .padding()

                DatePicker(
                    "Select Month",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                List {
                    ForEach(staff.tipHistory.filter { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }) { tip in
                        HStack {
                            Text(dateFormatter.string(from: tip.date))
                            Spacer()
                            Text("\(tip.amount, specifier: "%.2f")")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedTip = tip
                            self.newTipAmount = String(format: "%.2f", tip.amount)
                            self.newTipDate = tip.date
                        }
                    }
                }

                if let tip = selectedTip {
                    VStack {
                        Text("Tip Amount: \(tip.amount, specifier: "%.2f")")
                        TextField("New Tip Amount", text: $newTipAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        DatePicker("New Tip Date", selection: $newTipDate, displayedComponents: .date)
                            .padding()

                        HStack {
                            Button("Update Tip") {
                                updateTip(for: staff, oldTip: tip)
                            }
                            .padding()

                            Button("Delete Tip") {
                                deleteTip(for: staff, tip: tip)
                            }
                            .padding()
                        }

                        if showSuccessMessage {
                            Text("Tip updated successfully!")
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func updateTip(for staff: Staff, oldTip: Tip) {
        if let amount = Double(newTipAmount), let owner = staffManager.staffList.first(where: { $0.username == "owner" }) {
            let updatedTip = Tip(id: oldTip.id, date: newTipDate, amount: amount)
            staffManager.updateTip(for: staff, oldTip: oldTip, newTip: updatedTip, by: owner)
            showSuccessMessage = true
        }
    }

    private func deleteTip(for staff: Staff, tip: Tip) {
        if let owner = staffManager.staffList.first(where: { $0.username == "owner" }) {
            staffManager.deleteTip(for: staff, tip: tip, by: owner)
            showSuccessMessage = true
        }
    }

    private func deleteStaff(staff: Staff) {
        staffManager.deleteStaff(staff)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
