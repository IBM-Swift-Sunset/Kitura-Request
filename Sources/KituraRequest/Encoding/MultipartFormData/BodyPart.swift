/**
 * Copyright Sergey Minakov 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/


import Foundation

public struct BodyPart {

    public enum MimeType {

        public enum Image: String {
            case any = "*"
            case png = "png"
            case jpeg = "jpeg"
        }

        case none
        case text
        case image(Image)

        var value: String? {
            switch self {
            case .image(let type):
                return "image/\(type.rawValue)"
            case .text:
                return "text/plain"
            default:
                break
            }
            return nil
        }
    }

    private(set) var key: String
    private(set) var data: Data
    private(set) var mimeType: MimeType
    private(set) var fileName: String?

    public init?(key: String, value: Any) {
        let string = String(describing: value)
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }

        self.key = key
        self.data = data
        self.mimeType = .none
    }

    public init(key: String, data: Data, mimeType: MimeType = .none, fileName: String? = nil) {
        self.key = key
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }

    private var header: String {
        var header = "Content-Disposition: form-data; name=\(self.key)"

        if let fileName = self.fileName {
            header += "; filename=\(fileName)"
        }

        if let mimeType = self.mimeType.value {
            header += "\(String.newLine)Content-Type: \(mimeType)"
        }

        header += "\(String.newLine)\(String.newLine)"

        return header
    }

    public func content() throws -> Data {
        var result = Data()
        let headerString = self.header
        guard let header = headerString.data(using: .utf8, allowLossyConversion: false) else {
            throw ParameterEncodingError.couldNotCreateMultipart
        }

        result.append(header)
        result.append(self.data)

        return result
    }
}
