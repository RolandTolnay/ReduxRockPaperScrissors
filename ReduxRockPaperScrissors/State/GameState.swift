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
  var score: Score

  var gameStatus: GameStatus

  var statusMessage: String
  var playerMessage: String

  var localPlay: Play
  var otherPlay: Play

  var currentCountdown: Int?
  var result: Result?

  init() {
    self.playerNames = (localPlayerName: "Local", otherPlayerName: "Opponent")
    self.score = [.local: 0,
                  .other: 0]

    self.statusMessage = Message.prepare.rawValue
    self.playerMessage = Message.playerChoose.rawValue

    self.gameStatus = .opponentLeft
    self.localPlay = Play(chosen: false, weapon: nil)
    self.otherPlay = Play(chosen: false, weapon: nil)
  }
}
