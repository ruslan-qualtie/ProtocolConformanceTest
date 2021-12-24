import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var model = ContentViewModel()

    var body: some View {
        VStack {
            Picker(selection: $model.selected, label: Text("Value:")) {
                ForEach(SomeEnum.allCases) {
                    Text($0.id).tag($0)
                }
            }
            Text(model.message)
            Button("Action") {
                model.action()
            }
        }
        .padding()
        .frame(width: 300, height: 100)
    }
}

public protocol VaultCompatible {
    static func decode(source: Any?) -> Self?
    func encode() -> Any
}

public struct Vault<T: VaultCompatible> {
    public var defaultValue: T
    private var encodedValue: Any?

    public var value: T {
        get { T.decode(source: encodedValue) ?? defaultValue }
        set { encodedValue = newValue.encode() }
    }

    public init(defaultValue: T) {
        self.defaultValue = defaultValue
    }
}

extension RawRepresentable where Self: VaultCompatible, RawValue == String {
    public static func decode(source: Any?) -> Self? {
        print("decode(source:)")
        if let value = source as? RawValue {
            return .init(rawValue: value)
        }
        return nil
    }

    public func encode() -> Any {
        print("encode()")
        return rawValue
    }
}

class ContentViewModel: ObservableObject {
    @Published public var message = "Initial value"
    @Published public var selected: SomeEnum = .first
    private var vault: Vault<SomeEnum> = .init(defaultValue: .first)
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $selected
            .sink { self.vault.value = $0 }
            .store(in: &cancellable)
    }
    
    func action() {
        message = "Handled \(vault.value) value"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
