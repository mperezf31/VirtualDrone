//
//  ConfettiNode.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 22/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation
import SceneKit

class AnimationNode : SCNNode {
    
    init(position : SCNVector3) {
        super.init()
        
        let fire  = SCNParticleSystem(named: "art.scnassets/Fire.scnp", inDirectory: nil)
        fire?.loops = false
        fire?.particleLifeSpan = 4
        fire?.emitterShape = SCNSphere(radius: 0.05)
        
        self.addParticleSystem(fire!)
        self.position = position
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
