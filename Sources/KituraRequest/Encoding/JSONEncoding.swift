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

public struct JSONEncoding: Encoding {

    private(set) var options: JSONSerialization.WritingOptions

    public static let `default` = JSONEncoding(options: [])

    public init(options: JSONSerialization.WritingOptions) {
        self.options = options
    }

    public func encode(_ request: inout URLRequest, parameters: Request.Parameters?) throws {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let parameters = parameters, !parameters.isEmpty else { return }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: self.options)
            request.httpBody = data
        } catch {
            throw KituraRequest.Error.jsonEncoding(reason: error)
        }
    }
}
