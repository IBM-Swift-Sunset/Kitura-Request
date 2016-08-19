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

        public enum Image: String {
            case png = "png"
            case jpeg = "jpeg"
        }

        case none
        // case text
        case image(type: Image)

        var value: String? {
            switch self {
            case .image(let type):
                return "image/\(type.rawValue)"
            default:
                break
            }
            return nil
        }
    }

    private(set) var data: Data
    private(set) var mimeType: MimeType
    private(set) var fileName: String?

    public init?(_ object: AnyObject) {
        let string = String(object)
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }

        self.data = data
        self.mimeType = .none
    }

    public init(data: Data, mimeType: MimeType = .none, fileName: String? = nil) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }

    private func header(for key: String) -> String {
        var header = "Content-Disposition: form-data; name=\(key)"

        if let fileName = self.fileName {
            header += "; filename=\(fileName)"
        }

        if let mimeType = self.mimeType.value {
            header += "\(String.newLine)Content-Type: \(mimeType)"
        }

        header += "\(String.newLine)\(String.newLine)"

        return header
    }

    public func content(for key: String) throws -> Data {
        var result = Data()
        let headerString = self.header(for: key)
        guard let header = headerString.data(using: .utf8, allowLossyConversion: false) else {
            throw ParameterEncodingError.CouldNotCreateMultipart
        }

        result.append(header)
        result.append(self.data)

        return result
    }
}
