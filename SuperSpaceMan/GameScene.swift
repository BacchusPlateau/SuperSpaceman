//
//  GameScene.swift
//  SuperSpaceMan
//
//  Created by Bret Williams on 5/12/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene : SKScene {
    
    let backgroundNode = SKSpriteNode(imageNamed: "Background")
    let backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
    let backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
    let foregroundNode = SKSpriteNode()
    let playerNode = SKSpriteNode(imageNamed: "Player")

    var engineExhaust: SKEmitterNode?
    
    var impulseCount = 40
    let coreMotionManager = CMMotionManager()
    
    let CollisionCategoryPlayer : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let CollisionCategoryBlackHoles : UInt32 = 0x1 << 3
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        isUserInteractionEnabled = true
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        backgroundNode.size.width = frame.size.width
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundNode)
        
        backgroundStarsNode.size.width = frame.size.width
        backgroundStarsNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundStarsNode.position = CGPoint(x: 160.0, y: 0.0)
        addChild(backgroundStarsNode)
        
        backgroundPlanetNode.size.width = frame.size.width
        backgroundPlanetNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundPlanetNode.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundPlanetNode)
        
        addChild(foregroundNode)
        
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width / 2.0)
        playerNode.physicsBody?.isDynamic = false
        playerNode.position = CGPoint(x: size.width / 2.0, y: 220)
        playerNode.physicsBody?.linearDamping = 1.0
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryPlayer
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles
        playerNode.physicsBody?.collisionBitMask = 0
        foregroundNode.addChild(playerNode)
        
        addBlackHolesToForeground()
        addOrbsToForeground()
        
        let engineExhaustPath = Bundle.main.path(forResource: "EngineExhaust", ofType: "sks")
        engineExhaust = NSKeyedUnarchiver.unarchiveObject(withFile: engineExhaustPath!) as? SKEmitterNode
        engineExhaust?.position = CGPoint(x: 0.0, y: -(playerNode.size.height / 2))
        playerNode.addChild(engineExhaust!)
        engineExhaust?.isHidden = true
        
    }
    
    func addOrbsToForeground() {
        
        var orbNodePosition = CGPoint(x: playerNode.position.x, y: playerNode.position.y + 100)
        var orbXShift : CGFloat = -1.0
        
        for _ in 1...50 {
            
            let orbNode = SKSpriteNode(imageNamed: "PowerUp")
            
            if (orbNodePosition.x - (orbNode.size.width * 2) <= 0) {
                
                orbXShift = 1.0
                
            }
            
            if (orbNodePosition.x + orbNode.size.width >= size.width) {
                
                orbXShift = -1.0
                
            }
            
            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120.0
            orbNode.position = orbNodePosition
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width / 2.0)
            orbNode.physicsBody?.isDynamic = false
            orbNode.physicsBody?.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody?.collisionBitMask = 0
            orbNode.name = "POWER_UP_ORB"
            foregroundNode.addChild(orbNode)
            
        }
        
    }
    
    func addBlackHolesToForeground() {
        
        let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
        
        let frame0 = textureAtlas.textureNamed("BlackHole0")
        let frame1 = textureAtlas.textureNamed("BlackHole1")
        let frame2 = textureAtlas.textureNamed("BlackHole2")
        let frame3 = textureAtlas.textureNamed("BlackHole3")
        let frame4 = textureAtlas.textureNamed("BlackHole4")
        
        let blackHoleTextures = [frame0, frame1, frame2, frame3, frame4]
        
        let animateAction = SKAction.animate(with: blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatForever(animateAction)
        let moveLeftAction = SKAction.moveTo(x: 0.0, duration: 3.0)
        let moveRightAction = SKAction.moveTo(x: size.width, duration: 3.0)
        let actionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
        let moveAction = SKAction.repeatForever(actionSequence)
        
        for i in 1...10 {
        
            let blackHoleNode = SKSpriteNode(imageNamed: "BlackHole0")
            blackHoleNode.position = CGPoint(x: size.width - 80, y: 600 * CGFloat(i))
            blackHoleNode.physicsBody = SKPhysicsBody(circleOfRadius: blackHoleNode.size.width / 2.0)
            blackHoleNode.physicsBody?.isDynamic = false
            blackHoleNode.name = "BLACK_HOLE"
            blackHoleNode.physicsBody?.categoryBitMask = CollisionCategoryBlackHoles
            blackHoleNode.physicsBody?.collisionBitMask = 0
            
            blackHoleNode.run(moveAction)
            blackHoleNode.run(rotateAction)
            
            foregroundNode.addChild(blackHoleNode)
            
        }
    }
    
    @objc func hideEngineExhaust(_ timer:Timer!) {
        
        if (!(engineExhaust?.isHidden)!) {
            
            engineExhaust?.isHidden = true
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!playerNode.physicsBody!.isDynamic) {
            
            playerNode.physicsBody!.isDynamic = true
            
            coreMotionManager.accelerometerUpdateInterval = 0.3
            coreMotionManager.startAccelerometerUpdates()
            
        }
        
        if (impulseCount > 0) {
            
            playerNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 40.0))
            impulseCount -= 1
            engineExhaust?.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 0.5,
                                 target: self,
                                 selector: #selector(GameScene.hideEngineExhaust(_:)),
                                 userInfo: nil,
                                 repeats: false)
            
        }
    }
    
    //this method is invoked BEFORE the render loop has evaluated all of the physics bodies in the scene
    override func update(_ currentTime: TimeInterval) {
        
        if (playerNode.position.y >= 180.0) {
        
            backgroundNode.position = CGPoint(x: backgroundNode.position.x, y: -((playerNode.position.y - 180.0) / 8))
            backgroundPlanetNode.position = CGPoint(x: backgroundPlanetNode.position.x, y: -((playerNode.position.y - 180.0) / 8))
            backgroundStarsNode.position = CGPoint(x: backgroundStarsNode.position.x, y: -((playerNode.position.y - 180.0) / 6))
            foregroundNode.position = CGPoint(x: foregroundNode.position.x, y: -(playerNode.position.y - 180.0))
            
        }
        
    }
    
    override func didSimulatePhysics() {
        
        if let accelerometerData = coreMotionManager.accelerometerData {
            
            playerNode.physicsBody!.velocity = CGVector(dx: CGFloat(accelerometerData.acceleration.x * 380.0),
                                                        dy: playerNode.physicsBody!.velocity.dy)
            
        }
        
        if (playerNode.position.x < -(playerNode.size.width / 2)) {
            
            playerNode.position = CGPoint(x: size.width - playerNode.size.width / 2, y: playerNode.position.y)
            
        } else if ( playerNode.position.x > self.size.width)  {
            
            playerNode.position = CGPoint(x: playerNode.size.width / 2, y: playerNode.position.y)
            
        }
        
    }
    
    deinit {
        
        coreMotionManager.stopAccelerometerUpdates()
        
    }
    
}

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let nodeB = contact.bodyB.node
        
        if (nodeB?.name == "POWER_UP_ORB") {
            
            impulseCount += 1
            nodeB?.removeFromParent()
            print ("impulse count: \(impulseCount)")
            
        } else if (nodeB?.name == "BLACK_HOLE") {
            
            playerNode.physicsBody?.contactTestBitMask = 0
            impulseCount = 0
            let colorizeAction = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 1)
            playerNode.run(colorizeAction)
            
        }
        
    }
    
}




