//
//  ViewController.swift
//  Super Iashu
//
//  Created by Alexandru Rosianu on 05/09/2018.
//  Copyright © 2018 AR. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill 
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
//            view.showsFields = true
//            view.showsPhysics = true
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }
}

