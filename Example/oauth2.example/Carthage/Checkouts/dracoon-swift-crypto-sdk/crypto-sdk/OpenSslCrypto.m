//
//  OpenSslCrypto.m
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

#import "OpenSslCrypto.h"

#import <openssl/pem.h>
#import <openssl/rsa.h>
#import <openssl/bn.h>
#import <openssl/rand.h>
#import <openssl/evp.h>
#import <openssl/x509.h>
#import <openssl/pkcs12.h>

#define RSA_KEY_LENGTH 2048
#define SALT_LENGTH 20
#define ITERATION_COUNT 10000

#define AES_KEY_LENGTH 256
#define AES_GCM_IV_LENGTH 12
#define AES_TAG_LENGTH 16

#define BLOCK_SIZE 16

@implementation OpenSslCrypto

// Declare statement expressions
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

- (instancetype)init {
    self = [super init];
    if (self) {
        OPENSSL_init_crypto(OPENSSL_INIT_ADD_ALL_CIPHERS \
                            | OPENSSL_INIT_ADD_ALL_DIGESTS, NULL);
    }
    return self;
}

#pragma mark -
#pragma mark Generate UserKeyPair

- (nullable NSDictionary*)createUserKeyPair:(nonnull NSString*)password {
    
    if (password.length <= 0) {
        return nil;
    }
    
    int success = seed_prng();
    if (!success) {
        return nil;
    }
    
    NSString *publicKey;
    NSString *privateKey;
    char *pwd;
    
    BIGNUM *r = BN_new();
    BN_set_word(r, RSA_F4);
    
    RSA *rsa = RSA_new();
    success = RSA_generate_key_ex(rsa, RSA_KEY_LENGTH, r, NULL);
    if (!success) {
        goto fail_userKey_rsa;
    }
    
    EVP_PKEY* pkey = EVP_PKEY_new();
    // rsa to pkey
    success = EVP_PKEY_set1_RSA(pkey, rsa);
    if (!success) {
        goto fail_userKey_pKey;
    }
    
    BIO *mem_pub = BIO_new(BIO_s_mem());
    success = PEM_write_bio_RSA_PUBKEY(mem_pub, rsa);
    if (!success) {
        goto fail_userKey_pub;
    }
    
    // Encrypt private key
    
    BIO *mem_pr = BIO_new(BIO_s_mem());
    unsigned char* salt = OPENSSL_malloc(SALT_LENGTH);
    
    if (SecRandomCopyBytes(kSecRandomDefault, SALT_LENGTH, salt) != errSecSuccess) {
        goto fail_userKey_salt;
        return nil;
    }
    
    pwd = OPENSSL_malloc(password.length);
    createPasswordBuffer(password, pwd);
    
    PKCS8_PRIV_KEY_INFO* info;
    info = EVP_PKEY2PKCS8(pkey);
    
    X509_SIG* sig;
    int pwdLength = (int)strlen(pwd);
    sig = PKCS8_encrypt(-1, EVP_aes_256_cbc(), pwd, pwdLength, salt, 20, ITERATION_COUNT, info);
    
    success = PEM_write_bio_PKCS8(mem_pr, sig);
    if (!success) {
        goto fail_userKey_pr;
    }
    
    long size_pr = BIO_get_mem_data(mem_pr, NULL);
    unsigned char *private = OPENSSL_malloc(size_pr + 1);
    private[size_pr] = '\0';
    
    long size_pub = BIO_get_mem_data(mem_pub, NULL);
    char *public = OPENSSL_malloc(size_pub + 1);
    public[size_pub] = '\0';
    
    BIO_read(mem_pub, public, (int)size_pub);
    BIO_flush(mem_pub);
    publicKey = [NSString stringWithUTF8String:public];
    
    BIO_read(mem_pr, private, (int)size_pr);
    BIO_flush(mem_pr);
    privateKey = [NSString stringWithUTF8String: (char*)private];
    
    OPENSSL_free(public);
    OPENSSL_free(private);
    
fail_userKey_pr:
    OPENSSL_free(sig);
    OPENSSL_free(info);
    OPENSSL_free(pwd);
    BIO_set_close(mem_pr, BIO_CLOSE);
    BIO_free_all(mem_pr);
fail_userKey_salt:
    OPENSSL_free(salt);
fail_userKey_pub:
    BIO_set_close(mem_pub, BIO_CLOSE);
    BIO_free_all(mem_pub);
fail_userKey_pKey:
    EVP_PKEY_free(pkey);
fail_userKey_rsa:
    BN_free(r);
    RSA_free(rsa);
    
    if (publicKey == NULL || privateKey == NULL) {
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:publicKey forKey:@"public"];
    [result setObject:privateKey forKey:@"private"];
    
    return result;
}

