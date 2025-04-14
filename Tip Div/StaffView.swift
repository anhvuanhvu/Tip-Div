import SwiftUI

struct StaffView: View {
    var loggedInUser: Staff
    @ObservedObject var staffManager: StaffManager
    @State private var selectedDate = Date()
    @State private var tipAmount: Double = 0.0
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .onChange(of: selectedDate, perform: { date in
                    loadTip(for: date)
                })
            
            Text("Tip Earned: \(tipAmount, specifier: "%.2f")")
                .font(.headline)
                .padding()
        }
        .onAppear {
            loadTip(for: selectedDate)
        }
    }
    
    private func loadTip(for date: Date) {
        if let tip = loggedInUser.tipHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            tipAmount = tip.amount
        } else {
            tipAmount = 0.0
        }
    }
}
