//
//  GameScene.swift
//  ShootingGalleryGame
//
//  Created by Helder on 06/08/20.
//  Copyright © 2020 Helder de Melo Sérvio Filho. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let goodTargets = ["fishTile_073", "fishTile_075", "fishTile_077", "fishTile_079", "fishTile_081"]
    let badTargets = ["fishTile_091", "fishTile_093", "fishTile_095", "fishTile_097", "fishTile_099"]
    let rareTargets = ["fishTile_101", "fishTile_103"]
    let seaBedTop = ["fishTile_006", "fishTile_007", "fishTile_009"]
    let algae = ["fishTile_014", "fishTile_015", "fishTile_016", "fishTile_017", "fishTile_032", "fishTile_033", "fishTile_034", "fishTile_035"]
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var isGameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var ammo = 6
    var gameTimer: Timer?
    var gameOverTimer: Timer?
    
    override func didMove(to view: SKView) {
        createBackgroundGradient()
        addSeaBed()
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        scoreLabel.color = .brown
        scoreLabel.position = CGPoint(x: 15, y: 1290)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        let rechargeButton = SKSpriteNode(imageNamed: "fishTile_121")
        rechargeButton.name = "recharge"
        rechargeButton.position = CGPoint(x: 700, y: 1300)
        addChild(rechargeButton)
        
        score = 0
        physicsWorld.gravity = .zero
        
        run(SKAction.playSoundFileNamed("backgroundtheme.wav", waitForCompletion: false))
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(createTargets), userInfo: nil, repeats: true)
        gameOverTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(setGameOver), userInfo: nil, repeats: false)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        guard let touch = touches.first else { return }
        for node in nodes(at: touch.location(in: self)) {
            if let node = node as? SKSpriteNode, node.name == "recharge" && ammo == 0 {
                node.size = CGSize(width: node.size.width * 1.5, height: node.size.height * 1.5)
                node.run(SKAction.resize(toWidth: node.size.width / 1.5, height: node.size.height / 1.5, duration: 0.3))
                ammo = 6
                return
            }
            guard let fish = node as? Fish else { return }
            if ammo == 0 { return }
            switch(fish.type) {
            case .smallGood:
                score += 10
            case .mediumGood:
                score += 5
            case .bigGood:
                score += 1
            case .smallBad:
                score -= 10
            case .mediumBad:
                score -= 5
            case .bigBad:
                score -= 1
            case .rare:
                score += 15
            default:
                break
            }
            fish.removeFromParent()
            let bubble = SKSpriteNode(imageNamed: "fishTile_125")
            bubble.position = touch.location(in: self)
            bubble.name = "bubble"
            addChild(bubble)
            bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2)
            bubble.physicsBody?.velocity = CGVector(dx: 0, dy: 400)
            bubble.physicsBody?.linearDamping = 0
            bubble.zPosition = -1
            bubble.physicsBody?.collisionBitMask = 1
            bubble.physicsBody?.categoryBitMask = 5
            run(SKAction.playSoundFileNamed("bubblepop.wav", waitForCompletion: false))
            if ammo > 0 {
                ammo -= 1
            }
        }
    }
    
    @objc func setGameOver() {
        gameOverLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 110
        gameOverLabel.text = "GAME OVER"
        addChild(gameOverLabel)
        scoreLabel.position = CGPoint(x: 325, y: frame.midY - 100)
        isGameOver = true
    }
    
    @objc func createTargets() {
        if isGameOver { return }
        let targets = [goodTargets.randomElement()!, goodTargets.randomElement()!, goodTargets.randomElement()!, goodTargets.randomElement()!, goodTargets.randomElement()!, goodTargets.randomElement()!, badTargets.randomElement()!, badTargets.randomElement()!, badTargets.randomElement()!, badTargets.randomElement()!, rareTargets.randomElement()!]
        guard let target1 = targets.randomElement() else { return }
        guard let target2 = targets.randomElement() else { return }
        guard let target3 = targets.randomElement() else { return }
        
        let targetImages = [target1, target2, target3]
        for index in 0..<targetImages.count {
            let sprite = Fish(imageNamed: targetImages[index])
            sprite.name = index == 0 ? "fish1" : index == 1 ? "fish2" : "fish3"
            let yPosition = index == 0 ? 1200 : index == 1 ? 800 : 400
            let xPosition = index == 1 ? 750 : 0
            let dx: Double = index == 1 ? -400 : 400
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.zPosition = 1
            if index == 1 {
                sprite.xScale = -1
            }
            switch(targetImages[index]) {
            case "fishTile_073", "fishTile_077":
                sprite.type = .mediumGood
            case "fishTile_075", "fishTile_081":
                sprite.type = .smallGood
            case "fishTile_079":
                sprite.type = .bigGood
            case "fishTile_091", "fishTile_095":
                sprite.type = .mediumBad
            case "fishTile_093", "fishTile_099":
                sprite.type = .smallBad
            case "fishTile_097":
                sprite.type = .bigBad
            default:
                sprite.type = .rare
            }
            addChild(sprite)
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
            sprite.physicsBody?.categoryBitMask = 2
            sprite.physicsBody?.collisionBitMask = 0
            if sprite.type == fishType.mediumGood || sprite.type == fishType.mediumBad {
                sprite.physicsBody?.velocity = CGVector(dx: dx, dy: -60)
            } else if sprite.type == fishType.smallGood || sprite.type == fishType.smallBad || sprite.type == fishType.rare {
                sprite.physicsBody?.velocity = CGVector(dx: 1.5 * dx, dy: -60)
            } else {
                sprite.physicsBody?.velocity = CGVector(dx: dx / 1.2, dy: -60)
            }
            sprite.physicsBody?.linearDamping = 0
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        for node in children {
            guard let node = node as? Fish else { continue }
            var yDefaultPosition: CGFloat!
            switch(node.name) {
            case "fish1":
                yDefaultPosition = 1200
            case "fish2":
                yDefaultPosition = 800
            default:
                yDefaultPosition = 400
            }
            if node.position.y > yDefaultPosition + 10 {
                node.physicsBody?.velocity.dy = -60
            } else if node.position.y < yDefaultPosition - 10 {
                node.physicsBody?.velocity.dy = 60
            }
        }
    }
    
    func imageFromGradientLayer(layer: CAGradientLayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: layer.frame.width, height: layer.frame.height), true, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    func createBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 750, height: 1334)
        gradient.colors = [SKColor.cyan.cgColor, SKColor.blue.cgColor]
        let texture = SKTexture(image: imageFromGradientLayer(layer: gradient))
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: 375, y: 667)
        sprite.zPosition = -3
        addChild(sprite)
    }
    
    func addSeaBed() {
        for i in 0...12 {
            if i > 0 && i % 3 == 0 {
                let plant = SKSpriteNode(imageNamed: algae.randomElement()!)
                plant.position = CGPoint(x: i * 64 + 10, y: 205)
                plant.zPosition = -2
                addChild(plant)
            }
            
            let topSprite = SKSpriteNode(imageNamed: seaBedTop.randomElement()!)
            topSprite.position = CGPoint(x: i * 64, y: 150)
            topSprite.zPosition = -1
            addChild(topSprite)
            
            let bottomSprite1 = SKSpriteNode(imageNamed: "fishTile_001")
            bottomSprite1.position = CGPoint(x: i * 64, y: 86)
            bottomSprite1.zPosition = -1
            addChild(bottomSprite1)
            
            let bottomSprite2 = SKSpriteNode(imageNamed: "fishTile_001")
            bottomSprite2.position = CGPoint(x: i * 64, y: 22)
            bottomSprite2.zPosition = -1
            addChild(bottomSprite2)
        }
    }
}
