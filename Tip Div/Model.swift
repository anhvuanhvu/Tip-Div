    import Foundation

    enum StaffRole: String, Codable, CaseIterable {
        case owner = "Owner"
        case manager = "Manager"
        case waiter = "Waiter/Waitress"
        case chef = "Chef"
    }

    struct Staff: Identifiable, Codable, Hashable {
        var id = UUID()
        var name: String
        var username: String
        var password: String
        var role: StaffRole
        var earnings: Double = 0.0
        var tipHistory: [Tip] = []

        // Conformance to Hashable
        static func == (lhs: Staff, rhs: Staff) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    struct Tip: Identifiable, Codable, Hashable {
        var id = UUID()
        var date: Date
        var amount: Double

        // Conformance to Hashable
        static func == (lhs: Tip, rhs: Tip) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
