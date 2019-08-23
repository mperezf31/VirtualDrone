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
        
    init(positionNode: SCNVector3) {
        super.init()

        let coinScene = SCNScene(named: "art.scnassets/CoinScene.scn")
        let coinNode = (coinScene?.rootNode.childNode(withName: "Coin", recursively: false))!
        self.addChildNode(coinNode)

        position = positionNode
        physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: coinNode, options: nil))
        physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        physicsBody?.contactTestBitMask = BitMaskCategory.drone.rawValue
        
        let rotationAction = SCNAction.rotate(by: CGFloat(360.degreesToRadians), around: SCNVector3(0, 1, 0), duration: 4)
        let action = SCNAction.repeatForever(rotationAction)
        runAction(action)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
