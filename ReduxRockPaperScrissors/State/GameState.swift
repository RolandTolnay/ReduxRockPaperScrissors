//
//  GameState.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 14/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

struct GameState: StateType {
  
  // Messages on main screen
  var statusMessage: Message
  var playerMessage: Message
  
  // Player who moves next
  var turn: Turn
  
  // Weapon choice of players
  var player1Play: Play
  var player2Play: Play
  
  // Result of the match
  var result: Result?
  
  init() {
    self.statusMessage = .prepare
    self.playerMessage = .playerChoose
    
    self.turn = Turn(player: .one)
    self.player1Play = Play(chosen: false, weapon: nil)
    self.player2Play = Play(chosen: false, weapon: nil)
  }
}
