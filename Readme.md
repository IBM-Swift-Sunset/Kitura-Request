Kitura Request
-------------

**Warning: This is work in progress**

A module for sending HTTP requests in [IBM Kitura](https://github.com/IBM-Swift/Kitura) based applications. It wraps KituraNet `ClientRequest` class and exposes a familiar interface known from Alamofire.

TODO:
- [x] !! Add URL parameter encoding
- [x] !! Add JSON parameter encoding 
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

Currently `DEVELOPMENT-SNAPSHOT-2016-05-03-a` toolchain is supported

## Usage
API of KituraRequest should feel familiar as it closely maps the one of [Alamofire](https://github.com/Alamofire/Alamofire).

#### Creating a request
To create a request object simply call

```swift
KituraRequest.request(method: .GET, "https://httpbin.org/get"]
```

#### Request parameters and parameters encoding
You can also create a request with parameters by passing `[String: AnyObject]` dictionary together with encoding method

```swift
KituraRequest.request(method: .POST,
                      "https://httpbin.org/post",
                      parameters: ["foo":"bar"],
                      encoding: .JSON)
```

Currently `.URL` and `.JSON` encoding is supported. `.URL` encodes parameters as URLs query while the latter converts parameters dictionary to JSON and appends it to request's body. When encoding parameters as `.JSON` appropriate Content-Type header is set.


#### Headers
To set headers in the request pass them as `[String: String]` dictionary as shown below:

```swift
KituraRequest.request(method: .GET,
                      "https://httpbin.org/get",
                      headers: ["User-Agent":"Awesome-App"])
```

#### Handling response
Currently there is only one method that you can call to get back the requests response and it returns `NSData`.

```swift
KituraRequest.request(method: .GET, "https://google.com"].response {
  request, response, data, error in
  // do something with data
}
```

## License
This library is licensed under Apache 2.0. For details see license.txt
