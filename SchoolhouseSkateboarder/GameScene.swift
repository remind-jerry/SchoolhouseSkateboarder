//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 18.01.2021.
//

import SpriteKit

struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 100.0
    }
    
    var bricks = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    var brickSize = CGSize.zero
    var brickLevel = BrickLevel.low
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    let gravitySpeed: CGFloat = 1.5
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    var lastUpdateTime: TimeInterval?
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        anchorPoint = CGPoint.zero
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        background.size = self.size // размер картинки для сцены подогнали под размер сцены
        addChild(background)
        setupLabels()
        addChild(skater)
        skater.setupPhysicsBody()
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self,action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        startGame()
    }
    
    func resetSkater() {
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        // Надпись со словами "очки" в верхнем левом углу
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "очки")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // Надпись с количеством очков игрока в текущей игре
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // Надпись "лучший результат" в правом верхнем углу
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text:  "Лучший результат")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0,  y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        // Надпись с максимумом набранных игроком очков
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as?SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
           highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        resetSkater()
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        bricks.forEach { $0.removeFromParent() }
        bricks.removeAll(keepingCapacity: true)
        gems.forEach { removeGem($0) }
    }
    
    func gameOver() {
        if score > highScore {
            highScore = score
            updateHighScoreLabelText()
        }
        startGame()
    }
    
    func spawnBrick (atPosition position: CGPoint) -> SKSpriteNode {
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)

        brickSize = brick.size
        bricks.append(brick)

        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        gem.removeFromParent()
        if let gemIndex = gems.firstIndex(of: gem) { gems.remove(at: gemIndex) }
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            // Если секция сместилась слишком далеко влево (за пределы 8 экрана), удалите ее
            if newX < -brickSize.width {
                brick.removeFromParent()
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                // Для секции, оставшейся на экране, обновляем положение
                brick.position = CGPoint(x: newX, y: brick.position.y)
                //Обновляем значение для крайней правой секции
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            let randomNumber = arc4random_uniform(99)
            if randomNumber < 2 && score > 10 {
                let gap = 20.0 * scrollSpeed
                brickX += gap
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            } else if randomNumber < 4 && score > 20 {
                brickLevel = brickLevel == .high ? .low : .high
            }
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            // Удаляем любые алмазы, ушедшие с экрана
            if gem.position.x < 0.0 { removeGem(gem) }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        scrollSpeed += 0.001
        
        // Called before each frame is rendered
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime { elapsedTime = currentTime - lastTimeStamp }
        lastUpdateTime = currentTime
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
    }
        
    func updateSkater() {
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        // Проверяем, должна ли игра закончиться
        let isOffScreen = skater.position.y < 0.0 ||  skater.position.x < 0.0
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        if isOffScreen || isTippedOver { gameOver() }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        // Количество очков игрока увеличивается по мере игры
        // Счет обновляется каждую секунду
        let elapsedTime = currentTime - lastScoreUpdateTime
        if elapsedTime > 1.0 {
            // Увеличиваем количество очков
            score += Int(scrollSpeed)
            // Присваиваем свойству lastScoreUpdateTime значение 8 текущего времени
            lastScoreUpdateTime = currentTime
            updateScoreLabelText()
        }
        updateSkater()
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if skater.isOnGround { skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0)) }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Проверяем, есть ли контакт между скейтбордисткой и секцией
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            skater.isOnGround = true
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
               // Скейтбордистка коснулась алмаза, поэтому мы его убираем
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGem(gem)
                score += 50
                updateScoreLabelText()
            }
        }
    }
}