#pragma mark -
#pragma mark Check PrivateKey

- (BOOL)canDecryptPrivateKey:(nonnull NSString*)privateKey withPassword:(nonnull NSString*)password {
    
    if (privateKey.length <= 0 ||
        password.length <= 0) {
        return NO;
    }
    
    RSA* rsaKey = [self decryptPrivateKey:privateKey withPassword:password];
    
    if (rsaKey != nil) {
        RSA_free(rsaKey);
    }
    
    return rsaKey != nil;
}

- (nullable RSA*)decryptPrivateKey:(NSString*)privateKey withPassword:(NSString*) password {
    
    if (privateKey.length <= 0 ||
        password.length <= 0) {
        return nil;
    }
    
    const char *encryptedPrivateKey = privateKey.UTF8String;
    BIO *bio = BIO_new_mem_buf(encryptedPrivateKey, (int)strlen(encryptedPrivateKey));
    
    [[NSThread currentThread] threadDictionary][passwordKey] = password;
    RSA *rsaKey = PEM_read_bio_RSAPrivateKey(bio, NULL, pass_cb, NULL);
    [[NSThread currentThread] threadDictionary][passwordKey] = NULL;
    
    BIO_set_close(bio, BIO_CLOSE);
    BIO_free_all(bio);
    
    return rsaKey;
}

#pragma mark -
#pragma mark Create FileKey

- (nullable NSString*)createFileKey {
    
    int success = seed_prng();
    if (!success) {
        return nil;
    }
    
    int keyBytesLength = AES_KEY_LENGTH/8;
    unsigned char keyBuffer[keyBytesLength];
    success = RAND_bytes(keyBuffer, keyBytesLength);
    if (!success) {
        return nil;
    }
    
    NSData *keyData = [[NSData alloc] initWithBytes:keyBuffer length:keyBytesLength];
    NSString *keyString = [keyData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    return keyString;
}

- (nullable NSString*)createInitializationVector {
    
    char *ivBuffer = OPENSSL_malloc(AES_GCM_IV_LENGTH);
    
    if (SecRandomCopyBytes(kSecRandomDefault, AES_GCM_IV_LENGTH, ivBuffer ) != errSecSuccess) {
        OPENSSL_free(ivBuffer);
        return nil;
    }
    
    NSData *ivData = [[NSData alloc] initWithBytes:ivBuffer length: AES_GCM_IV_LENGTH];
    NSString *iv = [ivData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    OPENSSL_free(ivBuffer);
    
    return iv;
}

#pragma mark -
#pragma mark Encrypt File

- (nullable NSValue*)initializeEncryptionCipher:(nonnull NSString*)fileKey
                                         vector:(nonnull NSString*)vector {
    
    if (fileKey.length <= 0 ||
        vector.length <= 0) {
        return nil;
    }
    
    const char *utfFileKey = fileKey.UTF8String;
    const char *initializationVector = vector.UTF8String;
    
    unsigned char *utfFileKeyBuffer = base64_toByte(utfFileKey, NULL);
    unsigned char *initializationVectorBuffer = base64_toByte(initializationVector, NULL);
    
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    
    if (ctx == NULL) {
        free(utfFileKeyBuffer);
        free(initializationVectorBuffer);
        return nil;
    }
    
    int success;
    
    success = EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, utfFileKeyBuffer, initializationVectorBuffer);
    free(utfFileKeyBuffer);
    free(initializationVectorBuffer);
    if (!success) {
        EVP_CIPHER_CTX_free(ctx);
        return nil;
    }
    
    EVP_CIPHER_CTX_set_padding(ctx, 0);
    
    NSValue *cipher = [NSValue valueWithPointer: ctx];
    
    return cipher;
}

- (nullable NSData*)encryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)cipher
                         fileKey:(nonnull NSString*)fileKey {
    
    if (fileData.length <= 0 ||
        fileKey.length <= 0 ) {
        return nil;
    }
    
    EVP_CIPHER_CTX* ctx = [cipher pointerValue];
    
    if (ctx == NULL) {
        return nil;
    }
    
    int inputFileBytes = (int)fileData.length;
    NSMutableData *encryptedData = [NSMutableData data];
    int position = 0;
    int success;
    unsigned char outputBuffer[BLOCK_SIZE];
    unsigned char inputBuffer[BLOCK_SIZE];
    while (position < inputFileBytes) {
        int length = MIN(BLOCK_SIZE, (int)fileData.length - position);
        [fileData getBytes:inputBuffer range:NSMakeRange(position, length)];
        
        int writtenBytes;
        success = EVP_EncryptUpdate(ctx, outputBuffer, &writtenBytes, inputBuffer, length);
        if (!success) {
            EVP_CIPHER_CTX_free(ctx);
            return nil;
        }
        
        [encryptedData appendBytes:outputBuffer length:writtenBytes];
        position += length;
    }
    
    return encryptedData;
}

