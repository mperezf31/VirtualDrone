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
    
    private var droneNode :DroneNode?
    private var accelerometer : Accelerometer?
    private var planes = [PlaneNode]()
    
    private var initialCoins = [String]()

    private var caughtCoins = [String]()

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numCoinsLabel: UILabel!
    
    @IBOutlet weak var accelerator: GameButton!
    @IBOutlet weak var reverse: GameButton!
    @IBOutlet weak var ascend: GameButton!
    @IBOutlet weak var descend: GameButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        addButtonDelegates()
        
        serUpAccelerometer()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        restartGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
        
        self.droneNode = addDroneNode(dronePosition: self.getPointOfView())
        self.addTargets(numTargets: 3)
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

        for i in 1...numTargets {
            let targetName = "target_\(i)"
            
            // let positionNode1 = SCNVector3(x: Float.random(in: -2...2), y: Float.random(in: -2...2), z: Float.random(in: -3...(-1)))
            let positionNode1 = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: -2)
            
            let target = TargetNode(positionNode: positionNode1)
            target.name = targetName
            self.sceneView.scene.rootNode.addChildNode(target)
            
            self.initialCoins.append(targetName)
        }
        
        updateNumCoins()
    }
    
    private func updateNumCoins(){
        self.numCoinsLabel.text = String(String(self.caughtCoins.count) + "\\" + String(self.initialCoins.count))
    }

    
    func clicked(button : UIButton) {
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
            checkFinishGame()
            
            let confetti = AnimationNode(position: contact.contactPoint)
            self.sceneView.scene.rootNode.addChildNode(confetti)
            target?.removeFromParentNode()
        }

    }
    
    private func checkFinishGame(){
        
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
    

    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
     
     if (anchor is ARPlaneAnchor) {
     let plane = PlaneNode(anchor: anchor as! ARPlaneAnchor)
     self.planes.append(plane)
     node.addChildNode(plane)
     }
     }
     
     func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
     
     if(anchor is ARPlaneAnchor){
     let plane = self.planes.filter { plane in
     return plane.anchor.identifier == anchor.identifier
     }.first
     
     if plane != nil {
     plane?.update(anchor: anchor as! ARPlaneAnchor)
     }
     }
     
     }
     
     func session(_ session: ARSession, didFailWithError error: Error) {
     // Present an error message to the user
     
     }
     
     func sessionWasInterrupted(_ session: ARSession) {
     // Inform the user that the session has been interrupted, for example, by presenting an overlay
     
     }
     
     func sessionInterruptionEnded(_ session: ARSession) {
     // Reset tracking and/or remove existing anchors if consistent tracking is required
     
     }
     */
    
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
