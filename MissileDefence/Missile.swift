//
//  Missile.swift
//  MissileDefence
//
//  Created by Nue on 2017-06-21.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit

class Missile: SKSpriteNode {
    
    var hp: CGFloat = 1.0
    static let soundBigExplosion = SKAction.playSoundFileNamed("MissileExplosion.wav",waitForCompletion: false)

    
    func hitMissile(){
        hp -= 1
        if hp <= 0 {
            
            removeMissile()
        }
    }
    
    func killMissile(){
        removeMissile()
    }
    
    private func removeMissile(){
        parent!.run(Missile.soundBigExplosion)
        parent!.addChild(createExplosion(position: position, intensity: 2.0))
        physicsBody?.isDynamic = false
        removeFromParent()
    }
    
    func update(){
        
        if position.y < 300 {
            removeMissile()
        }
    }
}
