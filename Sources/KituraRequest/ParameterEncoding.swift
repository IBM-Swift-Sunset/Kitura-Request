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

public enum ParameterEncodingError: Swift.Error {
  case CouldNotCreateComponentsFromURL
  case CouldNotCreateURLFromComponents
}

public enum ParameterEncoding {
  case URL
  case JSON
  case Custom
  
  func encode(_ request: inout NSMutableURLRequest, parameters: [String: AnyObject]?) throws {
    
    guard let parameters = parameters, !parameters.isEmpty else {
      return
    }
    
    switch self {
    case .URL:
      guard let components = NSURLComponents.safeInit(URL: request.url!, resolvingAgainstBaseURL: false) else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      
      components.query = getQueryComponents(fromDictionary: parameters)
      
      guard let newURL = components.safeGetURL() else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      request.url = newURL
      
    case .JSON:
      let options = JSONSerialization.WritingOptions()
      // need to convert to NSDictionary as Dictionary(struct) is not AnyObject(instance of class only)
      #if os(Linux)
        let safe_parameters = parameters._bridgeToObject() // don't try to print!!!
      #else
        let safe_parameters = parameters as NSDictionary
      #endif
      let data = try JSONSerialization.data(withJSONObject: safe_parameters, options: options)
      request.httpBody = data
      // set content type to application/json
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    default:
      throw RequestError.NotImplemented
    }
  }
}

extension ParameterEncoding {
  typealias QueryComponents = [(String, String)]
  
  private func getQueryComponent(_ key: String, _ value: AnyObject) -> QueryComponents {
    var queryComponents: QueryComponents = []
    
    switch value {
    case let d as [String: AnyObject]:
      for (k, v) in d {
        queryComponents += getQueryComponent("\(key)[\(k)]", v)
      }
    case let d as NSDictionary:
    #if os(Linux)
      let convertedD = d.bridge() // [NSObject : AnyObject]
      for (k, v) in convertedD {
        if let kk = k as? NSString {
          queryComponents += getQueryComponent("\(key)[\(kk.bridge())]", v)
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
      for value in a.bridge() {
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
  
  func getQueryComponents(fromDictionary dict: [String: AnyObject]) -> String {
    var query: [(String,String)] = []
    
    for element in dict {
      query += getQueryComponent(element.0, element.1)
    }
    
    return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
  }
}
