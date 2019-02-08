//
//  GameScene.swift
//  second
//
//  Created by 洞井僚太 on 2018/11/17.
//  Copyright © 2018 洞井僚太. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene:SKScene,SKPhysicsContactDelegate{
    var dusts:[SKSpriteNode]=[]
    var player:SKSpriteNode!
    var dust:SKSpriteNode!
    let playerCategory:UInt32=0b0001
    let dustCategory:UInt32=0b0010
    let cont=SKLabelNode(text:"続ける")
    let label=SKLabelNode(text:"Game Clear!")
    var timer:Timer!
    var timeLabel=SKLabelNode(text:"Time:3")
    var lastTime:Int=3{
        didSet{
            timeLabel.text="Time:\(lastTime)"
        }
    }
    var downing:Bool=false
    var down:Timer!
    var downLabel=SKLabelNode(text:"3")
    var Time:Int=3{
        didSet{
            downLabel.text="\(Time)"
        }
    }
    var isClear:Bool=false
    var count=100
    override func didMove(to view: SKView) {
        addChild(SKAudioNode.init(fileNamed:"bgm_maoudamashii_8bit08"))
        physicsWorld.gravity=CGVector(dx:0,dy:0)
        physicsWorld.contactDelegate=self
        player=SKSpriteNode(imageNamed: "player")
        player.physicsBody=SKPhysicsBody(circleOfRadius:player.frame.width/2)
        player.physicsBody?.categoryBitMask=playerCategory
        player.physicsBody?.contactTestBitMask=dustCategory
        player.physicsBody?.collisionBitMask=0
        player.zPosition=1
        player.xScale=0.5
        player.yScale=0.5
        addChild(player)
        label.fontSize=50
        label.fontName="Papyrus"
        label.zPosition=2
        cont.fontSize=50
        cont.position = CGPoint(x:0,y:-(self.frame.height/3))
        for i in 0...count{
            dust=SKSpriteNode(imageNamed: "enemy")
            var xPos=Int(arc4random_uniform(UInt32(self.frame.width/2)))/*+Int(player.frame.width)*/
            var yPos=Int(arc4random_uniform(UInt32(self.frame.width/2)))/*+Int(player.frame.height)*/
            let xplus=Int(arc4random_uniform(2))
            let yplus=Int(arc4random_uniform(2))
            if xplus==1{
                xPos=xPos*(-1)
            }
            if yplus==1{
                yPos=yPos*(-1)
            }
            dust.xScale=0.1
            dust.yScale=0.1
            dust.position=CGPoint(x:xPos,y:yPos)
            dust.physicsBody=SKPhysicsBody(circleOfRadius:dust.frame.width/2)
            dust.physicsBody?.categoryBitMask=dustCategory
            dust.physicsBody?.contactTestBitMask=playerCategory
            dust.physicsBody?.collisionBitMask=0
            dust.zPosition=0
            dusts.append(dust)
            addChild(dust)
        }
        countDown()
    }
    func countDown(){
        Time=3
        downing=true
        down=Timer.scheduledTimer(withTimeInterval:1, repeats:true, block:{_ in
            self.Time-=1
        } )
        downLabel.fontSize=200
        downLabel.zPosition=2
        downLabel.fontColor=UIColor.blue
        addChild(downLabel)
        self.run(SKAction.wait(forDuration:3)){
            self.downing=false
            self.downLabel.removeFromParent()
            self.down.invalidate()
            self.timer=Timer.scheduledTimer(withTimeInterval:1, repeats:true, block:{_ in
                self.lastTime-=1
            } )
            self.timeLabel.position.y=self.frame.height/3
            self.timeLabel.fontSize=100
            self.addChild(self.timeLabel)}
    }
    func addEnemy(){
        cont.fontSize=50
        cont.position = CGPoint(x:0,y:-(self.frame.height/3))
        player.position=CGPoint(x:0,y:0)
        player.xScale=0.5
        player.yScale=0.5
        label.fontSize=50
        label.fontName="Papyrus"
        label.zPosition=2
        addChild(player)
        for i in 0...count{
            dust=SKSpriteNode(imageNamed: "enemy")
            var xPos=Int(arc4random_uniform(UInt32(self.frame.width/2)))/*+Int(player.frame.width)*/
            var yPos=Int(arc4random_uniform(UInt32(self.frame.width)/2))/*+Int(player.frame.height)*/
            let xplus=Int(arc4random_uniform(2))
            let yplus=Int(arc4random_uniform(2))
            if xplus==1{
                xPos=xPos*(-1)
            }
            if yplus==1{
                yPos=yPos*(-1)
            }
            dust.position=CGPoint(x:xPos,y:yPos)
            dust.xScale=0.1
            dust.yScale=0.1
            dust.physicsBody=SKPhysicsBody(circleOfRadius:dust.frame.width/2)
            dust.physicsBody?.categoryBitMask=dustCategory
            dust.physicsBody?.contactTestBitMask=playerCategory
            dust.physicsBody?.collisionBitMask=0
            dust.zPosition=0
            dusts.append(dust)
            addChild(dust)
        }
        countDown()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if downing{
            return
        }
        for touch:AnyObject in touches{
            let location=touch.location(in:self)
            if isClear{
                let touchNode=self.atPoint(location)
                print(touchNode)
                if touchNode==cont{
                    removeAllChildren()
                    cont.removeFromParent()
                    label.removeFromParent()
                    addEnemy()
                    lastTime=3
                    isClear=false
                    isPaused=false
                }
                return
            }
             player.position=location
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if downing{
            return
        }
        for touch:AnyObject in touches{
            if isClear==false{
                let location=touch.location(in:self)
                player.position=location
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var playerbody:SKPhysicsBody
        var enemybody:SKPhysicsBody
        if contact.bodyA.categoryBitMask==playerCategory{
            playerbody=contact.bodyA
            enemybody=contact.bodyB
        }else{
            playerbody=contact.bodyB
            enemybody=contact.bodyA
        }
        
        guard let playerNode=playerbody.node else {return}
        guard let enemynode=enemybody.node else{return}
        guard let explosion=SKEmitterNode(fileNamed:"kyuuinn")else{return}
        explosion.position=enemynode.position
        print(enemynode.position)
        addChild(explosion)     //余談でやる...???*/
        var tmp:[SKSpriteNode]=[]
        for i in 0..<dusts.count{
            tmp.append(dusts[i])
           // print(tmp[i].position)
        }
        dusts.removeAll()
        for i in 0..<tmp.count{
            
            if enemynode.position==tmp[i].position{
                enemynode.removeFromParent()
                continue
            }
            dusts.append(tmp[i])
        }
        print(dusts.count)
        self.run(SKAction.wait(forDuration:1)){
            explosion.removeFromParent()
        }
        tmp.removeAll()
    }
 
    
    override func update(_ currentTime: TimeInterval) {
        if lastTime==0{
            label.fontColor=UIColor.red
            label.text="Game Over"
            isClear=true
            addChild(label)
            addChild(cont)
            timer.invalidate()
            dusts.removeAll()
            isPaused=true
        }
        if dusts.count==0&&isClear==false{
            //player.removeFromParent()
            label.fontColor=UIColor.white
            isClear=true
            label.text="Game Clear!"
            addChild(label)
            addChild(cont)
            timer.invalidate()
            count+=1
            isPaused=true
        }
    }
}
