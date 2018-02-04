//
//  BulletEffect.swift
//  MissileDefence
//
//  Created by Nue on 2017-06-30.
//  Copyright © 2017 zzz. All rights reserved.
//

import SpriteKit

func bulletEffect(intensity: CGFloat) -> SKEmitterNode {
    let emitter = SKEmitterNode()
    let particleTexture = SKTexture(imageNamed: "spark")
    
    emitter.zPosition = 1
    //emitter.particlePositionRange(
    emitter.particleTexture = particleTexture
    emitter.particleBirthRate = 10 * intensity
    emitter.numParticlesToEmit = Int(5 * intensity)
    emitter.particleLifetime = 0.4
    emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
    emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
    emitter.particleSpeed = 70 * intensity
    emitter.particleSpeedRange = 10 * intensity
    emitter.particleAlpha = 1.0
    emitter.particleAlphaRange = 0.1
    emitter.particleScale = 0.6
    emitter.particleScaleRange = 0.5
    emitter.particleScaleSpeed = -1.0
    emitter.particleColor = SKColor.yellow
    emitter.particleColorBlendFactor = 1
    emitter.particleBlendMode = SKBlendMode.alpha
    emitter.run(SKAction.removeFromParentAfterDelay(2.0))
    
    return emitter
}

func explosion(intensity: CGFloat) -> SKEmitterNode {
    let emitter = SKEmitterNode()
    let particleTexture = SKTexture(imageNamed: "spark")
    
    emitter.zPosition = 2
    //emitter.particlePositionRange(
    emitter.particleTexture = particleTexture
    emitter.particleBirthRate = 150 * intensity
    emitter.numParticlesToEmit = Int(50 * intensity)
    emitter.particleLifetime = 0.5 * intensity
    emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
    emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
    emitter.particleSpeed = 200 * intensity
    emitter.particleSpeedRange = 50 * intensity
    emitter.particleAlpha = 1.0
    emitter.particleAlphaRange = 0.1
    emitter.particleScale = 0.5 * intensity
    emitter.particleScaleRange = 0.5
    emitter.particleScaleSpeed = -2.0 + (0.2 * intensity)
    //emitter.particleColor = SKColor.orange
    emitter.particleColorBlendFactor = 1
    emitter.particleBlendMode = SKBlendMode.alpha
    emitter.run(SKAction.removeFromParentAfterDelay(2.0))
    
    let sequence = SKKeyframeSequence(capacity: 5)
    sequence.addKeyframeValue(SKColor.white, time: 0)
    sequence.addKeyframeValue(SKColor.yellow,time: 0.10)
    sequence.addKeyframeValue(SKColor.orange,time: 0.20)
    sequence.addKeyframeValue(SKColor.red, time: 0.35)
    sequence.addKeyframeValue(SKColor.black, time: 0.5)
    emitter.particleColorSequence = sequence
    
    return emitter
}

func thrusterTrail(intensity: CGFloat) -> SKEmitterNode {
    let emitter = SKEmitterNode()
    let particleTexture = SKTexture(imageNamed: "spark")
    
    emitter.zPosition = -1
    //emitter.particlePositionRange(
    emitter.particleTexture = particleTexture
    emitter.particleBirthRate = 100 * intensity
    //emitter.numParticlesToEmit = Int(50 * intensity)
    emitter.particleLifetime = 1.0 * intensity
    emitter.emissionAngle = CGFloat(90).degreesToRadians()
    emitter.emissionAngleRange = CGFloat(45.0).degreesToRadians()
    emitter.particleSpeed = 300 * intensity
    emitter.particleSpeedRange = 50 * intensity
    emitter.particleAlpha = 1.0
    emitter.particleAlphaRange = 0.1
    emitter.particleScale = 0.75 * intensity
    emitter.particleScaleRange = 0.5
    emitter.particleScaleSpeed = -1.0
    //emitter.particleColor = SKColor.orange
    emitter.particleColorBlendFactor = 1
    emitter.particleBlendMode = SKBlendMode.alpha
    
    let sequence = SKKeyframeSequence(capacity: 5)
    sequence.addKeyframeValue(SKColor.white, time: 0)
    sequence.addKeyframeValue(SKColor.yellow,time: 0.10)
    sequence.addKeyframeValue(SKColor.orange,time: 0.20)
    sequence.addKeyframeValue(SKColor.red, time: 0.35)
    sequence.addKeyframeValue(SKColor.black, time: 0.5)
    emitter.particleColorSequence = sequence
    
    return emitter
}

func createBulletEffect(position : CGPoint,intensity: CGFloat) -> SKEmitterNode{
    let effect = bulletEffect(intensity:intensity)
    effect.position = position
    effect.zPosition = 0
    return effect
}

func createExplosion(position : CGPoint,intensity: CGFloat) -> SKEmitterNode {
    let blast = explosion(intensity:intensity)
    blast.position = position
    blast.zPosition = 0
    return blast
}
