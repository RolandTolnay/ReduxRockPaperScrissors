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

  var gameState: GameState
  var multipeerState: MultipeerState

  init() {
    self.gameState = GameState()
    self.multipeerState = MultipeerState()
  }
}