- (nullable NSString*)finalizeEncryption:(nonnull NSValue*)cipher {
    
    EVP_CIPHER_CTX* ctx = [cipher pointerValue];
    
    if (ctx == NULL) {
        return nil;
    }
    unsigned char* outs = malloc(BLOCK_SIZE);
    int out_len = 0;
    int success = EVP_EncryptFinal_ex(ctx, outs, &out_len);
    if (!success) {
        EVP_CIPHER_CTX_free(ctx);
        free(outs);
        return nil;
    }
    
    unsigned char tagBuffer[AES_TAG_LENGTH];
    success = EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, AES_TAG_LENGTH, tagBuffer);
    if (!success) {
        EVP_CIPHER_CTX_free(ctx);
        free(outs);
        return nil;
    }
    
    NSData *tagData = [[NSData alloc] initWithBytes:tagBuffer length: AES_TAG_LENGTH];
    NSString *tag = [tagData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    EVP_CIPHER_CTX_free(ctx);
    free(outs);
    
    return tag;
}

#pragma mark -
#pragma mark Decrypt File

- (nullable NSValue*)initializeDecryptionCipher:(nonnull NSString*)fileKey
                                            tag:(nonnull NSString*)tagString
                                         vector:(nonnull NSString*)vector {
    
    if (fileKey.length <= 0 ||
        tagString.length <= 0 ||
        vector.length <= 0) {
        return nil;
    }
    
    const char* decryptedFileKey = fileKey.UTF8String;
    const char* tag = tagString.UTF8String;
    const char* initializationVector = vector.UTF8String;
    
    unsigned char *decryptedFileKeyBuffer = base64_toByte(decryptedFileKey, NULL);
    unsigned char *initializationVectorBuffer = base64_toByte(initializationVector, NULL);
    unsigned char *tagBuffer = base64_toByte(tag, NULL);
    
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    
    if (ctx == NULL) {
        free(decryptedFileKeyBuffer);
        free(initializationVectorBuffer);
        free(tagBuffer);
        return nil;
    }
    
    int success;
    
    success = EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, decryptedFileKeyBuffer, initializationVectorBuffer);
    free(decryptedFileKeyBuffer);
    free(initializationVectorBuffer);
    if (!success) {
        free(tagBuffer);
        EVP_CIPHER_CTX_free(ctx);
        return nil;
    }
    
    EVP_CIPHER_CTX_set_padding(ctx, 0);
    
    success = EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, AES_TAG_LENGTH, tagBuffer);
    free(tagBuffer);
    if (!success) {
        EVP_CIPHER_CTX_free(ctx);
        return nil;
    }
    
    NSValue *cipher = [NSValue valueWithPointer: ctx];
    
    return cipher;
}

