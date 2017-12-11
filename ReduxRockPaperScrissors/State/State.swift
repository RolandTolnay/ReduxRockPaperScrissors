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
  
  // Messages on main screen
  var statusMessage: Message
  var playerMessage: Message
  // If text is dynamic based on content, it is handled by the viewcontroller
  
  // Player who moves next
  var turn: Turn
  // Weapon choice of players
  var player1Play: Play
  var player2Play: Play
  // Result of the match
  var result: Result?
  
  init() {
    // initial state
    self.statusMessage = .prepare
    self.playerMessage = .player1Choose
    
    self.turn = Turn(player: .one)
    self.player1Play = Play(chosen: false, weapon: nil)
    self.player2Play = Play(chosen: false, weapon: nil)
  }
}


