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
  var statusMessage: String
  var playerMessage: Message

  var gameStatus: GameStatus

  // Weapon choice of players
  var myPlay: Play
  var otherPlay: Play

  var currentCountdown: Int?

  // Result of the match
  var result: Result?

  init() {
    self.statusMessage = Message.prepare.rawValue
    self.playerMessage = .playerChoose

    self.gameStatus = .finished
    self.myPlay = Play(chosen: false, weapon: nil)
    self.otherPlay = Play(chosen: false, weapon: nil)
  }
}
