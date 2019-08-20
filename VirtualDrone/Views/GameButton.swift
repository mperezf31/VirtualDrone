//
//  GameButton.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 19/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class GameButton : UIButton {
    
    public var delegate : GameButtonListener?
    
    private var timer :Timer!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer :Timer) in
            self?.delegate?.clicked(button: self!)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.clickedEnd(button: self)
        self.timer.invalidate()
    }
    
}


protocol GameButtonListener {
    func clicked( button:UIButton)
    func clickedEnd(button:UIButton)
}
