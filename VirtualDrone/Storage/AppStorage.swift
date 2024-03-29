//
//  AppStorage.swift
//  VirtualDrone
//
//  Created by Miguel Perez on 26/08/2019.
//  Copyright © 2019 Miguel Pérez. All rights reserved.
//

import Foundation
import UIKit


class AppStorage : IAppStorage
{
    
    private let GAME_LEVEL = "game_level"
    
    func getCurrentGameLevel(completion: @escaping (Int) -> ())
    {
        
        let levelSaved = UserDefaults.standard.integer(forKey: GAME_LEVEL) + 1
        
        completion(levelSaved)
        
    }
    
    func increaseGameLevel() {
        
        let newLevel = UserDefaults.standard.integer(forKey: GAME_LEVEL) + 1
        UserDefaults.standard.set(newLevel, forKey: self.GAME_LEVEL)
    }
   
}

