//
//  IAppStorage.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 26/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation

protocol IAppStorage {
    
    func getCurrentGameLevel(completion: @escaping (Int) -> ())
    
    func increaseGameLevel()
    
}
