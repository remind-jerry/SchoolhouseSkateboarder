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

        if let skScene = SKScene(fileNamed: "GameScene") {
            let skView = view as! SKView
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true

            // Set the scale mode to scale to fit the window
            skScene.scaleMode = .resizeFill

            // Present the scene
            skView.presentScene(skScene)
        }
    }

}
