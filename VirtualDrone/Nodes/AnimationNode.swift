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
    
    init(shape : SCNGeometry, position : SCNVector3) {
        super.init()
        
        let confetti = SCNParticleSystem(named: "art.scnassets/Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = shape
        
        self.addParticleSystem(confetti!)
        self.position = position
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