- (nullable NSData*)decryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)cipher {
    
    if (fileData.length <= 0) {
        return nil;
    }
    
    EVP_CIPHER_CTX* ctx = [cipher pointerValue];
    
    if (ctx == NULL) {
        return nil;
    }
    
    int success;
    long outputFileBytes = fileData.length;
    
    NSMutableData *decData = [NSMutableData data];
    
    int position = 0;
    unsigned char outputBuffer[BLOCK_SIZE];
    unsigned char inputBuffer[BLOCK_SIZE];
    int writtenBytes = 0;
    while (position < outputFileBytes) {
        int length = MIN(BLOCK_SIZE, (int)fileData.length - position);
        [fileData getBytes:inputBuffer range:NSMakeRange(position, length)];
        
        success = EVP_DecryptUpdate(ctx, outputBuffer, &writtenBytes, inputBuffer, length);
        if (!success) {
            EVP_CIPHER_CTX_free(ctx);
            return nil;
        }
        
        [decData appendBytes:outputBuffer length:writtenBytes];
        position += writtenBytes;
    }
    
    return decData;
}

- (BOOL)finalizeDecryption:(nonnull NSValue*)cipher {
    
    EVP_CIPHER_CTX* ctx = [cipher pointerValue];
    
    if (ctx == NULL) {
        return 0;
    }
    
    int size;
    int success = EVP_DecryptFinal_ex(ctx, NULL, &size);
    
    EVP_CIPHER_CTX_free(ctx);
    
    return (BOOL)success;
}

#pragma mark -
#pragma mark Encrypt FileKey

- (nullable NSString *)encryptFileKey:(nonnull NSString*)fileKey
                            publicKey:(nonnull NSString*)publicKey {
    
    if (fileKey.length <= 0 ||
        publicKey.length <= 0) {
        return nil;
    }
    
    RSA *rsaKey = [self loadPublicKey:publicKey];
    
    if (rsaKey == nil) {
        return nil;
    }
    
    const char *decryptedFileKey = fileKey.UTF8String;
    int decryptedFileKeyBufferLength;
    
    unsigned char *decryptedFileKeyBuffer = base64_toByte(decryptedFileKey, &decryptedFileKeyBufferLength);
    unsigned char *encryptedFileKeyBuffer = (unsigned char*)malloc(AES_KEY_LENGTH) ;
    unsigned char *paddedResult = (unsigned char*)malloc(AES_KEY_LENGTH) ;
    
    int success = RSA_padding_add_PKCS1_OAEP_mgf1(paddedResult, AES_KEY_LENGTH, decryptedFileKeyBuffer, decryptedFileKeyBufferLength, NULL, 0, EVP_sha256(), EVP_sha1());
    
    if (!success) {
        free(encryptedFileKeyBuffer);
        free(decryptedFileKeyBuffer);
        free(paddedResult);
        return nil;
    }
    
    int bytes = RSA_public_encrypt(AES_KEY_LENGTH, paddedResult, encryptedFileKeyBuffer, rsaKey, RSA_NO_PADDING);
    
    RSA_free(rsaKey);
    free(decryptedFileKeyBuffer);
    free(paddedResult);
    
    if (bytes != AES_KEY_LENGTH) {
        free(encryptedFileKeyBuffer);
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:encryptedFileKeyBuffer length:bytes];
    NSString *encryptedFileKey = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    free(encryptedFileKeyBuffer);
    
    return encryptedFileKey;
}

- (nullable RSA*)loadPublicKey:(NSString *)publicKey {
    
    const char *utfPublicKey = publicKey.UTF8String;
    BIO *bio = BIO_new_mem_buf(utfPublicKey, (int)strlen(utfPublicKey));
    RSA *rsaKey = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    
    BIO_set_close(bio, BIO_CLOSE);
    BIO_free_all(bio);
    
    return rsaKey;
}

#pragma mark -
#pragma mark Decrypt FileKey

