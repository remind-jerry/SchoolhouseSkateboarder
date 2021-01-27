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

        if let view = view as? SKView {
            let scene = GameScene()
            scene.scaleMode = .resizeFill

            view.showsFPS = true
            view.showsNodeCount = true
            view.ignoresSiblingOrder = true

            view.presentScene(scene)
        }
    }

}
