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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, GameButtonListener, AccelerometerListener{
    
    private var droneNode :DroneNode?
    private var accelerometer : Accelerometer?
    private var planes = [PlaneNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var accelerator: GameButton!
    @IBOutlet weak var reverse: GameButton!
    
    @IBOutlet weak var ascend: GameButton!
    @IBOutlet weak var descend: GameButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self

        //Buttons delegate
        self.accelerator.delegate = self
        self.reverse.delegate = self
        self.ascend.delegate = self
        self.descend.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

        self.droneNode = getDroneNode()
        
        // Set the scene to the view
        if  (self.droneNode != nil) {
            sceneView.scene.rootNode.addChildNode(self.droneNode!)
        }
        
        //Add accelerometer listener
        self.accelerometer = Accelerometer()
        self.accelerometer!.delegate = self
        
        
        self.addEgg(x: 1, y: 0, z: -2)
        self.addEgg(x: 0, y: 0, z: -2)
        self.addEgg(x: 1, y: 0, z: -2)
    }
    
    
    func addEgg(x: Float, y: Float, z: Float) {
        let eggScene = SCNScene(named: "art.scnassets/egg.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "egg", recursively: false))!
        eggNode.position = SCNVector3(x,y,z)
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        eggNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMaskCategory.drone.rawValue
        self.sceneView.scene.rootNode.addChildNode(eggNode)
    }
    
    func getDroneNode() -> DroneNode? {
        // Get drone model
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        guard let node = scene.rootNode.childNode(withName: "ship", recursively: false) else {
            return nil
        }
        
        return DroneNode(node: node)
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
    
    
    func clicked(button : UIButton) {
        
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
        print("rotation", orientation)
        if  (orientation < 0.1 && orientation > -0.1) {
            self.droneNode?.stop()
        }else{
            self.droneNode?.turn(orientation: orientation)
        }
    }
    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        var Target : SCNNode?
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            Target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            Target = nodeB
        }
        
        let confetti = SCNParticleSystem(named: "art.scnassets/Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry

        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        Target?.removeFromParentNode()
        
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
