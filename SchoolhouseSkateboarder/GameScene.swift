//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 18.01.2021.
//

import SpriteKit

final class GameScene: SKScene {

    // MARK: Private properties

    private enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 100.0
    }
    
    private enum GameState {
        case notRunning
        case running
    }

    private var bricks = [SKSpriteNode]()
    private var gems = [SKSpriteNode]()
    private var brickSize: CGSize = .zero
    private var brickLevel: BrickLevel = .low
    private var gameState: GameState = .notRunning
    private var scrollSpeed: CGFloat = 5.0
    private var score: Int = 0
    private var highScore: Int = 0
    private var lastScoreUpdateTime: TimeInterval = 0.0
    private var lastUpdateTime: TimeInterval?
    private let skater = Skater(imageNamed: "skater")
    private let startingScrollSpeed: CGFloat = 5.0
    private let gravitySpeed: CGFloat = 1.5

    // MARK: Lifecycle

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        anchorPoint = .zero

        let backgroundNode = SKSpriteNode(imageNamed: "background")
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.size = size // размер картинки для сцены подогнали под размер сцены
        addChild(backgroundNode)

        setupLabels()
        addChild(skater)
        skater.setupPhysicsBody()
        
        let tapMethod = #selector(handleTap)
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        // Добавляем слой меню с текстом "Нажмите, чтобы играть"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: size)
        menuLayer.anchorPoint = .zero
        menuLayer.position = .zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Tap to play", score: nil)
        
        addChild(menuLayer)
    }

    override func update(_ currentTime: TimeInterval) {
        if gameState != .running { return }

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

    // MARK: Private methods

    private func resetSkater() {
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    private func setupLabels() {
        // Надпись со словами "Score" в верхнем левом углу
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "Score")
        scoreTextLabel.position = CGPoint(x: frame.minX + 25, y: frame.maxY - 25)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 25.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // Надпись с количеством очков игрока в текущей игре
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: frame.minX + 125, y: frame.maxY - 25)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 25.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // Надпись "Best score" в правом верхнем углу
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "Best score")
        highScoreTextLabel.position = CGPoint(x: frame.maxX - 100,  y: frame.maxY - 25)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 25.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        // Надпись с максимумом набранных игроком очков
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 25)
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 25.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    private func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    private func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    private func startGame() {
        gameState = .running
        resetSkater()
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        bricks.forEach { $0.removeFromParent() }
        bricks.removeAll(keepingCapacity: true)
        gems.forEach { removeGem($0) }
    }
    
    private func gameOver() {
        gameState = .notRunning

        if score > highScore {
            highScore = score
            updateHighScoreLabelText()
        }
        
        // Показываем надпись "Игра окончена!"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = .zero
        menuLayer.position = .zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display( message: "Game over", score: score)
        addChild(menuLayer)
    }
    
    private func spawnBrick (atPosition position: CGPoint) -> SKSpriteNode {
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
    
    private func spawnGem(atPosition position: CGPoint) {
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)

        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        gems.append(gem)
    }
    
    private func removeGem(_ gem: SKSpriteNode) {
        gem.removeFromParent()
        if let gemIndex = gems.firstIndex(of: gem) { gems.remove(at: gemIndex) }
    }
    
    private func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
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
    
    private func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            // Удаляем любые алмазы, ушедшие с экрана
            if gem.position.x < 0.0 { removeGem(gem) }
        }
    }
        
    private func updateSkater() {
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        // Проверяем, должна ли игра закончиться
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        if isOffScreen || isTippedOver { gameOver() }
    }
    
    private func updateScore(withCurrentTime currentTime: TimeInterval) {
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
    
    @objc private func handleTap(tapGesture: UITapGestureRecognizer) {
        if gameState == .running {
            if skater.isOnGround { skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
        } else {
            // Если игра не запущена, нажатие на экран запускает новую игру
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                menuLayer.removeFromParent()
            }
            startGame()
        }
    }

}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Проверяем, есть ли контакт между скейтбордисткой и секцией
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            if let velocityY = skater.physicsBody?.velocity.dy {
            if !skater.isOnGround && velocityY < 100.0 {
                skater.createSparks()
            }
            }
            skater.isOnGround = true
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            // Скейтбордистка коснулась алмаза, поэтому мы его убираем
            if let gem = contact.bodyB.node as? SKSpriteNode {
            removeGem(gem)
            score += 50
            updateScoreLabelText()
            run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
        }
    }
}
