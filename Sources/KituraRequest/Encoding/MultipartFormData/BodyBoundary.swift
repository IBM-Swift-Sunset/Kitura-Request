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

extension String {

    /// Boundary new line string.
    static let newLine = "\r\n"
}

/// Boundary struct for body parts separation.
public struct BodyBoundary {

    /// Boundary unique value.
    private(set) var value: String

    /// Initializes new boundary with predefined unique value.
    init() {
        let boundaryString = String(format: "kitura-request.boundary.%08x%08x", randomize(), randomize())
        self.init(boundaryString)
    }

    /// Initializes new boundary with specified unique value.
    ///
    /// - Parameter value: boundary unique value.
    init(_ value: String) {
        self.value = value
    }

    /// Boundary value that starts form-data.
    public var initial: Data? {
        let boundary = "--\(self.value)\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }

    /// Boundary value that separates form-data items.
    public var encapsulated: Data? {
        let boundary = "\(String.newLine)--\(self.value)\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }

    /// Boundary value that finishes form-data.
    public var final: Data? {
        let boundary = "\(String.newLine)--\(self.value)--\(String.newLine)"
        return boundary.data(using: .utf8, allowLossyConversion: false)
    }
}
