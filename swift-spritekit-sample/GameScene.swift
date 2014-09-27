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
    
    func newBall() -> SKNode {
        let ball = SKShapeNode.node()
        var path = CGPathCreateMutable()
        let r = skRand(3, high: 30)
        let pi = CGFloat(M_PI * 2)
        CGPathAddArc(path, nil, 0, 0, r, 0, pi, true)
        ball.path = path
        ball.fillColor = SKColor (
            red: skRand(0.0, high: 1.0),
            green: skRand(0.0,high: 1.0),
            blue: skRand(0.0, high: 1.0),
            alpha: skRand(0.7, high: 1.0))
        ball.strokeColor = SKColor.clearColor()
        ball.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - r)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
        return ball
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        addChild(myLabel)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count == 1) {
                let location = touch?.locationInNode(self)
                let ball = newBall()
                ball.position = location!
                addChild(ball)
            } else if(touches.count == 2){
                physicsWorld.gravity = CGVectorMake(0,physicsWorld.gravity.dy * -1.0)
            }
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
