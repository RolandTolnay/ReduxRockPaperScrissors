//
//  State.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType {
  
  // In real-life apps this might contain other substates
  // ex. authenticationState, navigationState, error object
  
  var gameState: GameState
  var score: Score
  
  init() {
    self.gameState = GameState()
    self.score = [.one:0,
                  .two:0]
  }
}


