import Foundation


extension String {
    static let newLine = "\r\n"
}

public struct BodyBoundary {

    private(set) var value: String

    init(_ value: String) {
        self.value = value
    }

    public var initial: Data? {
        let boundary = "--\(self.value)\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }

    public var encapsulated: Data? {
        let boundary = "\(String.newLine)--\(self.value)\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }

    public var final: Data? {
        let boundary = "\(String.newLine)--\(self.value)--\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }
}

public struct BodyPart {

    public enum MimeType {
        case none
    }

    private(set) var data: Data
    private(set) var mimeType: MimeType
    private(set) var fileName: String?

    public init(data: Data, mimeType: MimeType? = nil, fileName: String? = nil) {
        self.data = data
        self.mimeType = mimeType ?? .none
        self.fileName = fileName
    }

    private var header: String {
        return ""
    }

    public func content(for key: String) -> Data {
        return Data()
    }
}
