//
//  DroneNode.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 20/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//


import SceneKit

class DroneNode :SCNNode {
    
    var droneNode :SCNNode
    
    private var velocity = 10
    
    init(dronePosition : SCNVector3, droneOrientation : SCNVector4) {
        
        //let scene = SCNScene(named: "Drone.usdz")!
       // let node = scene.rootNode.childNode(withName: "toy_biplane", recursively: false)

        let scene = SCNScene(named: "art.scnassets/Drone.scn")!
        let node = scene.rootNode.childNode(withName: "helicopter", recursively: false)
        let nodeRotorR = scene.rootNode.childNode(withName: "Rotor_R", recursively: true)
        let nodeRotorL = scene.rootNode.childNode(withName: "Rotor_L", recursively: true)
        let rotationAction = SCNAction.rotate(by: CGFloat(360.degreesToRadians), around: SCNVector3(0, 1, 0), duration: 2)
        let action = SCNAction.repeatForever(rotationAction)
        nodeRotorR?.runAction(action)
        nodeRotorL?.runAction(action)

        self.droneNode = node!
        
        super.init()
        
        self.addChildNode(self.droneNode)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = BitMaskCategory.drone.rawValue
        self.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        
        self.position = dronePosition
        self.orientation = droneOrientation
        
    }
    
    func accelerate() {
        applyForce(forceY: 0,forceZ: -velocity)
    }
    
    func reverse() {
        applyForce(forceY: 0,forceZ: velocity)
    }
    
    func ascend() {
        applyForce(forceY: velocity, forceZ: 0)
    }
    
    func descend() {
        applyForce(forceY: -velocity, forceZ: 0)
    }
    
    
    
    func turn(orientation: Float) {
        if orientation > 0 {
            self.physicsBody?.applyTorque(SCNVector4(0,orientation*17,0,1), asImpulse: false)
            
        }else{
            self.physicsBody?.applyTorque(SCNVector4(0,orientation*17,0,1), asImpulse: false)
        }
    }
    
    func stop() {
        self.physicsBody?.clearAllForces()
    }
    
    private func applyForce(forceY : Int, forceZ : Int) {
        
        let force = simd_make_float4(0,Float(forceY),Float(forceZ),0)
        let rotatedForce = simd_mul(self.presentation.simdTransform, force)
        let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        self.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

