//
//  ViewController.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 19/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


enum ButtonsTags : Int {
    case accelerator = 1
    case reverse = 2
    case ascend = 3
    case descend = 4
    
}

enum BitMaskCategory: Int {
    case drone = 1
    case target = 2
}

class GameController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, GameButtonListener, AccelerometerListener{
    
    private let MAX_GAME_TIME = 190
    private let NUM_TARGETS = 8
    
    private var droneNode :DroneNode?
    private var accelerometer : Accelerometer?
    
    private var initialCoins = [String]()
    private var caughtCoins = [String]()
    private var timer :Timer?
    private var gameTime = 0 //Seconds
    private var appStorage : IAppStorage!
    private var currentLevel :Int = 0
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numCoinsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBAction func startGame(_ sender: Any) {
        self.messageView.isHidden = true
        self.restartGame()
    }
    
    @IBOutlet weak var accelerator: GameButton!
    @IBOutlet weak var reverse: GameButton!
    @IBOutlet weak var ascend: GameButton!
    @IBOutlet weak var descend: GameButton!
    
    @IBAction func restartButton(_ sender: Any) {
        if self.messageView.isHidden{
            restartGame()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        appStorage = AppStorage()
        
        addButtonDelegates()
        
        serUpAccelerometer()
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        getInitialGameLevel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // configuration.planeDetection = [.horizontal, .vertical]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        self.timer?.invalidate()
        
    }
    
    private func getInitialGameLevel(){
        self.appStorage.getCurrentGameLevel(){ level in
            self.currentLevel = level
            self.levelLabel.text = "Nivel \(self.currentLevel)"
            self.showInitialMessage()
        }
    }
    
    private func addButtonDelegates(){
        
        //Buttons delegate
        self.accelerator.delegate = self
        self.reverse.delegate = self
        self.ascend.delegate = self
        self.descend.delegate = self
    }
    
    private func serUpAccelerometer() {
        self.accelerometer = Accelerometer()
        self.accelerometer!.delegate = self
    }
    
    
    private func restartGame() {
        self.timer?.invalidate()

        self.gameTime = self.MAX_GAME_TIME - (self.currentLevel * 10)
        updateTime()
        self.removeAllNodes()
        
        self.droneNode = addDroneNode(dronePosition: self.getPointOfView())
        self.droneNode?.name = "drone"
        
        self.addTargets(numTargets: self.NUM_TARGETS + (self.currentLevel * 2) )
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer :Timer) in
            self?.gameTime -= 1
            self?.updateTime()
            
            if(self?.gameTime == 0){
                self?.finishGame(success: false)
            }
        })
        
    }
    
    private func removeAllNodes() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    private func addDroneNode(dronePosition: SCNVector3, droneOrientation: SCNVector4 = SCNVector4(0,0,0,0)) -> DroneNode? {
        // Get drone model
        let drone = DroneNode(dronePosition : dronePosition, droneOrientation : droneOrientation)
        
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(drone)
        return drone
    }
    
    private func addTargets(numTargets :  Int) {
        
        self.initialCoins.removeAll()
        self.caughtCoins.removeAll()
        
        let pointOfView  = self.getPointOfView()
        
        for i in 1...numTargets {
            let targetName = "target_\(i)"
            let positionNode : SCNVector3
            
            var zValue : Float = 0
            if pointOfView.z > 0 {
                zValue = pointOfView.z + Float.random(in: 1.5...3)
            }else{
                zValue = pointOfView.z - Float.random(in: 1.5...3)
            }
            
            
            if self.currentLevel > 5{
                
                positionNode = SCNVector3(x: pointOfView.x + Float.random(in: -1...1), y: pointOfView.y + Float.random(in: -1...1), z: zValue)
            }else{
                positionNode = SCNVector3(x: pointOfView.x + Float.random(in: -2...2), y: pointOfView.y + Float.random(in: -2...2), z: zValue)
            }
            
            let target = TargetNode(positionNode: positionNode)
            target.name = targetName
            self.sceneView.scene.rootNode.addChildNode(target)
            
            self.initialCoins.append(targetName)
        }
        
        updateNumCoins()
    }
    
    private func updateNumCoins(){
        DispatchQueue.main.async {
            self.numCoinsLabel.text = String(String(self.caughtCoins.count) + "\\" + String(self.initialCoins.count))
        }
    }
    
    private func updateTime() {
        DispatchQueue.main.async {
            self.timeLabel.text = "\(self.gameTime) s"
        }
        
        if self.gameTime > 10 {
            self.timeLabel.backgroundColor = self.view.tintColor
        }else{
            self.timeLabel.backgroundColor = UIColor.red
        }
        
    }
    
    private func checkDroneOrientation() {
        if self.droneNode?.presentation.orientation.x != 0 || self.droneNode?.presentation.orientation.z != 0 {
            let position = self.droneNode?.presentation.position
            let orientation = self.droneNode?.presentation.orientation
            if position != nil &&  orientation != nil {
                self.droneNode?.removeFromParentNode()
                self.droneNode =  addDroneNode(dronePosition: position!, droneOrientation: SCNVector4(0,orientation!.y,0,1))
            }
        }
    }
    
    private func getPointOfView() -> SCNVector3{
        guard let pointOfView = sceneView.pointOfView else {return SCNVector3(-0, 0, -0.1 )}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        return position
    }
    
    private func finishGame(success: Bool){
        self.timer?.invalidate()
        self.gameTime = 0
        
        if success{
            self.appStorage.increaseGameLevel()
            self.currentLevel += 1
            DispatchQueue.main.async {
                self.levelLabel.text = "Nivel \(self.currentLevel)"
            }
            showSuccessMessage()
        }else{
            showGameOverMessage()
        }
    }
    
    func clicked(button : UIButton) {
        guard self.messageView.isHidden else { return}
        
        checkDroneOrientation()
        
        if button.tag == ButtonsTags.accelerator.rawValue {
            self.droneNode?.accelerate()
        }else if button.tag == ButtonsTags.reverse.rawValue {
            self.droneNode?.reverse()
        }else if button.tag == ButtonsTags.ascend.rawValue{
            self.droneNode?.ascend()
        }else if button.tag == ButtonsTags.descend.rawValue{
            self.droneNode?.descend()
        }
    }
    
    func clickedEnd(button: UIButton) {
        self.droneNode?.stop()
    }
    
    func orientationDeviceChange(orientation: Float) {
        guard self.messageView.isHidden else { return}

        if  (orientation < 0.1 && orientation > -0.1) {
            self.droneNode?.stop()
        }else{
            self.droneNode?.turn(orientation: orientation)
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        var target : SCNNode?
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            target = nodeB
        }
        
        if (target?.name != nil && self.initialCoins.contains(target!.name!) && !self.caughtCoins.contains(target!.name!)){
            print("Se añade" + target!.name!)
            self.caughtCoins.append(target!.name!)
            updateNumCoins()
            
            let fire = AnimationNode(position: contact.contactPoint)
            self.sceneView.scene.rootNode.addChildNode(fire)
            target?.removeFromParentNode()
            
            if self.initialCoins.count == self.caughtCoins.count {
                finishGame(success: true)
            }
        }
        
    }
    
    func showInitialMessage() {
        showMessage( title: "VirtualNode",msg: "Captura todas las monedas de tu entorno antes de que se agote el tiempo. Mueve la cámara de un lado a otro antes de empezar para que se reconozca el entorno.")
    }
    
    
    private func showSuccessMessage() {
        showMessage( title: "Enhorabuena!!",msg: "Has conseguido atrapar todas las monedas antes de que se agotase el tiempo.\nA por el nivel \(self.currentLevel)")
    }
    
    private func showGameOverMessage() {
        showMessage(title: "Game Over!!",msg: "No has conseguido atrapar todas las monedas en el tiempo establecido.\n Reintentar nivel \(self.currentLevel)")
    }
    
    private func showMessage(title: String, msg : String){
        DispatchQueue.main.async {
            self.messageTitleLabel.text = title
            self.messageLabel.text = msg
            self.messageView.isHidden = false
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
