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
    let testRequest = Request(method: .GET, invalidURL)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.invalidURL)
  }

  func testRequestWithURLWithoutSchemeReturnsError() {
    let URLWithoutScheme = "apple.com"
    let testRequest = Request(method: .GET, URLWithoutScheme)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.noSchemeProvided)
  }

  func testRequestWithNoHostReturnsError() {
    let URLWithoutHost = "http://"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.noHostProvided)
  }

  func testRequestWithNoHostAndQueryReturnsError() {
    let URLWithoutHost = "http://?asd=asd"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.noHostProvided)
  }

  func testValidURLCreatesValidClientRequest() {
    let validURL = "https://66o.tech"
    let testRequest = Request(method: .GET, validURL)

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
