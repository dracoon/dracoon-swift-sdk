# DRACOON Swift Crypto SDK

A library which implements the client-side encryption of DRACOON.

# Introduction

Later, a link to the DRACOON client-side encryption white paper will be added here. This document
will describe the client-side encryption in detail.

# Setup

#### Minimum Requirements

Xcode 7.3.1 or newer

#### Build boringSSL

`./build-boringssl.sh`

#### Carthage

Add the SDK to your Cartfile:

`github "dracoon/dracoon-swift-crypto-sdk.git" ~> 1.0`

Then run

`carthage update --platform iOS`

To add the framework to your project, open it in Xcode, choose the "General" tab in targets settings and add it to "Linked Frameworks and Libraries".

# Example

An example playground can be found here: `Example/CryptoSDK.playground`

The example shows the complete encryption workflow, i.e. generate user keypair, validate user
keypair, generate file key, encrypt file key, and finally encrypt and decrypt a file.

```swift
    // --- INITIALIZATION ---
    let crypto = Crypto()
    // Generate key pair
    let userKeyPair = try crypto.generateUserKeyPair(password: USER_PASSWORD)
    // Check key pair
    if !crypto.checkUserKeyPair(keyPair: userKeyPair, password: USER_PASSWORD) {
        ...
    }

    let plainData = plainText.data(using: .utf8)

    ...

    // --- ENCRYPTION ---
    // Generate plain file key
    let plainFileKey = try crypto.generateFileKey()
    // Encrypt blocks
    let encryptionCipher = try crypto.createEncryptionCipher(fileKey: fileKey)
    let encData = try encryptionCipher.processBlock(fileData: plainData)
    try encryptionCipher.doFinal()
    // Encrypt file key
    let encryptedKey = try crypto.encryptFileKey(fileKey: plainFileKey, publicKey: userKeyPair.publicKeyContainer)

    ...

    // --- DECRYPTION ---
    // Decrypt file key
    let decryptedKey = try crypto.decryptFileKey(fileKey: encryptedKey, privateKey: userKeyPair.privateKeyContainer,
      USER_PASSWORD)
    // Decrypt blocks
    let decryptionCipher = try crypto.createDecryptionCipher(fileKey: fileKey)
    let decData = try decryptionCipher.processBlock(fileData: encData)
    try decryptionCipher.doFinal()

    ...
```

# Copyright and License

See [LICENSE](LICENSE)
