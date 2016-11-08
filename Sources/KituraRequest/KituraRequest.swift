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

import Foundation

///
public class KituraRequest {

    /// Creates new request and performs it immediately.
    ///
    /// - Parameter method: request method.
    /// - Parameter URL: request url string.
    /// - Parameter parameters: parameters that will be send with request.
    /// - Parameter encoding: encoding that will be used.
    /// - Parameter headers: additional header.
    public static func request(_ method: Request.Method,
                            _ URL: String,
                            parameters: Request.Parameters? = nil,
                            encoding: Encoding = URLEncoding.default,
                            headers: [String: String]? = nil) -> Request {
        let request =  Request(method: method,
                            URL,
                            parameters: parameters,
                            encoding: encoding,
                            headers: headers)
        request.submit()
        return request
    }
}
