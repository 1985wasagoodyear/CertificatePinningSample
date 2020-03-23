//
//  MonError.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

public typealias MonResult = Result<Mon, MonError>

public enum MonError: Error {
    case badName
    case noData
    case error(Error)
    case badParsing(Error)
}
