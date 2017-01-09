/**
 * Copyright Sergey Minakov 2016
 * Copyright IBM Corporation 2017
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


extension BodyPart.MimeType {

    /// Image media type.
    public enum ImageSubtype: String {

        /// Any image.
        case any = "*"

        /// A .gif image.
        case gif = "gif"

        /// A .jpeg image.
        case jpeg = "jpeg"

        /// A .png image.
        case png = "png"

        /// A .tiff image.
        case tiff = "tiff"
    }

    /// Text media type.
    public enum TextSubtype: String {

        /// Any text.
        case any = "*"

        /// Text in .css format.
        case css = "css"

        /// Text in .csv format.
        case csv = "csv"

        /// Text in .html format.
        case html = "html"

        /// Text in javascript format.
        case javascript = "javascript"

        /// Plain text
        case plain = "plain"

        /// Text in .php format.
        case php = "php"

        /// Text in .xml format.
        case xml = "xml"
    }

    /// Application media type.
    public enum ApplicationSubtype: String {

        /// Any binary data.
        case any = "*"

        /// Json data format.
        case json = "json"

        /// Javascript data format.
        case javascript = "javascript"

        /// Unrecognized binary data format.
        case octetStream = "octet-stream"

        /// A .pdf data format.
        case pdf = "pdf"

        /// A .zip data format.
        case zip = "zip"

        /// A .gzip data format.
        case gzip = "gzip"
    }
}

