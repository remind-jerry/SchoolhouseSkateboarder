//
//  GameViewController.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 18.01.2021.
//

import UIKit
import SpriteKit
import GameplayKit

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

        if let skView = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                scene.size = view.bounds.size
                print("SKView size: \(view.bounds.size)")
                // Present the scene
                skView.presentScene(scene)
            }

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

}
