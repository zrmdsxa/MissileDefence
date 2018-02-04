//
//  Building.swift
//  MissileDefence
//
//  Created by Nue on 2017-06-21.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit

class Building: SKSpriteNode {
    
    var hp: Int = 3
    
    //run sound in parent
    static let soundBigExplosion = SKAction.playSoundFileNamed("BigExplosion.wav",waitForCompletion: false)
    
    func hitBuilding(){
        hp -= 1
        if hp <= 0 {
            
            destroyBuilding()
        }
    }
    
    func destroyBuilding(){
        parent!.run(Building.soundBigExplosion)
        parent!.addChild(createExplosion(position: position, intensity: 4.0))
        
        for child in children{
            child.removeFromParent()
        }
        
        let destroyed = SKSpriteNode(fileNamed: "DestroyedBuilding")!.childNode(withName: "DestroyedBuilding")!
        destroyed.move(toParent: parent!)
        destroyed.position = CGPoint.zero
        destroyed.zPosition = 0
        removeFromParent()
    }

}
