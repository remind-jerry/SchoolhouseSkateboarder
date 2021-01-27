//
//  GameViewController.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 18.01.2021.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    // MARK: Properties

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let skScene = GameScene(fileNamed: "GameScene") {
            let skView = view as! SKView
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true

            // Set the scale mode to scale to fit the window
            skScene.scaleMode = .aspectFill

            // Present the scene
            skView.presentScene(skScene)
        }
    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        let skView = self.view as! SKView
//        if let scene = skView.scene {
//            var size = scene.size
//            let newHeight = skView.bounds.size.height / skView.bounds.width * size.width
//            if newHeight > size.height {
//                scene.anchorPoint = CGPoint(x: 0, y: (newHeight - scene.size.height) / 2.0 / newHeight)
//                size.height = newHeight
//                scene.size = size
//                print("scene.size = \(size)")
//            }
//        }
//    }

}
