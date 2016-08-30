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
    case CouldNotCreateMultipart
}

public enum ParameterEncoding {
    case URL
    case JSON
    case Multipart
    case Custom

    func encode(_ request: inout NSMutableURLRequest, parameters: [String: Any]?) throws {
        guard let parameters = parameters, !parameters.isEmpty else {
            return
        }

        switch self {
        case .URL:
	    //guard let objParameters = convertValuesToAnyObject(parameters) else { return }
            try self.encodeInURL(request: &request, parameters: parameters)
        case .JSON:
            try self.encodeInJSON(request: &request, parameters: parameters)
        case .Multipart:
            try self.encodeInFormData(request: &request, parameters: parameters)
        default:
            throw RequestError.NotImplemented
        }
    }

    private func encodeInURL(request: inout NSMutableURLRequest, parameters: [String: Any]) throws {
        guard let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
        }

        components.query = ParameterEncoding.getQueryComponents(fromDictionary: parameters)

        guard let newURL = components.url else {
            throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
        }

        request.url = newURL
    }

    private func encodeInJSON(request: inout NSMutableURLRequest, parameters: [String: Any]) throws {
        let options = JSONSerialization.WritingOptions()

        let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
        request.httpBody = data
        // set content type to application/json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func encodeInFormData(request: inout NSMutableURLRequest, parameters: [String: Any]) throws {
        print("form")
        let boundaryString = String(format: "kitura-request.boundary.%08x%08x", randomize(), randomize())
        print(boundaryString)
        let boundary = BodyBoundary(boundaryString)

        let parameters = ParameterEncoding.getComponents(from: parameters)

        var bodyParameters = parameters.query.flatMap { item -> (key: String, part: BodyPart)? in
            let key = item.0
        #if os(Linux)
            let value = item.1._bridgeToObject()
        #else
            let value = item.1
        #endif

            guard let returnValue = BodyPart(value) else {
                return nil
            }
            return (key, returnValue)
        }

        bodyParameters += parameters.body

        var httpBody = Data()

        for (index, bodyPart) in bodyParameters.enumerated() {
            let bodyBoundary: Data

            if index == 0,
                let initial = boundary.initial {
                    bodyBoundary = initial
            } else if index != 0,
                let encapsulated = boundary.encapsulated {
                    bodyBoundary = encapsulated
            } else {
                throw ParameterEncodingError.CouldNotCreateMultipart
            }

            httpBody.append(bodyBoundary)

            let parameterBody = try bodyPart.part.content(for: bodyPart.key)
            httpBody.append(parameterBody)
        }

        guard let final = boundary.final else {
            throw ParameterEncodingError.CouldNotCreateMultipart
        }

        httpBody.append(final)

        request.httpBody = httpBody
        request.setValue("multipart/form-data; boundary=\(boundary.value)", forHTTPHeaderField: "Content-Type")
        print("set header")
    }
}

extension ParameterEncoding {

    typealias QueryComponents = [(String, String)]
    typealias BodyPartComponents = [(key: String, part: BodyPart)]

    private static func getQueryComponent(_ key: String, _ value: Any) -> (query: QueryComponents, body: BodyPartComponents) {
        var queryComponents = QueryComponents()
        var bodyPartComponents = BodyPartComponents()

        switch value {
        case let bodyPart as BodyPart:
            bodyPartComponents += [(key: key, part: bodyPart)]
            break
        case let d as [String: AnyObject]:
            for (k, v) in d {
                let components = getQueryComponent("\(key)[\(k)]", v)
                queryComponents += components.query
                bodyPartComponents += components.body
            }
        case let d as NSDictionary:
        #if os(Linux)
            let convertedD = d.bridge() // [NSObject : AnyObject]
            for (k, v) in convertedD {
                if let kk = k as? NSString {
                    let components = getQueryComponent("\(key)[\(kk.bridge())]", v)
                    queryComponents += components.query
                    bodyPartComponents += components.body
                } // else consider throw or something
            }
        #else
            break
        #endif
        case let a as [AnyObject]:
              for value in a {
                let components = getQueryComponent(key + "[]", value)
                queryComponents += components.query
                bodyPartComponents += components.body
              }

            case let a as NSArray:
        #if os(Linux)
            for value in a.bridge() {
                let components = getQueryComponent(key + "[]", value)
                queryComponents += components.query
                bodyPartComponents += components.body
            }
        #else
            break
        #endif
        default:
            queryComponents.append((key, "\(value)"))
        }

        return (queryComponents, bodyPartComponents)
    }

    fileprivate static  func getComponents(from dictionary: [String: Any]) -> (query: QueryComponents, body: BodyPartComponents) {
        var query = QueryComponents()
        var body = BodyPartComponents()

        for element in dictionary {
	    let key = element.0
            let components = getQueryComponent(key, element.1)
            query += components.query
            body += components.body
        }

        return (query, body)
    }

    fileprivate static func getQueryComponents(fromDictionary dict: [String: Any]) -> String {
        let query = self.getComponents(from: dict).query
        return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
}
