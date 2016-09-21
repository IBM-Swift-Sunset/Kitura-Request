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
        try JSONEncoding.default.encode(&urlRequest, parameters: nil)
        XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }

  func testJSONParameterEncodingWhenEmptyPassed() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try JSONEncoding.default.encode(&urlRequest, parameters: [:])
        XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }

  func testJSONParameterEncodingSetsHeaders() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try JSONEncoding.default.encode(&urlRequest, parameters: ["p1":1])
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    } catch {
      XCTFail()
    }
  }

  func testJSONParametersEncodingSetsBody() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try JSONEncoding.default.encode(&urlRequest, parameters: ["p1":1])
        let body = dataToString(urlRequest.httpBody)
        XCTAssertEqual(body, "{\"p1\":1}")
    } catch {
      XCTFail()
    }
  }
    func testJSONParametersEncodingSetsBodyWithArray() {
        var urlRequest = NSMutableURLRequest(url: url)
        do {
            try JSONEncoding.default.encode(&urlRequest, parameters: ["p1":[1,2]])
            let body = dataToString(urlRequest.httpBody)
            XCTAssertEqual(body, "{\"p1\":[1,2]}")
        } catch {
            XCTFail()
        }
    }

    func testJSONArrayParametersEncodingSetsBody() {
        var urlRequest = NSMutableURLRequest(url: url)
        do {
            try JSONEncoding.default.encode(&urlRequest, parameters: ["p1":1, "p2": 2])
            guard let body = dataToString(urlRequest.httpBody) else {
                XCTFail("should have a body")
                return
            }
            XCTAssertTrue(body.contains("\"p1\":1"), "json encoding error")
            XCTAssertTrue(body.contains("\"p2\":2"), "json encoding error")
        } catch {
            XCTFail()
        }
    }

  // URL Encoding

  func testURLParametersEncodingWithNilParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: nil)
        XCTAssertEqual(urlRequest.url?.absoluteURL, url.absoluteURL)
    } catch {
      XCTFail()
    }
  }

  func testURLParametersEncodingWithEmptyParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: [:])
        XCTAssertEqual(urlRequest.url?.absoluteString, url.absoluteString)
    } catch {
      XCTFail()
    }
  }

  func testURLParametersEncodingWithSimpleParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: ["a":1, "b":2])
        guard let query = urlRequest.url?.query else {
            XCTFail("should have a body")
            return
        }
        XCTAssertTrue(query.contains("a=1"), "url encoding error")
        XCTAssertTrue(query.contains("b=2"), "url encoding error")
    } catch {
      XCTFail()
    }
  }

  func testURLParametersEncodingWithArray() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: ["a":[1, 2]])
        XCTAssertEqual(urlRequest.url?.query, "a%5B%5D=1&a%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }

  func testURLParametersEncodingWithDictionary() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: ["a" : ["b" : 1]])
        XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D=1") // this may be brittle
    } catch {
      XCTFail()
    }
  }

  func testURLParametersEncodingWithArrayNestedInDict() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
        try URLEncoding.default.encode(&urlRequest, parameters: ["a" : ["b" : [1, 2]]])
        XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D%5B%5D=1&a%5Bb%5D%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }
}

extension ParameterEncodingTests {
  static var allTests: [(String, (ParameterEncodingTests) -> () throws -> Void)] {
    return [
             ("testJSONParameterEncodingWhenNilPassedAsParameters", testJSONParameterEncodingWhenNilPassedAsParameters),
             ("testJSONParameterEncodingWhenEmptyPassed", testJSONParameterEncodingWhenEmptyPassed),
             ("testJSONParameterEncodingSetsHeaders", testJSONParameterEncodingSetsHeaders),
             ("testJSONParametersEncodingSetsBody", testJSONParametersEncodingSetsBody),
             ("testJSONParametersEncodingSetsBodyWithArray", testJSONParametersEncodingSetsBodyWithArray),
             ("testJSONArrayParametersEncodingSetsBody", testJSONArrayParametersEncodingSetsBody),
             ("testURLParametersEncodingWithNilParameters", testURLParametersEncodingWithNilParameters),
             ("testURLParametersEncodingWithEmptyParameters", testURLParametersEncodingWithEmptyParameters),
             ("testURLParametersEncodingWithSimpleParameters", testURLParametersEncodingWithSimpleParameters),
             ("testURLParametersEncodingWithArray",testURLParametersEncodingWithArray),
             ("testURLParametersEncodingWithDictionary", testURLParametersEncodingWithDictionary),
             ("testURLParametersEncodingWithArrayNestedInDict", testURLParametersEncodingWithArrayNestedInDict)
    ]
  }
}
