//
//  Optional+unwrapOrEmpty.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//  Credit: https://stackoverflow.com/a/76200736

extension Optional where Wrapped == String {
    var unwrapOrEmpty: Wrapped {
        self ?? ""
    }
}
