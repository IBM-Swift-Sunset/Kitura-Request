KituraRequest
-------------

**Warning: This is work in progress**

A module for sending HTTP requests in [IBM Kitura](https://github.com/IBM-Swift/Kitura) based applications. It wraps KituraNet `ClientRequest` class and exposes a familiar interface known from Alamofire.

TODO:
- [x] !! Add URL parameter encoding
- [x] !! Add JSON parameter encoding
- [x] !! Multipart form data parameter encoding
- [x] !! Make tests run on Linux
- [x] !! Write tests to check if resulting ClientRequest is properly initialised
- [x] Add synchronus interface
- [ ] Add async interface
- [x] Write instructions
- [x] Switch back to depend on IBM Kitura-net


## Installation
To install KituraRequest add following line to Dependencies in `Package.json`:

```swift
.Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0)
```

Currently `Swift 3.0 Release` is supported

## Usage
API of KituraRequest should feel familiar as it closely maps the one of [Alamofire](https://github.com/Alamofire/Alamofire).

#### Creating a request
To create a request object simply call

```swift
KituraRequest.request(.GET, "https://httpbin.org/get"]
```

#### Request parameters and parameters encoding
You can also create a request with parameters by passing `[String: Any]` dictionary together with an encoding method:

```swift
KituraRequest.request(.POST,
                      "https://httpbin.org/post",
                      parameters: ["foo":"bar"],
                      encoding: JSONEncoding.default)
```

Currently `URLEncoding`, `JSONEncoding` and `MultipartEncoding` encodings is supported by default.

`URLEncoding` encodes parameters as URLs query.  
`JSONEncoding` converts parameters dictionary to JSON and appends it to request's body.  
`MultipartEncoding` generates multipart http body from passed parameters and appends it to request's body.  
When encoding parameters as `JSONEncoding` or `MultipartEncoding` appropriate Content-Type header is set.  
To create custom parameter encoding extend any class or struct with `Encoding` protocol.


#### Headers
To set headers in the request pass them as `[String: String]` dictionary as shown below:

```swift
KituraRequest.request(.GET,
                      "https://httpbin.org/get",
                      headers: ["User-Agent":"Awesome-App"])
```

#### Handling response
Currently there is only one method that you can call to get back the requests response and it returns `NSData`.

```swift
KituraRequest.request(.GET, "https://google.com"].response {
  request, response, data, error in
  // do something with data
}
```

## License
This library is licensed under Apache 2.0. For details see license.txt
