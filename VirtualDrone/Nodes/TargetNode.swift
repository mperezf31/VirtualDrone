//
//  TargetNode.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 21/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class TargetNode :SCNNode {
        
    init(targetNode: SCNNode,position: SCNVector3) {
        super.init()
        self.addChildNode(targetNode)

        self.position = position
        self.physicsBody = SCNPhysicsBody.static()
        self.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        self.physicsBody?.contactTestBitMask = BitMaskCategory.drone.rawValue
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

