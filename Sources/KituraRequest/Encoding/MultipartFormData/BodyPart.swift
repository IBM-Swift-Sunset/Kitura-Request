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

/// An item for `MultipartEncoding` used to encode files or data of specific type.
public struct BodyPart {

    /// An item key.
    private(set) public var key: String

    /// An item data.
    private(set) public var data: Data

    /// An item mime type.
    private(set) public var mimeType: MimeType

    /// Optional item file name.
    private(set) public var fileName: String?

    /// An optional initializer.
    ///
    /// - Parameter key: parameter key.
    /// - Parameter value: parameter value.
    public init?(key: String, value: Any) {
        let string = String(describing: value)
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }

        self.key = key
        self.data = data
        self.mimeType = .none
    }

    /// Initializes form item with specified parameters.
    ///
    /// - Parameter key: parameter key.
    /// - Parameter data: parameter data.
    /// - Parameter mimeType: parameter mime type.
    /// - Parameter fileName: optional parameter file name.
    public init(key: String, data: Data, mimeType: MimeType = .none, fileName: String? = nil) {
        self.key = key
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }

    /// A form item header.
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

    /// A form item content.
    ///
    /// - Returns: a data describing body item.
    public func content() throws -> Data {
        var result = Data()
        let headerString = self.header

        guard let header = headerString.data(using: .utf8, allowLossyConversion: false) else {
            throw KituraRequest.Error.multipartEncoding(.headerEncoding)
        }

        result.append(header)
        result.append(self.data)

        return result
    }
}
