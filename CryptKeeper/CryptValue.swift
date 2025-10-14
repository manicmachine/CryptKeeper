//
//  Value.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import Foundation
import Observation

@Observable
class CryptValue: Identifiable, Encodable {
    var id: UUID
    let name: String
    var original: String
    private var _result: String?
    var result: String? {
        get {
            if self._result == nil && self.hasError { return "<Error>" }
            else { return self._result }
        }
        set (newValue) {
            self._result = newValue
        }
    }
    var hasError: Bool = false
    
    init(name: String, original: String, result: String? = nil) {
        self.id = UUID()
        self.name = name
        self.original = original
        self._result = result
    }
}
