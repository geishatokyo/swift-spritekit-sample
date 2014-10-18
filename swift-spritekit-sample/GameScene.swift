//
//  GameScene.swift
//  sample
//
//  Created by OKAYA YOHEI on 2014/09/27.
//  Copyright (c) 2014年 geishatokyo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    func skRandf() -> CGFloat {
        return CGFloat(Float(rand()) / Float(RAND_MAX));
    }
    func skRand(low: CGFloat, high: CGFloat) -> CGFloat {
        return skRandf() * (high - low) + low;
    }
    
    var player: SKNode?
    
    // カテゴリを用意しておく。
    let wallCategory: UInt32 = 0x1 << 0
    let blueCategory: UInt32 = 0x1 << 1
    let redCategory: UInt32 = 0x1 << 2
    let greenCategory: UInt32 = 0x1 << 3
    
    // 玉を生成
    func newBall(color: UIColor, categoryBitMask: UInt32, contactTestBitMask: UInt32) -> SKNode {
        let ball = SKShapeNode.node()
        var path = CGPathCreateMutable()
        let r = CGFloat(30.0)
        let pi = CGFloat(M_PI * 2)
        CGPathAddArc(path, nil, 0, 0, r, 0, pi, true)
        ball.path = path
        ball.fillColor =  color // SKColor.blueColor()
        ball.strokeColor = SKColor.clearColor()
        ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidX(self.frame))
        ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
        ball.physicsBody?.categoryBitMask = categoryBitMask // blueCategory
        ball.physicsBody?.contactTestBitMask = contactTestBitMask // redCategory
        return ball
    }
    
    // 静的な四角を生成
    func newRect(x: CGFloat, y: CGFloat) -> SKNode {
        let rect = SKSpriteNode(
            color: UIColor.redColor(),
            size: CGSizeMake(80, 80)
        )
        rect.position = CGPointMake(x, y)
        rect.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        rect.physicsBody?.dynamic = false // 動かない
        rect.physicsBody?.categoryBitMask = redCategory
        rect.physicsBody?.contactTestBitMask = 0 // 初期化しないと不定値が入る
        return rect
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let floorPositions: [[CGFloat]] = [
            [6.40000009536743,92.8000030517578],
            [36.2666664123535,87.4666748046875],
            [58.6666679382324,70.3999786376953],
            [97.0666656494141,66.1333312988281],
            [161.066665649414,73.6000061035156],
            [235.733337402344,70.3999786376953],
            [320.0,73.6000061035156],
            [379.733337402344,76.8000030517578],
            [467.200012207031,76.8000030517578],
            [537.599975585938,78.9333419799805],
            [614.400024414062,84.2666778564453],
            [680.533325195312,81.066650390625],
            [758.400024414062,88.5333251953125],
            [830.933349609375,83.1999816894531],
            [903.466674804688,84.2666778564453],
            [970.666687011719,84.2666778564453],
            [1014.40002441406,88.5333251953125],
            [136.533340454102,252.800018310547],
            [197.33332824707,257.066650390625],
            [254.933334350586,256.0],
            [312.533325195312,253.866668701172],
            [295.466674804688,452.266723632812],
            [354.133331298828,461.86669921875],
            [400.0,452.266723632812],
            [451.200012207031,454.400024414062],
            [683.733337402344,410.666687011719],
            [724.266662597656,412.800048828125],
            [760.533325195312,406.400024414062]
        ]
        // 床配置
        for floor in floorPositions {
            addChild(newRect(floor[0],y:floor[1]))
        }
        
        player = newBall(SKColor.blueColor(),
            categoryBitMask: blueCategory,
            contactTestBitMask: greenCategory)
        addChild(player!)
        
        let greenBall = newBall(SKColor.greenColor(),
            categoryBitMask: greenCategory,
            contactTestBitMask: blueCategory)
        greenBall.position.x += 500
        addChild(greenBall)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = wallCategory
        self.physicsBody?.contactTestBitMask = 0
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count == 1) {
                let location = touch?.locationInNode(self)
                let touchX = location?.x
                let position = player?.position
                let positionX = position?.x
                if(positionX > touchX) {
                    player?.physicsBody?.applyImpulse(CGVectorMake(-100.0,150.0))
                } else {
                    player?.physicsBody?.applyImpulse(CGVectorMake(100.0,150.0))
                }
            }
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    var i : UInt8 = 1
    func didBeginContact(contact: SKPhysicsContact!) {
        
        var firstBody, secondBody: SKPhysicsBody
        
        // firstを青、secondを緑とする。
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 青と緑が接したときの処理。
        if ((firstBody.categoryBitMask & blueCategory) != 0) &&
            ((secondBody.categoryBitMask & greenCategory) != 0) {
                let label = SKLabelNode(fontNamed:"Chalkduster")
                label.text = "Hit!"
                label.fontSize = 65
 
                label.position = CGPoint(x:skRand(0, high: CGRectGetMaxX(self.frame)),
                    y:skRand(0, high: CGRectGetMaxY(self.frame)));
                addChild(label)
        }
    }
}
