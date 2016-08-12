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

public enum RequestMethod: String {
  case CONNECT, DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE
}

/// Wrapper around NSURLRequest
/// TODO: Make an asynchronus version
public class Request {
  var request: ClientRequest?
  var response: ClientResponse?
  var data: NSData?
  var error: Swift.Error?
  
  public typealias ResponseArguments = (request: ClientRequest?, response: ClientResponse?, data: NSData?, error:Swift.Error?)
  public typealias CompletionHandler = (ResponseArguments) -> Void
  
  public init(method: RequestMethod,
             _ URL: String,
             parameters: [String: AnyObject]? = nil,
             encoding: ParameterEncoding = .URL,
             headers: [String: String]? = nil) {
    
    do {
      var options: [ClientRequest.Options] = []
      options.append(.schema("")) // so that ClientRequest doesn't apend http
      options.append(.method(method.rawValue)) // set method of request
      
      // headers
      if let headers = headers {
        options.append(.headers(headers))
      }
      
      var urlRequest = try formatURL(URL)
    
      try encoding.encode(&urlRequest, parameters: parameters)
      options.append(.hostname(urlRequest.url!.absoluteString)) // safe to force unwrap here
      
      // Create request
      let request = HTTP.request(options) {
        response in
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
  
  public func response(_ completionHandler: CompletionHandler) {
    guard let response = response else {
      completionHandler((request, nil, nil, error))
      return
    }
    
    var data = Data()
    do {
      _ = try response.read(into: &data)
      completionHandler((request, response, data, error))
    } catch {
      print(error)
    }
  }
  
  func submit() {
    request?.end()
  }
}

extension Request {
  func formatURL(_ url: String) throws -> NSMutableURLRequest {
    // Regex to test validity of url:
    // _^(?:(?:https?|ftp)://)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)(?:\.(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)*(?:\.(?:[a-z\x{00a1}-\x{ffff}]{2,})))(?::\d{2,5})?(?:/[^\s]*)?$_iuS
    // also check RFC 1808

    // or use NSURL:
    guard let validURL = URL(string: url) else {
      throw RequestError.InvalidURL
    }
    
    guard validURL.scheme != nil else {
      throw RequestError.NoSchemeProvided
    }
    
    guard validURL.host != nil else {
      throw RequestError.NoHostProvided
    }
    
    return NSMutableURLRequest(url: validURL)
  }
}
