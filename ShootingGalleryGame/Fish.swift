//
//  Fish.swift
//  ShootingGalleryGame
//
//  Created by Helder on 06/08/20.
//  Copyright © 2020 Helder de Melo Sérvio Filho. All rights reserved.
//

import SpriteKit

enum fishType {
    case smallGood
    case mediumGood
    case bigGood
    case smallBad
    case mediumBad
    case bigBad
    case rare
}

class Fish: SKSpriteNode {
    var type: fishType?
}
