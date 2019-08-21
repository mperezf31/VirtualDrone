//
//  BaseViewController.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 20/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class Accelerometer {
    
    private let motionManager = CMMotionManager()
    private var accelerationValues = [UIAccelerationValue(0), UIAccelerationValue(0)]
    
    public var delegate : AccelerometerListener?
    
    init() {
        setUpAccelerometer()
    }
    
    func setUpAccelerometer() {
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.3
            motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.accelerometerDidChange(acceleration: accelerometerData!.acceleration)
            })
            
        } else {
            print("Accelerometer not available in this device")
        }
        
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
        
        accelerationValues[1] = filtered(currentAcceleration: accelerationValues[1], UpdatedAcceleration: acceleration.y)
        accelerationValues[0] = filtered(currentAcceleration: accelerationValues[0], UpdatedAcceleration: acceleration.x)
        
        if accelerationValues[0] < -0.6 {
            self.delegate?.orientationDeviceChange(orientation: Float(accelerationValues[1]))
            print(" ->\(+accelerationValues[1])")

        }

    }
    
    func filtered(currentAcceleration: Double, UpdatedAcceleration: Double) -> Double {
        let kfilteringFactor = 0.5
        let res =  UpdatedAcceleration * kfilteringFactor + currentAcceleration * (1 - kfilteringFactor)
        return res
    }
    
}

protocol AccelerometerListener {
    func orientationDeviceChange(orientation : Float)
}
