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

class ViewController: UIViewController, ARSCNViewDelegate, GameButtonListener, AccelerometerListener{
    
    private var droneNode :DroneNode?
    private var accelerometer : Accelerometer?
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var accelerator: GameButton!
    @IBOutlet weak var reverse: GameButton!
    
    @IBOutlet weak var ascend: GameButton!
    @IBOutlet weak var descend: GameButton!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.accelerator.delegate = self
        self.reverse.delegate = self
        self.ascend.delegate = self
        self.descend.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Get drone model
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        guard let node = scene.rootNode.childNode(withName: "ship", recursively: false) else {
            return
        }
        
        self.droneNode = DroneNode(node: node)
        
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(droneNode!)
        
        //Add accelerometer listener
        self.accelerometer = Accelerometer()
        self.accelerometer!.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
    
    
    
    
    
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
}
