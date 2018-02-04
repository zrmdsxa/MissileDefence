//
//  HUD.swift
//  MissileDefence
//
//  Created by Nue on 2017-07-05.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit

enum HUDSettings{
    static let font = "CourierNewPS-BoldMT"
    static let fontSize: CGFloat = 100
    
}

enum HUDMessages{
    
    static let gameOver = "Game Over"
    static let missileDefense = "Missile Defense"
    static let playAgain = "Tap to Play Again"
    static let tapToStart = "Tap to Start"
    static let youWin = "You win!"
}

class HUD: SKNode{
    
    var levelCounterLabel: SKLabelNode?
    
    func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize){
        let label: SKLabelNode = SKLabelNode(fontNamed: HUDSettings.font)
        label.text = message
        label.name = message
        label.zPosition = 100
        label.fontColor = UIColor.black
        label.fontSize = fontSize
        label.position = position
        addChild(label)
        print("label: \(message)")
    }
    
    private func remove(message:String){
        childNode(withName:message)?.removeFromParent()
    }
    
    func updateGameState(from: GameState, to: GameState) {
        clearUI(gameState:from)
        updateUI(gameState: to)
    }
    
    private func updateUI(gameState: GameState){
        switch gameState{

        case .lose:
            add(message:HUDMessages.gameOver,position: CGPoint(x:1024,y:1050))
            add(message:HUDMessages.playAgain,position: CGPoint(x:1024,y:900))
        case .start:
            add(message: HUDMessages.missileDefense, position: CGPoint(x:1024,y:1050),fontSize: 150)
            add(message: HUDMessages.tapToStart, position: CGPoint(x:1024,y:850))
            
        case .win:
            add(message:HUDMessages.youWin,position: CGPoint(x:1024,y:1050))
            add(message:HUDMessages.playAgain,position: CGPoint(x:1024,y:900))
        default:
            break
        }
    }
    
    private func clearUI(gameState: GameState){
        switch gameState{
        case .lose:
            remove(message:HUDMessages.gameOver)
            remove(message:HUDMessages.playAgain)
        case .start:
            remove(message:HUDMessages.missileDefense)
            remove(message:HUDMessages.tapToStart)
        case .win:
            remove(message:HUDMessages.youWin)
            remove(message:HUDMessages.playAgain)
        default:
            break
        }
    }
    
    func addLevelCounter(){
        
        let position = CGPoint(x: 1024, y: 1300)
        print(position)
        add(message: "LevelCounter", position: position, fontSize: 50)
        levelCounterLabel = childNode(withName: "LevelCounter") as? SKLabelNode
        updateLevelCounter(level: 1)
    }
    
    
    func updateLevelCounter(level: Int){
        var _level = level
        if _level > 10 {
            _level = 10
        }
        let labelText = String("Level: \(_level)")
        levelCounterLabel?.text = labelText
    }
}
