import PackageDescription

let package = Package(
    name: "KituraRequest",
    dependencies: [
            .Package(url: "https://github.com/IBM-Swift/Kitura-net.git", majorVersion: 1)
        ]
)
