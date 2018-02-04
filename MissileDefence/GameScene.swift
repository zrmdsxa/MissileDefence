//
//  GameScene.swift
//  MissileDefence
//
//  Created by Nue on 2017-06-21.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit

protocol EventListenerNode{
    func didMoveToScene()
}

enum GameState: Int {
    case initial = 0, start, play, win, lose, wait
}

struct PhysicsCategory {
    static let None:    UInt32 = 0
    static let All:     UInt32 = 0xFFFFFFFF
    static let Edge:    UInt32 = 0b1        //1
    static let Player:  UInt32 = 0b10       //2
    static let Destroy: UInt32 = 0b100      //4
    static let Bullet:  UInt32 = 0b1000     //8
    static let Building:    UInt32 = 0b10000    //16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bullet : SKSpriteNode!
    var missile: SKSpriteNode!
    
    var moveArea: CGRect = CGRect()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var player : PlayerNode!
    var isFiring : Bool = false
    var reloadTime: TimeInterval = 0.118
    var newBullet: TimeInterval = 0
    let soundAACannon = SKAudioNode(fileNamed: "aacannon.wav")
    
    var nextMissile: TimeInterval = 0.9
    var newMissile: TimeInterval = 0
    var missileSpeed: CGFloat = 400.0
    let missileTrail = thrusterTrail(intensity: 1.0)
    
    var level: Int = 1
    var missileHP: CGFloat = 2.0
    var nextLevel: Int = 20
    var killsNeeded: Int = 20
    
    
    var gameState: GameState = .initial{
        didSet{
            hud.updateGameState(from:oldValue, to: gameState)
            print("gameState Changed from \(oldValue) to \(gameState)")
        }
    }

    var hud = HUD()
    
    var background : SKSpriteNode!

    func debugDrawPlayableArea(){
        //debug areas
        let width:CGFloat = 2048.0
        let height:CGFloat = 1536.0
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = width / maxAspectRatio
        let playableMargin = (height-playableHeight)/2.0
        
        let playableRect = CGRect(x: 0, y: playableMargin, width: width, height: playableHeight)
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        shape.zPosition = 999
        addChild(shape)
        //print("top:\(playableMargin) bottom:\(playableHeight)")

        moveArea = CGRect(x:0, y: playableMargin, width: width, height: 450 )
        
        let path2 = CGMutablePath()
        path2.addRect(moveArea)
        let shape2 = SKShapeNode()
        shape2.path = path2
        shape2.strokeColor = SKColor.blue
        shape2.lineWidth = 4.0
        shape2.zPosition = 999
        addChild(shape2)
    }