- (nullable NSString*)decryptFileKey:(nonnull NSString*)fileKey
                          privateKey:(nonnull NSString*)privateKey
                            password:(nonnull NSString*)password {
    
    if (fileKey.length <= 0 ||
        privateKey.length <= 0 ||
        password.length <= 0) {
        return nil;
    }
    
    RSA* rsaKey = [self decryptPrivateKey:privateKey withPassword:password];
    
    if (rsaKey == nil) {
        return nil;
    }
    
    NSData* data;
    NSString* decryptedFileKey;
    
    const char *encryptedFileKey = fileKey.UTF8String;
    int encryptedFileKeyBufferLength;
    unsigned char *encryptedFileKeyBuffer = base64_toByte(encryptedFileKey, &encryptedFileKeyBufferLength);
    
    // Decrypt FileKey using EVP_PKEY API
    EVP_PKEY *pkey = EVP_PKEY_new();
    
    // Set key reference to rsaKey
    int success = (EVP_PKEY_set1_RSA(pkey, rsaKey));
    if (!success) {
        goto fail_decrypt_fileKey_pKey;
    }
    
    EVP_PKEY_CTX *ctx = EVP_PKEY_CTX_new(pkey,  NULL);
    if (!ctx) {
        goto fail_decrypt_fileKey_pKey;
    }
    
    // Init decryption context
    success = (EVP_PKEY_decrypt_init(ctx) &&
               EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING) &&
               EVP_PKEY_CTX_set_rsa_oaep_md(ctx, EVP_sha256()) &&
               EVP_PKEY_CTX_set_rsa_mgf1_md(ctx, EVP_sha1()));
    if (!success) {
        goto fail_decrypt_fileKey_ctx;
    }
    
    // Determine buffer length
    size_t decryptedFileKeyBufferLength;
    success = EVP_PKEY_decrypt(ctx, NULL, &decryptedFileKeyBufferLength, encryptedFileKeyBuffer, encryptedFileKeyBufferLength);
    if (!success) {
        goto fail_decrypt_fileKey_ctx;
    }
    
    // Perform decryption operation
    unsigned char *decryptedFileKeyBuffer = malloc(decryptedFileKeyBufferLength);
    success = EVP_PKEY_decrypt(ctx, decryptedFileKeyBuffer, &decryptedFileKeyBufferLength, encryptedFileKeyBuffer, encryptedFileKeyBufferLength);
    if (!success) {
        goto fail_decrypt_fileKey_decryption;
    }
    
    data = [[NSData alloc] initWithBytes:decryptedFileKeyBuffer length:decryptedFileKeyBufferLength];
    decryptedFileKey = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
fail_decrypt_fileKey_decryption:
    free(decryptedFileKeyBuffer);
fail_decrypt_fileKey_ctx:
    EVP_PKEY_CTX_free(ctx);
fail_decrypt_fileKey_pKey:
    RSA_free(rsaKey);
    EVP_PKEY_free(pkey);
    free(encryptedFileKeyBuffer);
    
    if (decryptedFileKey == NULL) {
        return nil;
    }
    
    return decryptedFileKey;
}

#pragma mark -
#pragma mark Encrypting utilities

int seed_prng(void);
int seed_prng() {
    
    int bytesToSeed = 256;
    
    char *buffer = malloc(bytesToSeed);
    if (SecRandomCopyBytes(kSecRandomDefault, bytesToSeed, buffer) != errSecSuccess) {
        free(buffer);
        return 0;
    }
    RAND_seed(buffer, bytesToSeed);
    
    int status = RAND_status();
    free(buffer);
    return status;
}

static NSString* passwordKey = @"OpenSslPasswordKey";

int pass_cb(char *buf, int size, int rwflag, void *u);

int pass_cb(char *buf, int size, int rwflag, void *u) {
    NSString* passwordString = [[NSThread currentThread] threadDictionary][passwordKey];
    int length = (int)passwordString.length;
    
    char bytes[length];
    createPasswordBuffer(passwordString, bytes);
    
    memcpy(buf, bytes, length);
    
    return length;
}

void createPasswordBuffer(NSString *str, char* bytes);

void createPasswordBuffer(NSString *str, char* bytes) {
    // be compatible to Bouncycastle PKCS5PasswordToBytes()
    int length = (int)str.length;
    unichar buffer[length];
    
    [str getCharacters:buffer range:NSMakeRange(0, length)];
    
    for (int i = 0; i < length; i++) {
        bytes[i] = buffer[i];
    }
}

#pragma mark -
#pragma mark Helper

unsigned char *base64_toByte(const char *input, int *length);

unsigned char *base64_toByte(const char *input, int *length) {
    NSString* inputString = [NSString stringWithCString:input encoding:NSUTF8StringEncoding];
    NSData* data = [[NSData alloc] initWithBase64EncodedString:inputString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    unsigned char *output = (unsigned char *)malloc(data.length);
    memcpy(output, data.bytes, data.length);
    
    if (length != NULL) {
        *length = (int)data.length;
    }
    
    return output;
}

#pragma GCC diagnostic pop

@end

