//
//  SymmetricKey+extensions.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import CryptoKit
import Foundation

extension SymmetricKey {
    init?(base64EncodedString: String) {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            return nil
        }

        self.init(data: data)
    }
    
    func base64Encoded() -> String {
        return self.withUnsafeBytes { body in
            Data(body).base64EncodedString()
        }
    }
}
