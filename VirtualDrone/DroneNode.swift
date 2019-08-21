//
//  DroneNode.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 20/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//


import Foundation
import SceneKit

class DroneNode :SCNNode {
    
    var droneNode :SCNNode
    
    private var velocity = 10
    
    init(node: SCNNode) {
        
        self.droneNode = node
        super.init()
        
        self.addChildNode(self.droneNode)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
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

