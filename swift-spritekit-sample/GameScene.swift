//
//  GameScene.swift
//  sample
//
//  Created by OKAYA YOHEI on 2014/09/27.
//  Copyright (c) 2014年 geishatokyo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var miku : SKSpriteNode? = nil
    var walk : SKAction? = nil
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let atlas = SKTextureAtlas(named: "move")
        let textures = atlas.textureNames.map { tex in
            atlas.textureNamed(tex as String)
        }
        let location = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        miku = SKSpriteNode(texture: textures.first)
        miku?.position = location
        let size = textures.first?.size()
        miku?.physicsBody = SKPhysicsBody(rectangleOfSize: size!)
        addChild(miku!)
        walk = SKAction.repeatActionForever(SKAction.animateWithTextures(textures,timePerFrame: 0.25))
        miku?.runAction(walk!)
        
        // 床を敷き詰める
        let b = SKTexture(imageNamed: "block_ds")
        let b1 = SKTexture(rect: CGRectMake(0, (432.0 - 48.0) / 432.0, 16.0 / 128.0, 48.0 / 432.0), inTexture: b)
        let bNode = SKSpriteNode(texture: b1)
        let x = CGRectGetMinX(self.frame)
        let y = CGRectGetMinY(self.frame) + 50
        let count = Int(CGRectGetMaxX(self.frame) / 16.0) + 1
        for var i = 0 ; i < count ; ++i  {
            let bNode = SKSpriteNode(texture: b1)
            bNode.position = CGPointMake(x + CGFloat(i * 16.0), y)
            bNode.physicsBody = SKPhysicsBody(rectangleOfSize: b1.size())
            addChild(bNode)
        }

        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            let atlas = SKTextureAtlas(named: "jmp")
            let textures = atlas.textureNames.map { tex in
                atlas.textureNamed(tex as String)
            }
            let action = SKAction.sequence([SKAction.animateWithTextures(textures, timePerFrame: 0.05),walk!])
            miku?.runAction(action)
            miku?.physicsBody?.applyImpulse(CGVectorMake(0.0,200.0))
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
