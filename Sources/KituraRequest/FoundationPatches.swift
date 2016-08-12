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

// Patches to fix missing features of Swift Foundation

extension NSMutableURLRequest {
  #if os(Linux)
  private struct addedProperties {
    static var httpBody: NSData?
  }
  var httpBody: NSData? {
    get {
      return addedProperties.httpBody
    }
    set {
      addedProperties.httpBody = newValue
    }
  }
  #endif
}

extension NSURLComponents {
  class func safeInit(URL url: URL, resolvingAgainstBaseURL resolve: Bool) -> NSURLComponents? {
    #if os(Linux)
      return NSURLComponents(URL: url, resolvingAgainstBaseURL: resolve)
    #else
      return NSURLComponents(url: url, resolvingAgainstBaseURL: resolve)
    #endif
  }
  
  func safeGetURL() -> URL? {
    #if os(Linux)
      return self.URL
    #else
      return self.url
    #endif
  }
}

#if os(Linux)
  func convertValuesToAnyObject(_ d: [String: Any]?) -> [String: AnyObject]? {
    
    guard let d = d else {
      return nil
    }
    
    let nsdict = d.bridge()
    let backdict = nsdict.bridge() // looks hacky but produces [NSObject: AnyObject] hassle free
    
    var result: [String: AnyObject] = [:]
    for (key, value) in backdict {
      result[(key as! NSString).bridge()] = value
    }
    return result
  }
#endif


