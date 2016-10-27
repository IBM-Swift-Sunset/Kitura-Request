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

/// Common encoding protocol.
public protocol Encoding {

    /// Method used for `Request` parameters encoding.
    func encode(_ request: inout URLRequest, parameters: Request.Parameters?) throws
}

extension Encoding {

    /// Encoding components.
    typealias Components = [(String, String)]

    /// Parse components from key and value.
    ///
    /// - Parameter key: string value of parameter key.
    /// - Parameter value: value of parameter.
    ///
    /// - Returns: a components array
    private static func getComponents(_ key: String, _ value: Any) -> Components {
        var result = Components()

        switch value {
        case let dictionary as [String: Any]:
            result = dictionary.reduce(result) { value, element in
                let components = self.getComponents("\(key)[\(element.0)]", element.1)
                return value + components
            }
        case let array as [Any]:
            result = array.reduce(result) { value, element in
                let components = self.getComponents("\(key)[]", element)
                return value + components
            }
        default:
            result.append((key, "\(value)"))
        }

        return result
    }

    /// Parse `Request` parameters to components for encoder
    ///
    /// - Parameter parameters: parameters to parse
    ///
    /// - Returns: a components array
    static func getComponents(from parameters: Request.Parameters) -> Components {
        let components = parameters.reduce(Components()) { value, element in
            let key = element.0
            let components = self.getComponents(key, element.1)
            return value + components
        }

        return components
    }
}
