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
import KituraNet
import LoggerAPI


/// Wrapper around NSURLRequest
/// TODO: Make an asynchronus version
public class Request {

    private(set) var request: ClientRequest?
    private(set) var response: ClientResponse?
    private(set) var data: NSData?
    private(set) var error: Swift.Error?

    public init(method: Method,
             _ URL: String,
             parameters: Parameters? = nil,
             encoding: Encoding = URLEncoding.default,
             headers: [String: String]? = nil) {

        do {
            var options: [ClientRequest.Options] = []
            options.append(.schema("")) // so that ClientRequest doesn't apend http
            options.append(.method(method.rawValue)) // set method of request

            var urlRequest = try formatURL(URL)

            try encoding.encode(&urlRequest, parameters: parameters)

            options.append(.hostname(urlRequest.url!.absoluteString))

            // headers
            if let headers = headers {
                options.append(.headers(headers))
            }

            if let headers = urlRequest.allHTTPHeaderFields {
                options.append(.headers(headers))
            }

            // Create request
            let request = HTTP.request(options) { response in
                self.response = response
            }

            if let body = urlRequest.httpBody {
                request.write(from: body)
            }

            self.request = request
        } catch {
            self.request = nil
            self.error = error
        }
    }

    public func response(_ completionHandler: @escaping CompletionHandler) {
        guard let response = response else {
            completionHandler(request, nil, nil, error)
            return
        }

        var data = Data()
        do {
            _ = try response.read(into: &data)
            completionHandler(request, response, data, error)
        } catch {
            Log.error("Error in Kirutra-Request response: \(error)")
        }
    }

    func submit() {
        request?.end()
    }
}

extension Request {

    fileprivate func formatURL(_ url: String) throws -> URLRequest {
      guard let validURL = URL(string: url) else {
        throw KituraRequest.Error.urlFormat(.invalidURL)
      }

      guard validURL.scheme != nil else {
        throw KituraRequest.Error.urlFormat(.noSchemeProvided)
      }

      guard validURL.host != nil else {
        throw KituraRequest.Error.urlFormat(.noHostProvided)
      }

      return URLRequest(url: validURL)
    }
}
