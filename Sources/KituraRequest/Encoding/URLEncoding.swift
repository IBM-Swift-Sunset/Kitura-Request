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

public struct URLEncoding: Encoding {

    public enum Mode {

        case `default`
        case urlQuery
        case httpBody
    }

    public static let `default` = URLEncoding(mode: .default)

    private(set) var mode: Mode

    public init(mode: Mode) {
        self.mode = mode
    }

    public func encode(_ request: inout URLRequest, parameters: Request.Parameters?) throws {
        guard let parameters = parameters,
            !parameters.isEmpty else {
                return
        }

        let method = request.httpMethod ?? "GET"

        if self.shouldEncodeInQuery(using: method) {
            guard let url = request.url,
                let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                    throw KituraRequest.Error.urlEncoding(.noComponentsFromURL) // this should never happen
            }

            components.query = URLEncoding.getQuery(from: parameters)

            guard let newURL = components.url else {
                throw KituraRequest.Error.urlEncoding(.noURLFromComponents) // this should never happen
            }

            request.url = newURL
        } else {
            let query = URLEncoding.getQuery(from: parameters)

            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = query.data(using: .utf8, allowLossyConversion: false)
        }
    }

    private func shouldEncodeInQuery(using method: String) -> Bool {
        switch (self.mode, method) {
        case (.urlQuery, _):
            return true
        case (.httpBody, _):
            return false
        case (_, "GET"), (_, "HEAD"):
            return true
        default:
            return false
        }
    }

    private static func getQuery(from parameters: Request.Parameters) -> String {
        let query = self.getComponents(from: parameters)
        return query.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
