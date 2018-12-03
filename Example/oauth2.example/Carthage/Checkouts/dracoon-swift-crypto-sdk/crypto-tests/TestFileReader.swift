//
//  TestFileReader.swift
//  crypto-tests
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

@testable import crypto_sdk

class TestFileReader {
    
    class TestKey {
        var plainFileKey: PlainFileKey?
        var encryptedFileKey: EncryptedFileKey?
        
        var privateKey: UserPrivateKey?
        var publicKey: UserPublicKey?
    }
    
    // MARK: Read test file keys
    
    func readPlainFileKey(fileName: String) -> PlainFileKey? {
        guard let fileKey = readFileKey(fileName: fileName, plain: true) else {
            return nil
        }
        return fileKey.plainFileKey
    }
    
    func readEncryptedFileKey(fileName: String) -> EncryptedFileKey? {
        guard let fileKey = readFileKey(fileName: fileName, plain: false) else {
            return nil
        }
        return fileKey.encryptedFileKey
    }
    
    fileprivate func readFileKey(fileName: String, plain: Bool) -> TestKey? {
        guard let url = getPath(fileName: fileName) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let fileKeyJson = json as? Dictionary<String, String>,
                let key = fileKeyJson["key"], let version = fileKeyJson["version"],
                let iv = fileKeyJson["iv"], let tag = fileKeyJson["tag"] {
                let fileKey = TestKey()
                if plain {
                    let plainKey = PlainFileKey(key: key, version: version)
                    plainKey.iv = iv
                    plainKey.tag = tag
                    fileKey.plainFileKey = plainKey
                } else {
                    let encKey = EncryptedFileKey(key: key, version: version, iv: iv, tag: tag)
                    fileKey.encryptedFileKey = encKey
                }
                
                return fileKey
            }
        } catch {}
        return nil
    }
    
    // MARK: Read test user keys
    
    func readPublicKey(fileName: String) -> UserPublicKey? {
        guard let userKey = readUserKey(fileName: fileName, isPublicKey: true) else {
            return nil
        }
        return userKey.publicKey
    }
    
    func readPrivateKey(fileName: String) -> UserPrivateKey? {
        guard let userKey = readUserKey(fileName: fileName, isPublicKey: false) else {
            return nil
        }
        return userKey.privateKey
    }
    
    fileprivate func readUserKey(fileName: String, isPublicKey: Bool) -> TestKey? {
        guard let url = getPath(fileName: fileName) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let userKeyJson = json as? Dictionary<String, String> {
                let userKey = TestKey()
                if isPublicKey {
                    guard let publicKey = userKeyJson["publicKey"], let version = userKeyJson["version"] else {
                        return nil
                    }
                    let publicKeyContainer = UserPublicKey(publicKey: publicKey, version: version)
                    userKey.publicKey = publicKeyContainer
                } else {
                    guard let privateKey = userKeyJson["privateKey"], let version = userKeyJson["version"] else {
                        return nil
                    }
                    let privateKeyContainer = UserPrivateKey(privateKey: privateKey, version: version)
                    userKey.privateKey = privateKeyContainer
                }
                return userKey
            }
        } catch {}
        return nil
    }
    
    // MARK: Read file
    
    func readFile(fileName: String) -> Data? {
        guard let url = getPath(fileName: fileName) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {}
        return nil
    }
    
    func writeFile(data: Data) -> URL {
        let path = getPath(fileName: "encrypted")
        FileManager.default.createFile(atPath: path!.path, contents: nil, attributes: nil)
        do {
            try data.write(to: path!)
        } catch {
            print(error.localizedDescription)
        }
        return path!
    }
    
    func readFileContent(fileName: String) -> String? {
        guard let url = getPath(fileName: fileName) else {
            return nil
        }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content
        } catch {}
        return nil
    }
    
    fileprivate func getPath(fileName: String) -> URL? {
        let bundle = Bundle(for: TestFileReader.self)
        guard let url = bundle.resourceURL else {
            return nil
        }
        let path = url.appendingPathComponent(fileName)
        return path
    }
}
