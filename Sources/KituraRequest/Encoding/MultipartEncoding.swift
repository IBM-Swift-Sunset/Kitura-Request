/**
 * Original work Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
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

import Foundation

/// Multipart encoder.
public struct MultipartEncoding: Encoding {

    /// Body parts array.
    private var bodyParts: [BodyPart]?

    /// Initialize new encoder for specified body parts.
    ///
    /// - Parameter bodyParts: body parts that will be encoded alogside request parameters.
    public init(_ bodyParts: [BodyPart]?) {
        self.bodyParts = bodyParts
    }

    /// Encode parameters as multipart/form-data
    ///
    /// - Parameter request: URL request used in encoding.
    /// - Parameter parameters: parameters of the request.
    public func encode(_ request: inout URLRequest, parameters: Request.Parameters?) throws {
        let bodyData = try self.body(for: parameters)

        if let httpBody = bodyData.0 {
            request.httpBody = httpBody
        }

        if let boundary = bodyData.1 {
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        }
    }

    /// Parses parameters for multipart/form-data
    ///
    /// - Parameter parameters: parameters of the request.
    ///
    /// - Returns: a http body and boundary value.
    private func body(for parameters: Request.Parameters?) throws -> (Data?, String?) {
        var requestBodyParts = [BodyPart]()

        if let parameters = parameters {
            let parameters = MultipartEncoding.getComponents(from: parameters)

            let parameterParts = parameters.flatMap { item in
                return BodyPart(key: item.0, value: item.1)
            }

            requestBodyParts += parameterParts
        }

        if let bodyParts = self.bodyParts {
            requestBodyParts += bodyParts
        }

        guard !requestBodyParts.isEmpty else {
            return (nil, nil)
        }

        let boundary = BodyBoundary()
        var result = Data()

        for (index, bodyPart) in requestBodyParts.enumerated() {
            let bodyBoundary: Data

            if index == 0,
                let initial = boundary.initial {
                    bodyBoundary = initial
            } else if index != 0,
                let encapsulated = boundary.encapsulated {
                    bodyBoundary = encapsulated
            } else {
                throw KituraRequest.Error.multipartEncoding(.noBoundary)
            }

            result.append(bodyBoundary)

            let parameterBody = try bodyPart.content()
            result.append(parameterBody)
        }

        guard let final = boundary.final else {
            throw KituraRequest.Error.multipartEncoding(.noBoundary)
        }

        result.append(final)

        return (result, boundary.value)
    }
}
