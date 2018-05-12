//
//  GameViewController.swift
//  SuperSpaceMan
//
//  Created by Bret Williams on 5/12/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//


import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let skView = view as! SKView
        skView.showsFPS = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
