# DRACOON Swift SDK

A library to access DRACOON REST API

# Setup

#### Minimum Requirements

Xcode 7.3.1 or newer

#### Carthage

Add the SDK and its dependencies to your Cartfile:

`github "dracoon/dracoon-swift-sdk.git" ~> 1.0`
`github "Alamofire/Alamofire" ~> 4.7.3`
`github "dracoon/dracoon-swift-crypto-sdk.git" ~> 1.0.1`

Then run

`carthage update --platform iOS --cache-builds`

To add the frameworks to your project, open it in Xcode, choose the "General" tab in targets settings and add it to "Linked Frameworks and Libraries".

# Example

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
