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
import Bridging

public enum ParameterEncodingError: Swift.Error {
  case couldNotCreateComponentsFromURL
  case couldNotCreateURLFromComponents
}

public enum ParameterEncoding {
  case url
  case json
  case custom

  func encode( _ request: inout NSMutableURLRequest, parameters: [String: Any]?) throws {

    guard let parameters = parameters, !parameters.isEmpty else {
      return
    }

    switch self {
    case .url:
      guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
        throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
      }

      components.query = getQueryComponents(fromDictionary: parameters)

      guard let newURL = components.url else {
        throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
      }
      request.url = newURL

    case .json:
      let options = JSONSerialization.WritingOptions()
      // need to convert to NSDictionary as Dictionary(struct) is not AnyObject(instance of class only)
      #if os(Linux)
        let safe_parameters = parameters._bridgeToAnyObject() // don't try to print!!!
      #else
        let safe_parameters = parameters as NSDictionary
      #endif
      let data = try JSONSerialization.data(withJSONObject: safe_parameters, options: options)
      request.httpBody = data
      // set content type to application/json
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    default:
      throw RequestError.notImplemented
    }
  }
}

extension ParameterEncoding {
  typealias QueryComponents = [(String, String)]

  fileprivate func getQueryComponent(_ key: String, _ value: Any) -> QueryComponents {
    var queryComponents: QueryComponents = []

    switch value {
    case let d as [String: Any]:
      for (k, v) in d {
        queryComponents += getQueryComponent("\(key)[\(k)]", v)
      }
    case let d as NSDictionary:
    #if os(Linux)
      let convertedD = d._bridgeToSwift() // [NSObject : AnyObject]
      for (k, v) in convertedD {
        if let kk = k as? NSString {
          queryComponents += getQueryComponent("\(key)[\(kk._bridgeToSwift()))]", v)
        } // else consider throw or something
      }
    #else
      break
    #endif
    case let a as [AnyObject]:
      for value in a {
        queryComponents += getQueryComponent(key + "[]", value)
      }

    case let a as NSArray:
    #if os(Linux)
      for value in a._bridgeToSwift() {
        queryComponents += getQueryComponent(key + "[]", value)
      }
    #else
      break
    #endif
    default:
      queryComponents.append((key, "\(value)"))
    }
    return queryComponents
  }

  func getQueryComponents(fromDictionary dict: [String: Any]) -> String {
    var query: [(String, String)] = []

    for element in dict {
      query += getQueryComponent(element.0, element.1)
    }
    return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
  }
}
