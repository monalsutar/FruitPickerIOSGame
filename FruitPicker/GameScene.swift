import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var fruits: [String] = ["apple", "watermelon", "cherry", "grapes", "orange"]
    private var score = 0
    private var scoreLabel: SKLabelNode?
    private var quitButton: SKSpriteNode?
    private var playAgainButton: SKSpriteNode?
    private var currentFruitNameLabel: SKLabelNode?
    private var currentFruitName: String?
    private var wrongSelections = 0
    private let maxWrongSelections = 5
    private var fruitChangeTimer: Timer?
    private var nameChangeTimer: Timer?
    private var wrongSelectionLabel: SKLabelNode?

    // Load sound actions
    private let correctSound = SKAction.playSoundFileNamed("sound1.mp3", waitForCompletion: false)
    private let wrongSound = SKAction.playSoundFileNamed("sound2.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .white
        
        // Set up the score label
        self.scoreLabel = SKLabelNode(fontNamed: "Arial")
        self.scoreLabel?.fontSize = 24
        self.scoreLabel?.fontColor = .black
        self.scoreLabel?.position = CGPoint(x: self.size.width - 100, y: self.size.height - 50)
        self.scoreLabel?.text = "Score: \(score)"
        if let scoreLabel = self.scoreLabel {
            self.addChild(scoreLabel)
        }
        
        // Set up the quit button
        self.quitButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 50))
        self.quitButton?.position = CGPoint(x: self.size.width - 50, y: 50)
        self.quitButton?.name = "quitButton"
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = "Quit"
        label.fontSize = 16
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -8)
        self.quitButton?.addChild(label)
        if let quitButton = self.quitButton {
            self.addChild(quitButton)
        }
        
        // Set up the current fruit name label
        self.currentFruitNameLabel = SKLabelNode(fontNamed: "Arial")
        self.currentFruitNameLabel?.fontSize = 24
        self.currentFruitNameLabel?.fontColor = .black
        self.currentFruitNameLabel?.position = CGPoint(x: 100, y: self.size.height - 50)
        self.currentFruitNameLabel?.text = "Fruit: -"
        if let currentFruitNameLabel = self.currentFruitNameLabel {
            self.addChild(currentFruitNameLabel)
        }
        
        // Set up the wrong selection count label
        self.wrongSelectionLabel = SKLabelNode(fontNamed: "Arial")
        self.wrongSelectionLabel?.fontSize = 18
        self.wrongSelectionLabel?.fontColor = .black
        self.wrongSelectionLabel?.position = CGPoint(x: 100, y: 50)
        self.wrongSelectionLabel?.text = "Wrong: \(wrongSelections)"
        if let wrongSelectionLabel = self.wrongSelectionLabel {
            self.addChild(wrongSelectionLabel)
        }
        
        // Start the game
        startGame()
    }
    
    private func startGame() {
        self.wrongSelections = 0
        self.score = 0
        self.scoreLabel?.text = "Score: \(score)"
        self.wrongSelectionLabel?.text = "Wrong: \(wrongSelections)"
        
        // Start spawning fruits
        self.fruitChangeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(spawnFruit), userInfo: nil, repeats: true)
        
        // Start changing fruit names every 10 seconds
        self.nameChangeTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateFruitName), userInfo: nil, repeats: true)
        
        // Update the fruit name initially
        updateFruitName()
    }
    
    @objc private func spawnFruit() {
        let fruitName = fruits.randomElement()!
        let fruit = SKSpriteNode(imageNamed: fruitName) // Use image from asset catalog
        fruit.setScale(0.2)
        fruit.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: self.size.height + fruit.size.height)
        fruit.name = fruitName
        self.addChild(fruit)
        
        let moveDown = SKAction.moveBy(x: 0, y: -self.size.height - fruit.size.height, duration: TimeInterval(CGFloat.random(in: 2...5)))
        let remove = SKAction.removeFromParent()
        fruit.run(SKAction.sequence([moveDown, remove]))
    }
    
    @objc private func updateFruitName() {
        // Set a new fruit name for the user to guess
        if let newFruitName = fruits.randomElement() {
            self.currentFruitName = newFruitName
            self.currentFruitNameLabel?.text = "Fruit: \(newFruitName)"
            self.currentFruitNameLabel?.fontColor = .black
        }
    }
    
    private func highlightCorrectFruitName() {
        // Highlight the correct fruit name by changing its color and adding a pulse effect
        let highlight = SKAction.sequence([
            SKAction.run { self.currentFruitNameLabel?.fontColor = .green },
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        self.currentFruitNameLabel?.run(highlight)
    }
    
    private func displayWrongSelectionMessage() {
        let wrongMessage = SKLabelNode(fontNamed: "Arial")
        wrongMessage.text = "Wrong Selection!"
        wrongMessage.fontSize = 24
        wrongMessage.fontColor = .red
        wrongMessage.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(wrongMessage)
        
        let fadeOut = SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ])
        wrongMessage.run(fadeOut)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        if let node = self.atPoint(location) as? SKSpriteNode, let fruitName = node.name, fruitName == currentFruitName {
            node.removeFromParent()
            increaseScore()
            self.run(correctSound)  // Play correct selection sound
            highlightCorrectFruitName()  // Highlight the fruit name
            updateFruitName() // Update the fruit name immediately after a correct selection
        } else if let node = self.atPoint(location) as? SKSpriteNode, node.name == "quitButton" {
            // Quit game
            self.view?.presentScene(nil)
        } else if let node = self.atPoint(location) as? SKSpriteNode, node.name == "playAgainButton" {
            // Restart the game
            self.removeAllChildren()
            self.startGame()
        } else {
            // Incorrect selection
            wrongSelections += 1
            self.wrongSelectionLabel?.text = "Wrong: \(wrongSelections)"
            self.run(wrongSound)  // Play wrong selection sound
            displayWrongSelectionMessage()
            
            if wrongSelections >= maxWrongSelections {
                endGame()
            }
        }
    }
    
    private func increaseScore() {
        score += 1
        self.scoreLabel?.text = "Score: \(score)"
    }
    
    private func endGame() {
        self.isPaused = true
        self.fruitChangeTimer?.invalidate() // Stop spawning fruits
        self.nameChangeTimer?.invalidate() // Stop changing fruit names
        
        // Remove all fruit nodes
        self.enumerateChildNodes(withName: "*") { node, _ in
            if node.name != "quitButton" && node.name != "playAgainButton" {
                node.removeFromParent()
            }
        }

        // Display game over label
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over! Final Score: \(score)"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .black
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 50)
        self.addChild(gameOverLabel)

        // Display game over message for max wrong selections
        let gameOverMessage = SKLabelNode(fontNamed: "Arial")
        gameOverMessage.text = "Game Over! You reached max wrong selections."
        gameOverMessage.fontSize = 24
        gameOverMessage.fontColor = .red
        gameOverMessage.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 50)
        self.addChild(gameOverMessage)

        // Display reward based on score
        let rewardLabel = SKLabelNode(fontNamed: "Arial")
        rewardLabel.fontSize = 24
        rewardLabel.fontColor = .black
        rewardLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 100)

        var rewardMessage: String
        
        switch score {
        case 0..<5:
            rewardMessage = "Try Again!"
        case 5..<10:
            rewardMessage = "Good Job!"
        case 10..<15:
            rewardMessage = "Great Work!"
        default:
            rewardMessage = "Excellent!"
        }
        
        rewardLabel.text = rewardMessage
        self.addChild(rewardLabel)

        // Add a visual effect for game over (e.g., pulsating text)
        let pulse = SKAction.sequence([
            SKAction.scale(by: 1.1, duration: 0.5),
            SKAction.scale(by: 0.9, duration: 0.5)
        ])
        gameOverLabel.run(SKAction.repeatForever(pulse))

        // Add a play again button
        self.playAgainButton = SKSpriteNode(color: .green, size: CGSize(width: 100, height: 50))
        self.playAgainButton?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 150)
        self.playAgainButton?.name = "playAgainButton"
        let playAgainLabel = SKLabelNode(fontNamed: "Arial")
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 16
        playAgainLabel.fontColor = .white
        playAgainLabel.position = CGPoint(x: 0, y: -8)
        self.playAgainButton?.addChild(playAgainLabel)
        if let playAgainButton = self.playAgainButton {
            self.addChild(playAgainButton)
        }
    }
}
