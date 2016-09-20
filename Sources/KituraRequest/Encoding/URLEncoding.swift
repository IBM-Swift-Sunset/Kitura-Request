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

    public static let `default` = URLEncoding()

    public func encode(_ request: inout NSMutableURLRequest, parameters: Request.Parameters?) throws {
        guard let parameters = parameters, !parameters.isEmpty else { return }

        guard let url = request.url,
            let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
        }

        components.query = URLEncoding.getQuery(from: parameters)

        guard let newURL = components.url else {
            throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
        }

        request.url = newURL
    }

    private static func getQuery(from parameters: Request.Parameters) -> String {
        let query = self.getComponents(from: parameters)
        return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
}
