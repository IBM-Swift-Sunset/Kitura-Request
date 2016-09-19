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
    case couldNotCreateComponentsFromURL
    case couldNotCreateURLFromComponents
    case couldNotCreateMultipart
}

public enum ParameterEncoding {

    public typealias EncodingHandler = (_ request: inout NSMutableURLRequest, _ parameters: Request.Parameters?) throws -> ()

    case url
    case json
    case multipart
    case custom(EncodingHandler)

    func encode(_ request: inout NSMutableURLRequest, parameters: Request.Parameters?) throws {
        guard let parameters = parameters, !parameters.isEmpty else {
            return
        }

        switch self {
        case .url:
            try self.encodeInURL(request: &request, parameters: parameters)
        case .json:
            try self.encodeInJSON(request: &request, parameters: parameters)
        case .multipart:
            try self.encodeInMultipart(request: &request, parameters: parameters)
        case .custom(let closure):
            try closure(&request, parameters)
        }
    }

    private func encodeInURL(request: inout NSMutableURLRequest, parameters: Request.Parameters) throws {
        guard let url = request.url,
            let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
        }

        components.query = ParameterEncoding.getQuery(from: parameters)

        guard let newURL = components.url else {
            throw ParameterEncodingError.couldNotCreateComponentsFromURL // this should never happen
        }

        request.url = newURL
    }

    private func encodeInJSON(request: inout NSMutableURLRequest, parameters: Request.Parameters) throws {
        //for val in parameters {
        let options = JSONSerialization.WritingOptions()
        let data = parameters.count == 1 ?
            try JSONSerialization.data(withJSONObject: parameters[0], options: options) :
            try JSONSerialization.data(withJSONObject: parameters, options: options)
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //}
    }

    private func encodeInMultipart(request: inout NSMutableURLRequest, parameters: Request.Parameters) throws {
        let boundary = BodyBoundary()

        let parameters = ParameterEncoding.getComponents(from: parameters)

        var bodyParameters = parameters.query.flatMap { item -> (key: String, part: BodyPart)? in
            let key = item.0
            let value = item.1

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
                throw ParameterEncodingError.couldNotCreateMultipart
            }

            httpBody.append(bodyBoundary)

            let parameterBody = try bodyPart.part.content(for: bodyPart.key)
            httpBody.append(parameterBody)
        }

        guard let final = boundary.final else {
            throw ParameterEncodingError.couldNotCreateMultipart
        }

        httpBody.append(final)

        request.httpBody = httpBody
        request.setValue("multipart/form-data; boundary=\(boundary.value)", forHTTPHeaderField: "Content-Type")
    }
}

extension ParameterEncoding {

    typealias QueryComponents = [(String, String)]
    typealias BodyPartComponents = [(key: String, part: BodyPart)]
    typealias Components = (query: QueryComponents, body: BodyPartComponents)

    private static func getQueryComponent(_ key: String, _ value: Any) -> Components {
        var queryComponents = QueryComponents()
        var bodyPartComponents = BodyPartComponents()

        switch value {
        case let bodyPart as BodyPart:
            bodyPartComponents += [(key: key, part: bodyPart)]
            break
        case let dictionary as [String: Any]:
            for (valueKey, value) in dictionary {
                let components = getQueryComponent("\(key)[\(valueKey)]", value)
                queryComponents += components.query
                bodyPartComponents += components.body
            }
        case let array as [Any]:
              for value in array {
                let components = getQueryComponent(key + "[]", value)
                queryComponents += components.query
                bodyPartComponents += components.body
              }
        default:
            queryComponents.append((key, "\(value)"))
        }

        return (queryComponents, bodyPartComponents)
    }

    fileprivate static func getComponents(from parameters: Request.Parameters) -> Components {
        var components: Components = (QueryComponents(), BodyPartComponents())

        for dictionary in parameters {
            components = dictionary.reduce(components) { value, element in
                let key = element.0
                let components = getQueryComponent(key, element.1)
                return (value.query + components.query, value.body + components.body)
            }
        }

        return components
    }

    fileprivate static func getQuery(from parameters: Request.Parameters) -> String {
        let query = self.getComponents(from: parameters).query
        return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
}
