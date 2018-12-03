
import crypto_sdk

let crypto = Crypto()
let bufferSize = 200 * 1024

// MARK: Example - Encrypt data

func encryptData(fileKey: PlainFileKey, plainData: Data) throws -> Data {
    let encryptionCipher = try crypto.createEncryptionCipher(fileKey: fileKey)
    let inputStream = InputStream(data: plainData)
    var encryptedData = Data()
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    inputStream.open()
    defer {
        buffer.deallocate()
        inputStream.close()
    }
    
    while inputStream.hasBytesAvailable {
        let read = inputStream.read(buffer, maxLength: bufferSize)
        if read > 0 {
            var plainData = Data()
            plainData.append(buffer, count: read)
            let encData = try encryptionCipher.processBlock(fileData: plainData)
            encryptedData.append(encData)
        } else if let error = inputStream.streamError {
            throw error
        }
    }
    try encryptionCipher.doFinal()
    
    return encryptedData
}

// MARK: Example - Decrypt data

func decryptData(fileKey: PlainFileKey, encryptedData: Data) throws -> Data {
    let decryptionCipher = try crypto.createDecryptionCipher(fileKey: fileKey)
    let inputStream = InputStream(data: encryptedData)
    var decryptedData = Data()
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    inputStream.open()
    defer {
        buffer.deallocate()
        inputStream.close()
    }
    
    while inputStream.hasBytesAvailable {
        let read = inputStream.read(buffer, maxLength: bufferSize)
        if read > 0 {
            var encData = Data()
            encData.append(buffer, count: read)
            let plainData = try decryptionCipher.processBlock(fileData: encData)
            decryptedData.append(plainData)
        } else if let error = inputStream.streamError {
            throw error
        }
    }
    try decryptionCipher.doFinal()
    
    return decryptedData
}

// MARK: Function calls

let plainText = "TestABCDEFGH 123\nTestIJKLMNOP 456\nTestQRSTUVWX 789"
let data = plainText.data(using: .utf8)
do {
    let password = "correcthorsebatterystaple"
    let userKeyPair = try crypto.generateUserKeyPair(password: password)
    print("publicKey \(userKeyPair.publicKeyContainer.publicKey)")
    print("privateKey \(userKeyPair.privateKeyContainer.privateKey)")
    
    let plainFileKey = try crypto.generateFileKey()
    print("plainFileKey \(plainFileKey.key)")
    
    let encryptedData = try encryptData(fileKey: plainFileKey, plainData: data!)
    let plainData = try decryptData(fileKey: plainFileKey, encryptedData: encryptedData)
    
    let decryptedString = String(data: plainData, encoding: .utf8)
    print("\(String(describing: decryptedString))")
    
    if data == plainData {
        print("same data!")
    }
    
    let encryptedKey = try crypto.encryptFileKey(fileKey: plainFileKey, publicKey: userKeyPair.publicKeyContainer)
    let decryptedKey = try crypto.decryptFileKey(fileKey: encryptedKey, privateKey: userKeyPair.privateKeyContainer, password: password)
    print("decryptedKey \(decryptedKey.key)")
} catch {
    print(error)
}
