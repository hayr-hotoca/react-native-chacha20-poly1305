import Foundation
import CryptoKit

enum CryptoError: Error {
    case runtimeError(String)
}

@available(iOS 13.0, *)
@objc(Chacha20Poly1305)
class Chacha20Poly1305: NSObject {
    func encryptData(plainData: Data, key: Data) throws -> ChaChaPoly.SealedBox {
        let skey = SymmetricKey(data: key)
        return try ChaChaPoly.seal(plainData, using: skey)
    }
    
    func decryptData(cipherData: Data, keyData: Data, nonceData: Data, tagData: Data) throws -> Data {
        let skey = SymmetricKey(data: keyData)
        let sealedBox = try ChaChaPoly.SealedBox(nonce: ChaChaPoly.Nonce(data: nonceData),
                                               ciphertext: cipherData,
                                               tag: tagData)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: skey)
        return decryptedData
    }

    @objc(encrypt:withKey:keyEncoding:outputEncoding:withResolver:withRejecter:)
    func encrypt(plainText: String, key: String, keyEncoding: String, outputEncoding: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        do {
            if (keyEncoding != "base64" && keyEncoding != "hex") {
                reject("Input encoding eror", "Input key encoding should be in 'base64' or 'hex'", nil)
            }

            if (outputEncoding != "base64" && outputEncoding != "hex") {
                reject("Output encoding eror", "Output encoding should be in 'base64' or 'hex'", nil)
            }

            let keyData = keyEncoding == "base64" ? Data(base64Encoded: key)! : Data(hexString: key)!
            let plainData = plainText.data(using: .utf8)!
            let sealed = try self.encryptData(plainData: plainData, key: keyData)

            let encrypted = outputEncoding == "base64" ? sealed.ciphertext.base64EncodedString() : sealed.ciphertext.hexadecimal
            let nonce = outputEncoding == "base64" ? sealed.nonce.withUnsafeBytes {
                Data(Array($0)).base64EncodedString()
            } : sealed.nonce.withUnsafeBytes {
                Data(Array($0)).hexadecimal
            }
            let tag = outputEncoding == "base64" ? sealed.tag.base64EncodedString() : sealed.tag.hexadecimal
            
            let response: [String: String] = [
                "nonce": nonce,
                "tag": tag,
                "encrypted": encrypted
            ]
            resolve(response)
            
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("EncryptionError", "Failed to encrypt: " + error.localizedDescription, error)
        }
    }
    
    @objc(decrypt:withKey:nonce:tag:inputEncoding:withResolver:withRejecter:)
    func decrypt(encrypted: String, key: String, nonce: String, tag: String, inputEncoding: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        do {
            if (inputEncoding != "base64" && inputEncoding != "hex") {
                reject("Input encoding eror", "Input key encoding should be in 'base64' or 'hex'", nil)
            }

            let cipherData = inputEncoding == "base64" ? Data(base64Encoded: encrypted)! : Data(hexString: encrypted)!
            let keyData = inputEncoding == "base64" ? Data(base64Encoded: key)! : Data(hexString: key)!
            let nonceData = inputEncoding == "base64" ? Data(base64Encoded: nonce)! : Data(hexString: nonce)!
            let tagData = inputEncoding == "base64" ? Data(base64Encoded: tag)! : Data(hexString: tag)!
            let decryptedData = try decryptData(cipherData: cipherData, keyData: keyData, nonceData: nonceData, tagData: tagData)
            
            resolve(String(decoding: decryptedData, as: UTF8.self))
            
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("EncryptionError", "Failed to decrypt: " + error.localizedDescription, error)
        }
    }
}
