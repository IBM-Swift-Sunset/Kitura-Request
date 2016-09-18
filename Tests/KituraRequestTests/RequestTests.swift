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

class RequestTests: XCTestCase {

  var testRequest = KituraRequest.request(.POST,
                                          "https://google.com",
                                          parameters: ["asd":"asd"],
                                          encoding: .url,
                                          headers: ["User-Agent":"Kitura-Server"]
  )

  func testRequestAssignsClientRequestURL() {
    XCTAssertEqual(testRequest.request?.url, "https://google.com?asd=asd")
  }

  func testRequestAssignClientRequestMethod() {
    XCTAssertEqual(testRequest.request?.method, "POST")
  }

  func testRequestAssignsClientRequestHeaders() {
    if let headers = testRequest.request?.headers {
      XCTAssertEqual(headers["User-Agent"], "Kitura-Server")
    } else {
      XCTFail()
    }
  }

    func testMultipartRequest() {
        KituraRequest.request(.GET,
            "http://httpbin.org/image/png").response { _, _, data, error in
                guard let data = data else {
                    XCTFail("data should exits")
                    return;
                }

                KituraRequest.request(.POST,
                    "http://httpbin.org/post",
                    parameters: [
                        "key" : "value",
                        "file" : BodyPart(data: data, mimeType: .image(.png), fileName: "image.jpg")
                    ], encoding: .multipart).response { _, _, data, error in
                        guard let string = dataToString(data) else {
                            XCTFail("can't parse response")
                            return
                        }

                        if !string.contains("\"file\": \"data:image/png;base64,") {
                            XCTFail("file should exits in request")
                        }

                        if !string.contains("\"key\": \"value\"") {
                            XCTFail("file should exits in request")
                        }
                }
            }
    }
}

extension RequestTests {
  static var allTests : [(String, (RequestTests) -> () throws -> Void)] {
    return [
        ("testRequestAssignsClientRequestURL", testRequestAssignsClientRequestURL),
        ("testRequestAssignClientRequestMethod", testRequestAssignClientRequestMethod),
        ("testRequestAssignsClientRequestHeaders", testRequestAssignsClientRequestHeaders),
        ("testMultipartRequest", testMultipartRequest)
    ]
  }
}
