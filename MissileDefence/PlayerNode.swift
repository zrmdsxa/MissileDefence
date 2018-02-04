//
//  Player.swift
//  MissileDefence
//
//  Created by Nue on 2017-06-21.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit



class PlayerNode: SKSpriteNode {
    
    //dir
    //1 - right
    //-1 - left

    var moveSpeed: CGFloat = 300.0
    var velocity = CGPoint.zero
    
    var dir: Int = 1
    var lastClickMove: CGPoint?
    var lastClickShoot: CGPoint?
    var isMoving = false
    
    
    var gs_Reference: SKNode!
    var cannonNode: SKNode!
    var cannonEnd: SKNode!
    
    var bulletSpeed: CGFloat = 2000.0
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    func didMoveToScene(){
        print("player:did move to scene/aka created")
        zPosition = 50
        
        gs_Reference = parent!.parent!
        cannonNode = childNode(withName: "cannon")
        cannonEnd = cannonNode.childNode(withName: "end")
      
        gs_Reference.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:200.0,height:140.0))
        //print("parentphysicsbody:\(parent!.parent!.physicsBody)")
        
        gs_Reference.physicsBody?.restitution = 1.0
        gs_Reference.physicsBody?.affectedByGravity = false
        gs_Reference.physicsBody?.linearDamping = 0
        gs_Reference.physicsBody?.friction = 0
        gs_Reference.physicsBody?.allowsRotation = false
        
        gs_Reference.physicsBody!.categoryBitMask = PhysicsCategory.Player
        gs_Reference.physicsBody!.collisionBitMask = PhysicsCategory.Edge
        gs_Reference.physicsBody!.contactTestBitMask = PhysicsCategory.Destroy
        
    }
    
    //click somewhere on screen

    func setClick(target:CGPoint, maxX: CGFloat, minY: CGFloat, maxY: CGFloat){
        //print("player:setmove")
        guard let physicsBody = gs_Reference.physicsBody else {return}
        
        setAim(target: target)
        
        if target.y <= maxY {
            lastClickMove = target
            if lastClickMove!.y <= maxY {
                if lastClickMove!.y > maxY - self.size.height * 0.5{
                    lastClickMove!.y = maxY - self.size.height * 0.5
                }
                else if lastClickMove!.y < minY + self.size.height * 0.5 {
                    lastClickMove!.y = minY + self.size.height * 0.5
                }
                if lastClickMove!.x > maxX - self.size.width * 0.5{
                    lastClickMove!.x = maxX - self.size.width * 0.5
                }
                else if lastClickMove!.x < self.size.width * 0.5{
                    lastClickMove!.x = self.size.width * 0.5
                }
                
                //set tank to move
                //print("y:\(lastClickMove!.y)")
                //print("maxy:\(maxY - self.size.height * 0.5)")
                isMoving = true
                
                let newVelocity = (lastClickMove! - parent!.parent!.position).normalized() * moveSpeed
                physicsBody.velocity = CGVector(point:newVelocity)
                //print("player velocity: \(physicsBody.velocity)")
                
                //print(xScale)
                //set direction
                
                if newVelocity.x > 0 && dir != 1 {
                    dir = 1
                    xScale *= -1
                }
                else if newVelocity.x < 0 && dir != -1{
                    dir = -1
                    xScale *= -1
                }
            }
        }
    }
    
    //update auto move func
    func move (dt: TimeInterval){
        //print("player:move \(dt)")
        //
        if isMoving {
            //print("LENGTH:\((lastClickMove! - parent!.parent!.position).length())")
            //print("CHECK:\(moveSpeed * CGFloat(dt))")
            
            if (lastClickMove! - gs_Reference.position).length() <= moveSpeed * CGFloat(dt){
                guard let physicsBody = gs_Reference.physicsBody else {return}
                physicsBody.velocity = CGVector.zero
                isMoving = false
            }
            
        }
        
    }
    //update auto aim cannon
    func aimCannon(){
        guard let lastClickShoot = lastClickShoot else {return}
        
        
        let realCannonPos = getRealCannonPos()
        
        //print("target:\(lastClickShoot)")

        guard lastClickShoot == lastClickShoot else {return}
        
        let angleRad:CGFloat = atan2(lastClickShoot.y - realCannonPos.y,lastClickShoot.x - realCannonPos.x)
        
        var angleDeg:CGFloat = angleRad * (180/3.14) - 90
        if dir == -1 {
            angleDeg *= -1
        }
        
        //print("angleDeg:\(angleDeg)")
        
        cannonNode?.zRotation = angleDeg * (CGFloat(Double.pi) / 180)
        
        //Cannon Aiming Constraints
        
        //vehicle facing right
        //aiming bottom left
        if cannonNode!.zRotation < -180 * (CGFloat(Double.pi) / 180){
            cannonNode?.zRotation = 90 * (CGFloat(Double.pi) / 180)
        }
        //vehicle facing right
        //aiming bottom right
        else if cannonNode!.zRotation < -90 * (CGFloat(Double.pi) / 180){
            cannonNode?.zRotation = -90 * (CGFloat(Double.pi) / 180)
        }
        //vehicle facing left
        //aiming bottom left
        else if cannonNode!.zRotation > 180 * (CGFloat(Double.pi) / 180){
            cannonNode?.zRotation = -90 * (CGFloat(Double.pi) / 180)
        }
        //vehicle facing left
        //aiming botton right
        else if cannonNode!.zRotation > 90 * (CGFloat(Double.pi) / 180){
            cannonNode?.zRotation = 90 * (CGFloat(Double.pi) / 180)
        }
        
        //for tank facing right
        //right = -90
        //up = 0
        //left = 90
        
        
    }
    //for touch drag aiming
    func setAim(target:CGPoint){
        lastClickShoot = target
    }
    
    func getRealCannonPos() -> CGPoint {
        
        let realx : CGFloat = dir == 1 ? -77 : 77
        
        let localCannonPos = CGPoint(x: realx, y:55)
        let realCannonPos = gs_Reference.position + localCannonPos
        
        return realCannonPos
    }
    
    func getCannonEndPos() -> CGPoint {
//        print("to gs:\(cannonEnd.convert(cannonEnd.position,to: gs_Reference))")
//        print("to player:\(cannonEnd.convert(cannonEnd.position,to: cannonNode.parent!))")
        
        let distanceToGun: CGFloat = 0.5 // higher = closer to cannon base
        
        let fixPos = (getRealCannonPos() - (gs_Reference.position + cannonEnd.convert(cannonEnd.position,to: gs_Reference))) * distanceToGun

        return gs_Reference.position + cannonEnd.convert(cannonEnd.position,to: gs_Reference) + fixPos
    }
    
    func getZRotationForBullet() -> CGFloat{
        var zRot: CGFloat
        if dir == 1 {
            zRot = cannonNode.zRotation + (90 * CGFloat(Double.pi)/180)
        }
        else {
            zRot = -cannonNode.zRotation + (90 * CGFloat(Double.pi)/180)
        }
        return zRot
    }
    
    func getVelocityForBullet() -> CGVector{
        let cgpoint = (gs_Reference.position + cannonEnd.convert(cannonEnd.position,to: gs_Reference)) - getRealCannonPos()
        
        let velocity = CGVector(dx: cgpoint.x, dy: cgpoint.y).normalized() * bulletSpeed
        
        return velocity
    }

}
