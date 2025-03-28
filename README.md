# DRACOON Swift SDK

A library to access DRACOON REST API

# Setup

#### Minimum Requirements

Xcode 16

#### Swift Package Manager

Add this line to the dependencies section of your Package.swift:

`.package(name: "crypto_sdk", url: "https://github.com/dracoon/dracoon-swift-sdk", .upToNextMajor(from: "3.0.0"))`

#### Carthage

Add the SDK to your Cartfile:

`github "dracoon/dracoon-swift-sdk.git" ~> 3.0.0`

Then run

`carthage update --platform iOS`

to create a framework or

`carthage update --use-xcframeworks --platform iOS`

to create an xcframework.

#### CocoaPods

Add to your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'
use_frameworks!

target '<Your Target Name>' do
pod 'DRACOON-SDK', '~> 3.0.0'
end
```
Then run

`pod install`

# Example

Too see how OAuth Code Grant flow works with DRACOON SDK, check out the example app in /Example/oauth2.example.
Build it with carthage and make sure to store your configuration to /Example/oauth2.example/oauth2.example/OAuthConfig.swift first.

```swift

// Create authMode

// Use this mode the first time initializing your DracoonClient. authCode is the code from your OAuth2 code flow authorization response.
let authMode = DracoonAuthMode.authorizationCode(clientId: clientId, clientSecret: clientSecret, authorizationCode: authCode)

// If you received your access and refresh tokens use this mode to initialize your DracoonClient.
let token = DracoonTokens(refreshToken: "refreshToken", accessToken: "accessToken", timestamp: Date(), accessTokenValidity: 3600)
let authMode2 = DracoonAuthMode.accessRefreshToken(clientId: "clientId", clientSecret: "clientSecret", tokens: token)

// Create client

let client = DracoonClientImpl(serverUrl: serverUrl, authMode: authMode, getEncryptionPassword: getEncryptionPassword)

// -- Example Requests --

// Nodes

client.nodes.getNodes(parentNodeId: nodeId, limit: nil, offset: nil, completion: { result in
  switch result {
    case .value(let nodeList):
          // ...
    case .error(let error):
          // ...
  }
})

client.nodes.deleteNodes(request: deleteRequest, completion: { result in
  if let error = result.error {
    // ...
  } else {
    // ...
  }
})

// Account

client.account.getUserAccount(completion: { result in
   switch result {
     case .error(let error):
            // ...
     case .value(let user):
            // ...
    }
 })

client.account.setUserKeyPair(password: password, completion: { result in
  switch result {
    case .error(let error):
        // ...
    case .value(let keyPair):
        // ...
    }
})

// Download
client.nodes.downloadFile(nodeId: nodeId, targetUrl: url, callback: callback)

// Upload
client.nodes.uploadFile(uploadId: uploadId, request: createRequest, filePath: filePath, callback: callback, resolutionStrategy: .autorename)

// Shares

client.shares.createDownloadShare(nodeId: idToShare, password: sharePassword, completion: { result in
  switch result {
    case .error(let error):
        // ...
    case .value(let share):
        // ...
    }
})

let request = CreateUploadShareRequest(targetId: self.nodeId, name: self.containerName){$0.expiration = expiration; $0.password = password; $0.notes = notes}
client.shares.requestCreateUploadShare(request: createRequest, completion: { result in
  switch result {
    case .error(let error):
        // ...
    case .value(let share):
        // ...
  }
})

```

# Copyright and License

See [LICENSE](LICENSE)
