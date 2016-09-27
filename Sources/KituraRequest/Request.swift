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


/// TODO: Make an asynchronus version
public class Request{

    var request: URLRequest?
    var response: URLResponse?
    var session: URLSession?
    var data: NSData?
    var error: Swift.Error?

    public typealias Parameters = [String : Any]

    public enum Method: String {
        case CONNECT, DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE
    }

    public typealias CompletionHandler = (_ request: URLRequest?, _ response: URLResponse?, _ data: Data?, _ error: Swift.Error?) -> Void

    public init(method: Method,
             _ url: String,
             parameters: Parameters? = nil,
             encoding: Encoding = URLEncoding.default,
             headers: [String: String]? = nil) {

        do {
            var urlRequest = try formatURL(url)
            try encoding.encode(&urlRequest, parameters: parameters)
            
            urlRequest.addValue("", forHTTPHeaderField: "schema")
            urlRequest.httpMethod = method.rawValue

            if let headers = headers {
                urlRequest.allHTTPHeaderFields = headers
            }

            self.request = urlRequest
        } catch {
            
            self.request = nil
            self.error = error
            
        }
    }

    public func response(_ completionHandler: @escaping CompletionHandler) {
        
        var configuration = URLSessionConfiguration()
        configuration = .default
        configuration.urlCache = nil
        
        session = URLSession(configuration: configuration)
        let result = session?.dataTask(with: self.request!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(self.request, nil, nil, error)
            }
            completionHandler(self.request, response, data, error)
        }

        result?.resume()

    }
}

extension Request {

    func formatURL(_ url: String) throws -> URLRequest {

      // or use NSURL:
      guard let validURL = URL(string: url) else {
        throw RequestError.invalidURL
      }

      guard validURL.scheme != nil else {
        throw RequestError.noSchemeProvided
      }

      guard validURL.host != nil else {
        throw RequestError.noHostProvided
      }

      return URLRequest(url: validURL)
    }
}
