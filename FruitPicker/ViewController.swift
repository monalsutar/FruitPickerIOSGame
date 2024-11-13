import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene' as a SKScene
        let scene = GameScene(size: skView.bounds.size)
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        if let view = self.skView {
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Ensure the view's window handles mouse events
            if let window = view.window {
                window.acceptsMouseMovedEvents = true
            }
        }
    }
}
