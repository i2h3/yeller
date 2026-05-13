struct Message: Identifiable {
    var content: String
    var id: UInt
    var role: Role
    var sessionId: UInt
}
