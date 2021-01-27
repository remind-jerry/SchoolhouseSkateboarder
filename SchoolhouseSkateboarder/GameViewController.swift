//
//  GameViewController.swift
//  SchoolhouseSkateboarder
//
//  Created by Еременко Игорь on 18.01.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true

            let scene = GameScene()

            scene.scaleMode = .resizeFill

            view.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
