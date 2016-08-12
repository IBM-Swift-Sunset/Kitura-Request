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

import XCTest
import Foundation
@testable import KituraRequest

class ParameterEncodingTests: XCTestCase {
  let url = URL(string: "https://66o.tech")!
  
  // JSON encoding
  
  func testJSONParameterEncodingWhenNilPassedAsParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(nil))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: nil)
      #endif
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingWhenEmptyPassed() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject([:]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: [:])
      #endif
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: [:])
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingSetsHeaders() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(["p1":1]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1])
      #endif
      XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParametersEncodingSetsBody() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(["p1":1]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1])
      #endif
      let body = dataToString(urlRequest.httpBody)
      XCTAssertEqual(body, "{\"p1\":1}")
    } catch {
      XCTFail()
    }
  }
  
  // URL Encoding
  
  func testURLParametersEncodingWithNilParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(nil))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: nil)
      #endif
      XCTAssertEqual(urlRequest.url?.absoluteURL, url.absoluteURL)
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithEmptyParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject([:]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: [:])
      #endif
      XCTAssertEqual(urlRequest.url?.absoluteString, url.absoluteString)
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithSimpleParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a":1, "b":2]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a":1, "b":2])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "b=2&a=1") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithArray() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a":[1, 2]]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a":[1, 2]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5B%5D=1&a%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithDictionary() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        let nestedDict: [String: Any] = ["b" : 1]
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a" : nestedDict]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a" : ["b" : 1]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D=1") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithArrayNestedInDict() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        let nestedDict: [String: Any] = ["b" : [1, 2]]
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a" : nestedDict]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a" : ["b" : [1, 2]]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D%5B%5D=1&a%5Bb%5D%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }
}

extension ParameterEncodingTests {
  static var allTests : [(String, (ParameterEncodingTests) -> () throws -> Void)] {
    return [
             ("testJSONParameterEncodingWhenNilPassedAsParameters", testJSONParameterEncodingWhenNilPassedAsParameters),
             ("testJSONParameterEncodingWhenEmptyPassed", testJSONParameterEncodingWhenEmptyPassed),
             ("testJSONParameterEncodingSetsHeaders", testJSONParameterEncodingSetsHeaders),
             ("testJSONParametersEncodingSetsBody", testJSONParametersEncodingSetsBody),
             ("testURLParametersEncodingWithNilParameters", testURLParametersEncodingWithNilParameters),
             ("testURLParametersEncodingWithEmptyParameters",
              testURLParametersEncodingWithEmptyParameters),
             ("testURLParametersEncodingWithSimpleParameters",
              testURLParametersEncodingWithSimpleParameters),
             ("testURLParametersEncodingWithArray",testURLParametersEncodingWithArray),
             ("testURLParametersEncodingWithDictionary", testURLParametersEncodingWithDictionary),
             ("testURLParametersEncodingWithArrayNestedInDict", testURLParametersEncodingWithArrayNestedInDict)
    ]
  }
}
