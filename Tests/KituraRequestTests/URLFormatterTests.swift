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
import KituraNet

@testable import KituraRequest

class URLFormatterTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  func testRequestWithInvalidReturnsError() {
    let invalidURL = "http://💩.com"
    let testRequest = Request(method: .get, invalidURL)

    guard case .urlFormat(.invalidURL) = testRequest.error as! KituraRequest.Error else {
        XCTFail()
        return
    }
  }

  func testRequestWithURLWithoutSchemeReturnsError() {
    let URLWithoutScheme = "apple.com"
    let testRequest = Request(method: .get, URLWithoutScheme)

    guard case .urlFormat(.noSchemeProvided) = testRequest.error as! KituraRequest.Error else {
        XCTFail()
        return
    }
  }

  func testRequestWithNoHostReturnsError() {
    let URLWithoutHost = "http://"
    let testRequest = Request(method: .get, URLWithoutHost)

    guard case .urlFormat(.noHostProvided) = testRequest.error as! KituraRequest.Error else {
        XCTFail()
        return
    }
  }

  func testRequestWithNoHostAndQueryReturnsError() {
    let URLWithoutHost = "http://?asd=asd"
    let testRequest = Request(method: .get, URLWithoutHost)

    guard case .urlFormat(.noHostProvided) = testRequest.error as! KituraRequest.Error else {
        XCTFail()
        return
    }
  }

  func testValidURLCreatesValidClientRequest() {
    let validURL = "https://66o.tech"
    let testRequest = Request(method: .get, validURL)

    XCTAssertEqual(testRequest.request?.url, validURL)
  }
}

extension URLFormatterTests {
  static var allTests: [(String, (URLFormatterTests) -> () throws -> Void)] {
    return [
             ("testRequestWithInvalidReturnsError", testRequestWithInvalidReturnsError),
             ("testRequestWithURLWithoutSchemeReturnsError", testRequestWithURLWithoutSchemeReturnsError),
             ("testRequestWithNoHostReturnsError", testRequestWithNoHostReturnsError),
             ("testRequestWithNoHostAndQueryReturnsError", testRequestWithNoHostAndQueryReturnsError),
             ("testValidURLCreatesValidClientRequest", testValidURLCreatesValidClientRequest)
    ]
  }
}
