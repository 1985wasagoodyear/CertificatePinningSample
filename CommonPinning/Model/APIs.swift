//
//  APIs.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

public enum APIs {
    public static let baseUrl = "https://pokeapi.co/api/v2/pokemon/"
    public static func with(mon: String) -> URL? {
        URL(string: baseUrl + mon)
    }
}
