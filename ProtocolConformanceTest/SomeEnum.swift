public enum SomeEnum: String, CaseIterable {
    case first
    case second
}

extension SomeEnum: Identifiable {
    public var id: String { rawValue }
}

extension SomeEnum: VaultCompatible {}
