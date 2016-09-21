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

public enum ParameterEncodingError: Swift.Error {
    case couldNotCreateComponentsFromURL
    case couldNotCreateURLFromComponents
    case couldNotCreateMultipart
}

public protocol Encoding {

    func encode(_ request: inout NSMutableURLRequest, parameters: Request.Parameters?) throws
}

extension Encoding {

    typealias Components = [(String, String)]

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

    static func getComponents(from parameters: Request.Parameters) -> Components {
        let components = parameters.reduce(Components()) { value, element in
            let key = element.0
            let components = self.getComponents(key, element.1)
            return value + components
        }

        return components
    }


}
