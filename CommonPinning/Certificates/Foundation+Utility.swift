//
//  Foundation+Utility.swift
//  Created 3/23/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

public extension Data {
    init?(resourceFromBundle name: String, ofType fileType: String) throws {
        let bundle = Bundle(for: Mon.self)
        guard let filePath = bundle.path(forResource: name, ofType: fileType) else {
            return nil
        }
        self = try Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}