    func setupWorldPhysics(){
        let width:CGFloat = 2048.0
        let height:CGFloat = 1536.0
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = width / maxAspectRatio
        let playableMargin = (height-playableHeight)/2.0
        
        moveArea = CGRect(x:0, y: playableMargin, width: width, height: 450 )
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: moveArea)
        physicsWorld.contactDelegate = self

    }
    
    func setupThings(){
        /*
        enumerateChildNodes(withName: "//player_body", using: { node, _ in
            if let p = node as? PlayerNode {
                p.didMoveToScene()
            }
        })
 */
        player = childNode(withName: "//player_body") as! PlayerNode
        player.didMoveToScene()
        bullet = createNode("Bullet")
        missile = createNode("Missile")
        let trail = thrusterTrail(intensity: 1.0)
        trail.particlePosition.y = 100
        missile.addChild(trail)
        
        soundAACannon.autoplayLooped = true
        
        background = childNode(withName: "//background") as! SKSpriteNode
        background.color = UIColor.orange
        
    }
    
    func createNode(_ fileName: String) -> SKSpriteNode{
        let scene = SKScene(fileNamed:fileName)!
        let template = scene.childNode(withName:"SKSpriteNode")
        return template as! SKSpriteNode
    }
    
    func setupHUD(){
        hud.zPosition = 100
        hud.addLevelCounter()
        addChild(hud)
    }
   
    //view is now current scene
    override func didMove(to view: SKView) {
        
        if gameState == .initial {

        

        setupWorldPhysics()
        //debugDrawPlayableArea()
        setupThings()
        setupHUD()
            
        gameState = .start
            
            print("level: \(level)")
            print("missileHP: \(missileHP)")
            print("reloadTime: \(reloadTime)")
            print("nextMissile: \(nextMissile)")
            print("missileSpeed: \(missileSpeed)")
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Destroy ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Bullet:
            //print("missile hit bullet")
            guard let bodyA = contact.bodyA.node else {return}  //make sure this still exists
            guard let bodyB = contact.bodyB.node else {return}  //make sure this still exists
            //print("A:\(contact.bodyA.node)")
            //print("B:\(contact.bodyB.node)")
            let missile = contact.bodyA.categoryBitMask == PhysicsCategory.Destroy ? contact.bodyA.node as! Missile : contact.bodyB.node as! Missile
            missile.hitMissile()
            guard let other = other.node else {return}  //make sure bullet exists then add bullet hit effect and remove bullet
            addChild(createBulletEffect(position: other.position, intensity: 1.0))
            other.removeFromParent()
            
        case PhysicsCategory.Building:
            //print("missile hit building")
            guard let bodyA = contact.bodyA.node else {return}  //make sure this still exists
            guard let bodyB = contact.bodyB.node else {return}  //make sure this still exists
            
            let missile = contact.bodyA.categoryBitMask == PhysicsCategory.Destroy ? contact.bodyA.node as! Missile : contact.bodyB.node as! Missile
            missile.killMissile()
            
            

            let building = contact.bodyA.categoryBitMask == PhysicsCategory.Building ? contact.bodyA.node as! Building : contact.bodyB.node as! Building
            
            building.hitBuilding()
            
            var numBuildings = 0
            enumerateChildNodes(withName: "//Building", using: { node, _ in
                if let b = node as? Building {
                    numBuildings += 1
                }
            })
            
            if numBuildings == 0 {
                lose()
                
            }

            
        case PhysicsCategory.Player:
            guard let bodyA = contact.bodyA.node else {return}  //make sure this still exists
            guard let bodyB = contact.bodyB.node else {return}  //make sure this still exists
            
            let missile = contact.bodyA.categoryBitMask == PhysicsCategory.Destroy ? contact.bodyA.node as! Missile : contact.bodyB.node as! Missile
            missile.killMissile()

            //nothing happens to the player atm
        default:
            break
        }
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        
        if gameState == .play || gameState == .wait {
            //print("sceneposition:\(player.position)")
            player.setClick(target:touch.location(in:self),maxX:moveArea.maxX,minY:moveArea.minY,maxY:moveArea.maxY)
            //print("start firing")
            startFiring()
        }
        switch gameState{
        case .start:
            gameState = .play
            isPaused = false
        case .lose:
            restartGame()
        case .win:
            restartGame()
        default:
            break
        }
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("touchesMoved")
        guard let touch = touches.first else {return}
        
        if gameState == .play || gameState == .wait {
            player.setAim(target:touch.location(in:self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("touchesEnded")
        guard let touch = touches.first else {return}
        if gameState == .play || gameState == .wait {
            stopFiring()
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
        if gameState != .play && gameState != .lose && gameState != .wait {
            isPaused = true
            return
        }
        
        if lastUpdateTime > 0 {
            
            dt = currentTime - lastUpdateTime
            newMissile += dt
            newBullet += dt
            
            player.move(dt:dt)
            player.aimCannon()
            
            if isFiring{
                fireBullet()
            }
            
            if gameState == .wait{
                var numMissiles = 0
                enumerateChildNodes(withName: "//Missile", using: { node, _ in
                    if let m = node as? Missile {
                        numMissiles += 1
                    }
                })
                
                if numMissiles == 0 {
                    gameState = .win
                    
                }
            }
            else{
                
                if newMissile > nextMissile {
                    newMissile = 0
                    spawnMissile()
                    if gameState == .play{                        nextLevel -= 1
                        
                        if nextLevel <= 0 {
                            if level < 11 {
                                
                                
                                level += 1
                                reloadTime -= 0.012
                                nextMissile -= 0.05
                                missileSpeed += 10.0
                                missileHP += 0.60
                                killsNeeded += 1
                                hud.updateLevelCounter(level: level)
                                
                                print("level: \(level)")
                                print("reloadTime: \(reloadTime)")
                                print("nextMissile: \(nextMissile)")
                                print("missileSpeed: \(missileSpeed)")
                                print("missileHP: \(missileHP)")
                                print("killsNeeded: \(killsNeeded)")
                                
                                nextLevel = killsNeeded
                                
                                background.colorBlendFactor += 0.05
                            }
                            if level >= 11 {
                                gameState = .wait
                            }
                        }
                    }
                }
            }
            
            //go through all missiles to check if it reaches bottom of the screen
            enumerateChildNodes(withName: "//Missile", using: { node, _ in
                if let missile = node as? Missile {
                    missile.update()
                }
            })
            
            
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        //update hud
        //check end game

    }
    
    func fireBullet(){
//        print("")
        if newBullet > reloadTime {
            let fireBullet = bullet.copy() as! SKSpriteNode
            //fireBullet.position = player.getRealCannonPos()
            fireBullet.position = player.getCannonEndPos()
            
            //        print("realCannonPos:\(player.getRealCannonPos())")
            //        print("getCannonEnd:\(player.getCannonEndPos())")
            //        print("fireBullet:\(fireBullet.position)")
            
            fireBullet.zRotation = player.getZRotationForBullet()
            //print("\(fireBullet.zRotation)")
            fireBullet.physicsBody?.velocity = player.getVelocityForBullet()
            fireBullet.run(SKAction.removeFromParentAfterDelay(1.5))
            fireBullet.zPosition = 1
            addChild(fireBullet)
            addChild(createBulletEffect(position: fireBullet.position, intensity: 0.6))
            newBullet = 0
        }
    }
  

    
    
    func spawnMissile(){
        let m = missile.copy() as! Missile
        //                                                                         y should be 1650
        m.position = CGPoint(x: CGFloat.random(min:moveArea.minX+50,max:moveArea.maxX-50) , y: 1650)
        m.name = "Missile"
        m.hp = missileHP

        //                                                                         explodes at 300
        let target = CGPoint(x: CGFloat.random(min:moveArea.minX+50,max:moveArea.maxX-50) , y: 300)

        let velocity = CGVector(point: (target-m.position).normalized())
        m.physicsBody?.velocity = velocity * missileSpeed
        
        let angleRad:CGFloat = atan2(target.y - m.position.y,target.x - m.position.x)
        var angleDeg:CGFloat = angleRad * (180/3.14) + 90
        m.zRotation = angleDeg * (CGFloat(Double.pi) / 180)
        
        addChild(m)
        //print("missile added")
    }
    
    func lose(){
        print("game over")
        gameState = .lose
        stopFiring()
    }
    
    func startFiring(){
        isFiring = true
        addChild(soundAACannon)
    }
    
    func stopFiring(){
        isFiring = false
        soundAACannon.removeFromParent()
    }
    
    func restartGame(){
        let newScene = GameScene(fileNamed:"GameScene")
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.flipHorizontal(withDuration: 1.0)
        self.view?.presentScene(newScene!, transition: reveal)
    }
}
