//
//  GameScene.swift
//  sample
//
//  Created by OKAYA YOHEI on 2014/09/27.
//  Copyright (c) 2014年 geishatokyo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    func skRandf() -> CGFloat {
        return CGFloat(Float(rand()) / Float(RAND_MAX));
    }
    func skRand(low: CGFloat, high: CGFloat) -> CGFloat {
        return skRandf() * (high - low) + low;
    }
    
    var player: SKNode?
    
    // Player用の玉を生成
    func newPlayer() -> SKNode {
        let ball = SKShapeNode.node()
        var path = CGPathCreateMutable()
        let r = CGFloat(30.0)
        let pi = CGFloat(M_PI * 2)
        CGPathAddArc(path, nil, 0, 0, r, 0, pi, true)
        ball.path = path
        ball.fillColor = SKColor.blueColor()
        ball.strokeColor = SKColor.clearColor()
        ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidX(self.frame))
        ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
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
        return rect
    }
    
    override func didMoveToView(view: SKView) {

        // 床配置
        addChild(newRect(6.40000009536743,y:92.8000030517578))
        addChild(newRect(36.2666664123535,y:87.4666748046875))
        addChild(newRect(58.6666679382324,y:70.3999786376953))
        addChild(newRect(97.0666656494141,y:66.1333312988281))
        addChild(newRect(161.066665649414,y:73.6000061035156))
        addChild(newRect(235.733337402344,y:70.3999786376953))
        addChild(newRect(320.0,y:73.6000061035156))
        addChild(newRect(379.733337402344,y:76.8000030517578))
        addChild(newRect(467.200012207031,y:76.8000030517578))
        addChild(newRect(537.599975585938,y:78.9333419799805))
        addChild(newRect(614.400024414062,y:84.2666778564453))
        addChild(newRect(680.533325195312,y:81.066650390625))
        addChild(newRect(758.400024414062,y:88.5333251953125))
        addChild(newRect(830.933349609375,y:83.1999816894531))
        addChild(newRect(903.466674804688,y:84.2666778564453))
        addChild(newRect(970.666687011719,y:84.2666778564453))
        addChild(newRect(1014.40002441406,y:88.5333251953125))
        addChild(newRect(136.533340454102,y:252.800018310547))
        addChild(newRect(197.33332824707,y:257.066650390625))
        addChild(newRect(254.933334350586,y:256.0))
        addChild(newRect(312.533325195312,y:253.866668701172))
        addChild(newRect(295.466674804688,y:452.266723632812))
        addChild(newRect(354.133331298828,y:461.86669921875))
        addChild(newRect(400.0,y:452.266723632812))
        addChild(newRect(451.200012207031,y:454.400024414062))
        addChild(newRect(683.733337402344,y:410.666687011719))
        addChild(newRect(724.266662597656,y:412.800048828125))
        addChild(newRect(760.533325195312,y:406.400024414062))
        
        player = newPlayer()
        addChild(player!)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
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
}
