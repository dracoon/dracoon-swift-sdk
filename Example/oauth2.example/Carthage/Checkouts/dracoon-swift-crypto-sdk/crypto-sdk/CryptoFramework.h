//
//  CryptoFramework.h
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

#ifndef CryptoFramework_h
#define CryptoFramework_h

@protocol CryptoFramework <NSObject>

- (nullable NSDictionary*)createUserKeyPair:(nonnull NSString*)password;

- (BOOL)canDecryptPrivateKey:(nonnull NSString*)privateKey withPassword:(nonnull NSString*)password;

- (nullable NSString*)createFileKey;

- (nullable NSString*)createInitializationVector;

- (nullable NSValue*)initializeEncryptionCipher:(nonnull NSString*)fileKey
                                                vector:(nonnull NSString*)vector;

- (nullable NSData*)encryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)ctx
                         fileKey:(nonnull NSString*)fileKey;

- (nullable NSString*)finalizeEncryption:(nonnull NSValue*)ctx;

- (nullable NSValue*)initializeDecryptionCipher:(nonnull NSString*)fileKey
                                                   tag:(nonnull NSString*)tagString
                                                vector:(nonnull NSString*)vector;

- (nullable NSData*)decryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)ctx;

- (BOOL)finalizeDecryption:(nonnull NSValue*)ctx;

- (nullable NSString*)encryptFileKey:(nonnull NSString*)fileKey
                           publicKey:(nonnull NSString*)publicKey;

- (nullable NSString*)decryptFileKey:(nonnull NSString*)fileKey
                          privateKey:(nonnull NSString*)privateKey
                            password:(nonnull NSString*)password;

@end


#endif /* CryptoFramework_h */
