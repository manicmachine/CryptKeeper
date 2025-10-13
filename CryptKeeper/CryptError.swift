//
//  CryptError.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import Foundation

struct CryptError: LocalizedError {
    let message: String
    
    init(_ message: String = "An unknown error occurred.") {
        self.message = message
    }
    
    var errorDescription: String? {
        return message
    }
}
