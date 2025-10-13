//
//  CryptService.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import CryptoKit
import Foundation

struct CryptService {
    static func generateKey() -> String {
        return SymmetricKey(size: .bits256).base64Encoded()
    }
    
    static func encryptValue(_ value: String, using key: String, with mask: UInt8? = nil) throws -> String {
        guard let symKey = SymmetricKey(base64EncodedString: key) else {
            throw CryptError("Failed to create symmetric key for encryption")
        }
        
        do {
            let data = try ChaChaPoly.seal(value.data(using: .utf8)!, using: symKey).combined
            return data.base64EncodedString()
        } catch {
            throw CryptError("Failed to seal value")
        }
    }
    
    static func decryptValue(_ value: String, using key: String, with mask: UInt8? = nil) throws -> String {
        guard let symKey = SymmetricKey(base64EncodedString: key) else {
            throw CryptError("Failed to create symmetric key for decryption")
        }
        
        guard let data = Data(base64Encoded: value) else {
            throw CryptError("Failed to decode value")
        }
        
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try? ChaChaPoly.open(sealedBox, using: symKey)
        
        guard let data = decryptedData, let val = String(data: data, encoding: .utf8) else {
            throw CryptError("Failed to decrypted data")
        }
        
        return val
    }
    
    static func xorStringToBase64(_ input: String, with key: UInt8) -> String {
        let xored = input.utf8.map { $0 ^ key }
        return Data(xored).base64EncodedString()
    }

    static func decodeXorBase64(_ base64: String, with key: UInt8) -> String {
        guard let data = Data(base64Encoded: base64) else { return "<Error>" }
        let decodedBytes = data.map { $0 ^ key }
        return String(bytes: decodedBytes, encoding: .utf8) ?? "<Error>"
    }
}
