import Foundation

public func *(lhs: Character, rhs: Int) -> String {
    return String(repeating: "\(lhs)", count: rhs)
}

extension DateFormatter {
    public convenience init(configure: (DateFormatter) -> Void) {
        self.init()
        configure(self)
    }
}
public let formatter = DateFormatter { $0.dateFormat = "HH:mm:ss.SSS" }
