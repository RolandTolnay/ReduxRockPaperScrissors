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

  var playerNames: PlayerNames

  // Messages on main screen
  var statusMessage: String
  var playerMessage: String

  var gameStatus: GameStatus

  // Weapon choice of players
  var localPlay: Play
  var otherPlay: Play

  var currentCountdown: Int?

  // Result of the match
  var result: Result?

  init() {
    self.playerNames = (localPlayerName: "Local", otherPlayerName: "Opponent")

    self.statusMessage = Message.prepare.rawValue
    self.playerMessage = Message.playerChoose.rawValue

    self.gameStatus = .finished
    self.localPlay = Play(chosen: false, weapon: nil)
    self.otherPlay = Play(chosen: false, weapon: nil)
  }
}
