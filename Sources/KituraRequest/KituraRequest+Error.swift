/**
 * Copyright Michal Kalinowski 2016
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

extension KituraRequest {

    /// Errors that can be thrown by `KituraRequest`.
    public enum Error: Swift.Error {

        /// URL encoding error subtypes.
        public enum URLEncodingError {

            /// Could not generate a components from formatted URL.
            case noComponentsFromURL

            /// Could not generate an URL from provided components.
            case noURLFromComponents
        }

        /// Multipart encoding error subtypes.
        public enum MultipartEncodingError {

            /// Could not generate a multipart header data.
            case headerEncoding

            /// Could not find a corresponding boundary while encoding.
            case noBoundary
        }

        /// Used when there is an error in `URLEconding`.
        case urlEncoding(URLEncodingError)

        /// Used when there is an error in `MultipartEncoding`.
        case multipartEncoding(MultipartEncodingError)

        /// Used when there is an error in `JSONEncoding`.
        case jsonEncoding(reason: Swift.Error)

        /// URL format error subtypes.
        public enum URLFormatError {

            /// An incorrect url string was passed to request.
            case invalidURL

            /// Provided url did not contain a host.
            case noHostProvided

            /// Provided url did not contain a scheme.
            case noSchemeProvided
        }

        /// Used when there is an error in url generation.
        case urlFormat(URLFormatError)
    }
}
