//
//  Mon.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

public class Mon: Decodable {
    public let name: String
    public let imageUrl: String
    
    enum PokeCodingKeys: String, CodingKey {
        case name
        case sprites
    }
    
    enum SpritesCodingKeys: String, CodingKey {
        case fDefault = "front_default"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PokeCodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let sprites = try container.nestedContainer(keyedBy: SpritesCodingKeys.self,
                                                    forKey: .sprites)
        let imageURL = try sprites.decode(String.self, forKey: .fDefault)
        
        self.name = name
        self.imageUrl = imageURL
    }
}
