import Foundation

class StaffManager: ObservableObject {
    @Published var staffList: [Staff] = []
    
    init() {
        loadStaffList()
        ensureOwnerExists()
        printStaffList()
    }
    
    func loadStaffList() {
        // Load staff list from UserDefaults or another persistent storage
        if let savedStaffList = UserDefaults.standard.data(forKey: "StaffList") {
            let decoder = JSONDecoder()
            if let decodedStaffList = try? decoder.decode([Staff].self, from: savedStaffList) {
                self.staffList = decodedStaffList
                return
            }
        }
        
        // If no staff list found, initialize with some example staff including owner
        self.staffList = [
            Staff(id: UUID(), name: "Admin", username: "admin", password: "adminpass", role: .manager),
            Staff(id: UUID(), name: "John Doe", username: "john", password: "johnpass", role: .waiter),
            Staff(id: UUID(), name: "Jane Smith", username: "jane", password: "janepass", role: .waiter),
            Staff(id: UUID(), name: "Owner", username: "owner", password: "owner", role: .owner)
        ]
    }
    func ensureOwnerExists() {
            if !staffList.contains(where: { $0.username == "owner" }) {
                let owner = Staff(id: UUID(), name: "Owner", username: "owner", password: "owner", role: .owner)
                staffList.append(owner)
                saveStaffList() // Save after adding the owner
            }
    }
    
    func saveStaffList() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(staffList) {
            UserDefaults.standard.set(encoded, forKey: "StaffList")
        }
    }
    
    func addStaff(name: String, username: String, password: String, role: StaffRole) {
        let newStaff = Staff(id: UUID(), name: name, username: username, password: password, role: role)
        staffList.append(newStaff)
        saveStaffList() // Save after adding new staff
    }
    
    func deleteStaff(_ staff: Staff) {
        staffList.removeAll { $0.id == staff.id }
        saveStaffList() // Save after deleting staff
    }
    
    func updateStaffEarnings(for staff: Staff, earnings: Double, date: Date) {
        if let index = staffList.firstIndex(where: { $0.id == staff.id }) {
            let tip = Tip(id: UUID(), date: date, amount: earnings)
            staffList[index].tipHistory.append(tip)
            saveStaffList() // Save after updating earnings
        }
    }
    
    func updateTip(for staff: Staff, oldTip: Tip, newTip: Tip, by user: Staff) {
        guard user.role == .owner else { return } // Only owner can update tips
        if let staffIndex = staffList.firstIndex(where: { $0.id == staff.id }) {
            if let tipIndex = staffList[staffIndex].tipHistory.firstIndex(where: { $0.id == oldTip.id }) {
                staffList[staffIndex].tipHistory[tipIndex] = newTip
                saveStaffList() // Save after updating tip
            }
        }
    }
    
    func deleteTip(for staff: Staff, tip: Tip, by user: Staff) {
        guard user.role == .owner else { return } // Only owner can delete tips
        if let staffIndex = staffList.firstIndex(where: { $0.id == staff.id }) {
            staffList[staffIndex].tipHistory.removeAll { $0.id == tip.id }
            saveStaffList() // Save after deleting tip
        }
    }
    func printStaffList() {
            for staff in staffList {
                print("Name: \(staff.name), Username: \(staff.username), Role: \(staff.role.rawValue)")
            }
    }
}
