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

extension BodyPart {

    /// Body Part mime type enumeration.
    public enum MimeType {

        /// Empty mime type.
        case none

        /// Text mime type.
        case text(TextSubtype)

        /// Image mime type.
        case image(ImageSubtype)

        /// Application mime type.
        case application(ApplicationSubtype)

        /// Custom mime type.
        case raw(String)

        /// String representation of mime type.
        var value: String? {
            switch self {
            case .image(let type):
                return "image/\(type.rawValue)"
            case .text(let type):
                return "text/\(type.rawValue)"
            case .application(let type):
                return "application/\(type.rawValue)"
            case .raw(let value):
                return value
            default:
                break
            }
            return nil
        }
    }
}
