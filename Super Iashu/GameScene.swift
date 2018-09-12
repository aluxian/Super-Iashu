//
//  GameScene.swift
//  Super Iashu
//
//  Created by Alexandru Rosianu on 05/09/2018.
//  Copyright © 2018 AR. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let hero: UInt32 = 0x1 << 0
    static let floor: UInt32 = 0x1 << 1
    static let bad_food: UInt32 = 0x1 << 2
    static let good_food: UInt32 = 0x1 << 3
    static let iashusGravity: UInt32 = 0x1 << 4
    static let cage: UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // sprites
    
    var hbLabel: SKLabelNode!
    var floor: SKTileMapNode!
    var hero: SKSpriteNode!
    var saladAttraction: SKFieldNode!
    
    // keys
    
    var keyState = [UInt16 : Bool]()
    
    override func didMove(to view: SKView) {
        // world setup
        
        run(SKAction.playSoundFileNamed("Sounds/CrankDat.mp3", waitForCompletion: true))
        backgroundColor = NSColor(red: 0.71, green: 0.85, blue: 1, alpha: 1)
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = PhysicsCategory.cage
        physicsBody!.contactTestBitMask = PhysicsCategory.hero
        physicsBody!.collisionBitMask = PhysicsCategory.hero
        
        // gravity
        
        saladAttraction = SKFieldNode.radialGravityField()
        saladAttraction.strength = 50
//        saladAttraction.falloff = -10
        saladAttraction.region = SKRegion(radius: Float(size.height / 2))
        saladAttraction.categoryBitMask = PhysicsCategory.iashusGravity
        
        // floor
        
        let floorTileSet = SKTileSet(named: "Beach")!
        let sandGroup = floorTileSet.tileGroups.first!
        let sandRule = sandGroup.rules.first!
        let tileSize = CGSize(width: 32, height: 32)
        floor = SKTileMapNode(tileSet: floorTileSet, columns: Int(size.width / tileSize.width), rows: 2, tileSize: tileSize)
        floor.position = CGPoint(x: frame.width * 0.5, y: floor.mapSize.height / 2)
        floor.enableAutomapping = false
        
        for j in 0..<floor.numberOfColumns {
            floor.setTileGroup(sandGroup, andTileDefinition: sandRule.tileDefinitions[0], forColumn: j, row: 0)
            floor.setTileGroup(sandGroup, andTileDefinition: sandRule.tileDefinitions[1], forColumn: j, row: 1)
        }
        
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.mapSize)
        floor.physicsBody!.isDynamic = false
        floor.physicsBody!.affectedByGravity = false
        
        floor.physicsBody!.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody!.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.bad_food | PhysicsCategory.good_food
        floor.physicsBody!.collisionBitMask = PhysicsCategory.hero | PhysicsCategory.bad_food | PhysicsCategory.good_food
        floor.physicsBody!.fieldBitMask = 0
        
        // happy bday label
        
        hbLabel = SKLabelNode(fontNamed: "Chalkduster")
        hbLabel.color = .black
        hbLabel.text = "Happy Birthday! 🎉👯‍♀️"
        hbLabel.position = CGPoint(x: size.width / 2, y: size.height / 6 * 5)
        hbLabel.alpha = 0
        
        hbLabel.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ])))
        
        // hero
        
        hero = SKSpriteNode(imageNamed: "hero")
        hero.position = CGPoint(x: 50, y: 100)
        
        hero.xScale = 0.4
        hero.yScale = 0.4
        
        hero.physicsBody = SKPhysicsBody(texture: hero.texture!, alphaThreshold: 0.5, size: hero.size)
        hero.physicsBody!.allowsRotation = false
        hero.physicsBody!.mass = 30
        hero.physicsBody!.linearDamping = 5
        
        hero.physicsBody!.categoryBitMask = PhysicsCategory.hero
        hero.physicsBody!.contactTestBitMask = PhysicsCategory.floor | PhysicsCategory.bad_food | PhysicsCategory.good_food | PhysicsCategory.cage
        hero.physicsBody!.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.bad_food | PhysicsCategory.good_food | PhysicsCategory.cage
        hero.physicsBody!.fieldBitMask = 0
        
        // kufte
        
        let kuftexture = SKTexture(imageNamed: "kufte")
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5, withRange: 3),
            SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in
                let y = arc4random_uniform(UInt32(self.frame.height - 200)) + 100
                
                let kufte = SKSpriteNode(texture: kuftexture)
                kufte.position = CGPoint(x: self.frame.width + 100, y: CGFloat(y))
                
                kufte.xScale = 0.1
                kufte.yScale = 0.1
                
                kufte.physicsBody = SKPhysicsBody(texture: kuftexture, alphaThreshold: 0.5, size: kufte.size)
                kufte.physicsBody!.allowsRotation = false
                kufte.physicsBody!.mass = 0.5
                kufte.physicsBody!.linearDamping = 0.5
                kufte.physicsBody!.friction = 0
                
                kufte.physicsBody!.categoryBitMask = PhysicsCategory.bad_food
                kufte.physicsBody!.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.floor
                kufte.physicsBody!.collisionBitMask = PhysicsCategory.hero | PhysicsCategory.floor
                kufte.physicsBody!.fieldBitMask = 0
                
                let y2 = Double(arc4random_uniform(UInt32(100)) + 200) / 100 / 3
                kufte.run(SKAction.sequence([
                    SKAction.applyImpulse(CGVector(dx: -1000, dy: 1500*y2), duration: 2),
                    SKAction.removeFromParent()
                ]))
                
                self.addChild(kufte)
            }),
            SKAction.wait(forDuration: 2)
        ])))
        
        // salad
        
        let saladTexture = SKTexture(imageNamed: "salad")
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5, withRange: 3),
            SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in
                let y = arc4random_uniform(UInt32(self.frame.height - 200)) + 100
                
                let salad = SKSpriteNode(texture: saladTexture)
                salad.position = CGPoint(x: self.frame.width + 100, y: CGFloat(y))
                
                salad.xScale = 0.1
                salad.yScale = 0.1
                
                salad.physicsBody = SKPhysicsBody(texture: saladTexture, alphaThreshold: 0.5, size: salad.size)
                salad.physicsBody!.allowsRotation = false
                salad.physicsBody!.mass = 0.5
                salad.physicsBody!.linearDamping = 0.5
                salad.physicsBody!.friction = 0
                
                salad.physicsBody!.categoryBitMask = PhysicsCategory.good_food
                salad.physicsBody!.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.floor
                salad.physicsBody!.collisionBitMask = PhysicsCategory.hero | PhysicsCategory.floor
                salad.physicsBody!.fieldBitMask = PhysicsCategory.iashusGravity
                
                let y2 = Double(arc4random_uniform(UInt32(100)) + 300) / 100 / 3
                salad.run(SKAction.sequence([
                    SKAction.applyImpulse(CGVector(dx: -1000, dy: 1500*y2), duration: 2),
                    SKAction.removeFromParent()
                ]))
                
                self.addChild(salad)
            }),
            SKAction.wait(forDuration: 2)
        ])))
        
        // add sprites to the scene
        
        addChild(hbLabel)
        addChild(floor)
        addChild(hero)
        addChild(saladAttraction)
    }
    
    override func keyDown(with event: NSEvent) {
        keyState[event.keyCode] = true
    }
    
    override func keyUp(with event: NSEvent) {
        keyState[event.keyCode] = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1: SKPhysicsBody
        var body2: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body2 = contact.bodyA
            body1 = contact.bodyB
        }
        
        if body1.categoryBitMask & PhysicsCategory.hero != 0
                && body2.categoryBitMask & PhysicsCategory.bad_food != 0 {
            body2.node!.removeFromParent()
            hero.xScale += 0.1
            hero.yScale += 0.1
        }
        
        if body1.categoryBitMask & PhysicsCategory.hero != 0
                && body2.categoryBitMask & PhysicsCategory.good_food != 0 {
            body2.node!.removeFromParent()
            hero.xScale -= hero.xScale * 0.3
            hero.yScale -= hero.yScale * 0.3
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        saladAttraction.position = hero.position
        
        if let p = keyState[0x7B] {
            if p {
                hero.physicsBody?.applyForce(CGVector(dx: -20000*3, dy: 0))
            }
        }
        
        if let p = keyState[0x7C] {
            if p {
                hero.physicsBody?.applyForce(CGVector(dx: +20000*3, dy: 0))
            }
        }
        
        if let p = keyState[0x31] {
            if p {
                hero.physicsBody?.applyForce(CGVector(dx: 0, dy: +50000*3))
            } else {
                hero.physicsBody?.applyForce(CGVector(dx: 0, dy: -20000*3))
            }
        }
    }
    
}
