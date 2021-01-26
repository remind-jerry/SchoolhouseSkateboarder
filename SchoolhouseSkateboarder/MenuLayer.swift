//
//  MenuLayer.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 26.01.2021.
//

import SpriteKit

final class MenuLayer: SKSpriteNode {

    func display(message: String, score: Int?) {
        // Создаем надпись сообщения, используя передаваемое сообщение
        let messageLabel = SKLabelNode(text: message)
      
        // Устанавливаем начальное положение надписи в левой стороне 8 слоя меню
        let messageX = frame.width / 2.0
        print(messageX)
        let messageY = frame.height / 2.0
        print(messageY)
        messageLabel.position = CGPoint(x: messageX, y: messageY)
       
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        addChild(messageLabel)
    
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        // Если количество очков было передано методу, показываем надпись на экране
        if let scoreToDisplay = score {
            
            // Создаем текст с количеством очков из числа score
            let scoreString = String(format: "Score:%04d", scoreToDisplay)
            let scoreLabel = SKLabelNode(text: scoreString)
           
            // Задаем начальное положение надписи справа от слоя меню
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            
            // Анимируем движение надписи в центр экрана
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}


