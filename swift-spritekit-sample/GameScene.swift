//
//  GameScene.swift
//  sample
//
//  Created by OKAYA YOHEI on 2014/09/27.
//  Copyright (c) 2014年 geishatokyo. All rights reserved.
//

import SpriteKit

extension SKNode{
    func skRandf() -> CGFloat {
        return CGFloat(Float(rand()) / Float(RAND_MAX));
    }
    
    func skRand(low: CGFloat, high: CGFloat) -> CGFloat {
        return skRandf() * (high - low) + low;
    }
}

struct Category{
    // カテゴリを用意しておく。
    static let wall: UInt32 = 0x1 << 0
    static let goal: UInt32 = 0x1 << 1
    static let player: UInt32 = 0x1 << 2
    static let enemy: UInt32 = 0x1 << 3
}

protocol MovingNode{
    func move(current: CGFloat)
}

class WallNode: SKSpriteNode{
    // 静的な四角を生成
    let x: CGFloat
    let y: CGFloat
    
    let width: CGFloat = 80.1
    let height: CGFloat = 80.1
    
    init(x: CGFloat, y: CGFloat, category: UInt32){
        self.x = x
        self.y = y
        super.init(
            texture: nil,
            color: UIColor.redColor(),
            size: CGSizeMake(width, height)
        )
        self.position = CGPointMake(x, y)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false // 動かない
        self.physicsBody?.categoryBitMask = category
        self.physicsBody?.contactTestBitMask = 0 // 初期化しないと不定値が入る
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.x = 0
        self.y = 0
        super.init(coder: aDecoder)
    }
}

class VerticalMovingWall: WallNode, MovingNode{
    func move(current: CGFloat) {
        let ang: CGFloat = current
        self.position = CGPointMake(self.x + self.width * CGFloat(sin(ang)), self.y)
    }
}

class HorizontalMovingWall: WallNode, MovingNode{
    func move(current: CGFloat) {
        let ang: CGFloat = current
        self.position = CGPointMake(self.x, self.y + self.height * CGFloat(sin(ang)))
    }
}

class BallNode: SKShapeNode{
    init(color: UIColor, categoryBitMask: UInt32, contactTestBitMask: UInt32){
        super.init()
        var path = CGPathCreateMutable()
        let r = CGFloat(30.0)
        let pi = CGFloat(M_PI * 2)
        CGPathAddArc(path, nil, 0, 0, r, 0, pi, true)
        self.path = path
        self.fillColor = color
        self.strokeColor = color
        self.position = CGPointMake(80, 80)
        self.physicsBody = SKPhysicsBody(circleOfRadius: r)
        self.physicsBody?.categoryBitMask = categoryBitMask
        self.physicsBody?.contactTestBitMask = contactTestBitMask
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EnemyNode: BallNode, MovingNode{
    let prob : CGFloat
    init(prob: CGFloat){
        self.prob = prob
        super.init(color: SKColor.greenColor(), categoryBitMask: Category.enemy, contactTestBitMask: Category.player)
        self.physicsBody?.restitution = 0.8;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.prob = 0.0
        super.init(coder: aDecoder)
    }
    
    func move(current: CGFloat) {
        if skRandf() < prob{
            self.physicsBody?.applyImpulse(
                CGVectorMake(skRand(0, high: 200), skRand(0, high: 200)))
        }
    }
}

class PlayerNode: BallNode{
    var hp: Int
    
    init(hp: Int){
        self.hp = hp
        super.init(color: SKColor.blueColor(), categoryBitMask: Category.player, contactTestBitMask: Category.enemy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hp = 0
        super.init(coder: aDecoder)
    }
    
    func damage(amount: Int){
        hp = max(0, hp - amount)
    }
    
    func isDead() -> Bool{
        return hp == 0
    }
}

class GoalNode: SKSpriteNode{
    let width: CGFloat = 80.1
    let height: CGFloat = 80.1
    
    init(x: CGFloat, y: CGFloat){
        super.init(
            texture: nil,
            color: UIColor.whiteColor(),
            size: CGSizeMake(80, 80)
        )
        self.position = CGPointMake(x, y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isGoal(player: SKNode) -> Bool{
        return self.containsPoint(player.position)
    }
}

class MapNode: SKNode{
    var start: CGPoint?
    var goal: CGPoint?
    var movingItem: [MovingNode] = []
    
    init(map: [String], category: UInt32){
        super.init()
        let h = map.count
        
        for y in 0 ..< h{
            let w = countElements(map[0])
            for x in 0 ..< w{
                let s = map[y]
                let c = s[advance(s.startIndex, x)]
                
                let xPos = CGFloat(x * 80)
                let yPos = CGFloat((h - y - 1) * 80)
                
                if c == "#"{
                    // 壁
                    self.addChild(WallNode(x: xPos, y: yPos, category: category))
                }else if c == "|"{
                    // 縦に動く壁
                    let node = VerticalMovingWall(x: xPos, y:yPos, category: category)
                    self.addChild(node)
                    movingItem.append(node)
                }else if c == "-"{
                    // 横に動く壁
                    let node = HorizontalMovingWall(x: xPos, y:yPos, category: category)
                    self.addChild(node)
                    movingItem.append(node)
                }else if c == "S"{
                    // スタート
                    self.start = CGPointMake(xPos, yPos)
                }else if c == "G"{
                    // ゴール
                    self.goal = CGPointMake(xPos, yPos)
                }else if c == "E"{
                    // 動く敵
                    let enemy = EnemyNode(prob: 0.01)
                    enemy.position = CGPointMake(xPos, yPos)
                    self.addChild(enemy)
                    movingItem.append(enemy)
                }else if c == "e"{
                    // 動かない敵
                    let enemy = EnemyNode(prob: 0.00)
                    enemy.position = CGPointMake(xPos, yPos)
                    self.addChild(enemy)
                    movingItem.append(enemy)
                }
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SKScene{
    func makeLabel(text: String, fontSize: CGFloat) -> SKLabelNode{
        let label = SKLabelNode(fontNamed:"Chalkduster")
        label.text = text
        label.fontSize = fontSize
        label.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        return label
    }
}

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.addChild(self.makeLabel("Tap to Start", fontSize: 65))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count >= 1) {
                let transition = SKTransition.doorsOpenHorizontalWithDuration(2)
                let scene = MainGameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view!.presentScene(scene, transition: transition)
            }
        }
    }
}

class GameOverScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.addChild(self.makeLabel("ゲームオーバー", fontSize: 65))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count >= 1) {
                let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 1)
                let scene = GameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view!.presentScene(scene, transition: transition)
            }
        }
    }
}

class ClearScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.addChild(self.makeLabel("ゲームクリアー", fontSize: 65))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count >= 1) {
                let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 1)
                let scene = GameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view!.presentScene(scene, transition: transition)
            }
        }
    }
}

class MainGameScene: SKScene, SKPhysicsContactDelegate {
    var map1 = [
        "###################",
        "#.................#",
        "#.................#",
        "#.....e..G..e.....#",
        "#....#########....#",
        "#.................#",
        "#.................#",
        "#..||...---...||..#",
        "#.................#",
        "#...E.........E...#",
        "#..###.......###..#",
        "#.................#",
        "#S................#",
        "###################"
    ]
    
    var map2 = [
        "############################################",
        "#................#.....#...................#",
        "#................#.........................#",
        "#........e...................e...e.........#",
        "#........#.............##################..#",
        "#...................E..#...............#...#",
        "#................#######.........e...G.#...#",
        "#.....E....E.....#..............########...#",
        "#....###..###....#.........e....e..........#",
        "#................#........---..---.....|...#",
        "#.............|..#...........EE........|...#",
        "#....e........|..#...E......####.......|...#",
        "#...###.......|..#..###................|...#",
        "#................#..............|..........#",
        "#................#..............|..###.....#",
        "#..---......---..#.........E....|..........#",
        "#................#........----....---.######",
        "#................#...--....................#",
        "#.S....E.E.......#......E..................#",
        "############################################"
    ]
    
    var player: PlayerNode?
    var goal: GoalNode?
    var myWorld: SKNode?
    var movingItem: [MovingNode] = []
    var hpLabel: SKLabelNode?
    
    override func didMoveToView(view: SKView) {
        self.anchorPoint = CGPointMake(0.5, 0.5)
        self.physicsWorld.contactDelegate = self

        myWorld = SKNode()
        self.addChild(myWorld!)
        
        let (startPos, goalPos) = makeMap(map1, parent: myWorld!)
        
        player = PlayerNode(hp: 100)
        player!.position = startPos
        myWorld!.addChild(player!)
        
        goal = GoalNode(x: goalPos.x, y: goalPos.y)
        myWorld!.addChild(goal!)
        
        let label = makeLabel("HP: " + String(player!.hp), fontSize: 30)
        label.position = CGPointMake(100 - self.frame.width / 2, self.frame.height / 2 - 150)
        self.hpLabel = label
        self.addChild(label)
    }
    
    func makeMap(map: [String], parent: SKNode) -> (CGPoint, CGPoint){
        let mapNode = MapNode(map: map, category: Category.wall)
        parent.addChild(mapNode)
        
        for item in mapNode.movingItem{
            movingItem.append(item)
        }
        
        return (mapNode.start!, mapNode.goal!)
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch: AnyObject? = touches.anyObject()
        if (touch != nil) {
            if(touches.count == 1) {
                let location = touch!.locationInNode(myWorld!)
                let touchX = location.x
                let touchY = location.y
                let position = player!.position
                let positionX = position.x
                let positionY = position.y
                let length = CGFloat(sqrt(pow(Double(positionX - touchX), 2) + pow(Double(positionY - touchY), 2)))
                let power: CGFloat = 200
                if length >= 1{
                    player?.physicsBody?.applyImpulse(
                        CGVectorMake((touchX - positionX) / 2, (touchY - positionY) / 1.5))
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for item in movingItem{
            item.move(CGFloat(currentTime))
        }
        
        if goal!.isGoal(player!){
            clearGame()
        }
        
        hpLabel?.text = "HP: " + String(player!.hp)
    }
    
    override func didFinishUpdate() {
        self.centerOnNode(player!)
    }
    
    // 対象のノードを中心に持ってくる(カメラの機能)
    func centerOnNode(node: SKNode){
        let cameraPositionInScene = node.scene?.convertPoint(node.position, fromNode: myWorld!)
        myWorld!.position = CGPointMake(
            myWorld!.position.x - cameraPositionInScene!.x,
            myWorld!.position.y - cameraPositionInScene!.y);
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (Category.player | Category.enemy){
            player!.damage(20)
            if player!.isDead(){
                gameOver()
            }
        }
    }
    
    var clear: Bool = false
    func clearGame(){
        // フラグをたてないと毎フレームシーン遷移しようとしてうまくいかない
        if !clear {
            clear = true
            let transition = SKTransition.fadeWithDuration(0.5)
            let scene = ClearScene(size: self.scene!.size)
            scene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view!.presentScene(scene, transition: transition)
        }
    }
    
    func gameOver(){
        let transition = SKTransition.fadeWithDuration(0.5)
        let scene = GameOverScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view!.presentScene(scene, transition: transition)
    }
}