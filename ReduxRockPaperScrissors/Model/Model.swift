//
//  Model.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation

// MARK: - Enums
// MARK: - Model

enum Player {

  case local
  case other
}

enum Weapon {

  case rock
  case paper
  case scrissors
}

enum Result {

  case draw
  case localWin
  case otherWin
}

enum GameStatus {

  case finished
  case pendingStartSent
  case pendingStartReceived
  case countdown
}

typealias Score = [Player: Int]
typealias PlayerNames = (localPlayerName: String, otherPlayerName: String)

// MARK: - Utility

enum Message: String {

  case prepare = "Prepare to battle!"
  case playerChoose = "Choose weapon"
  case gameStart = "Rock Paper Scrissors GO!"
  case empty = ""

  case draw = "Wow it's a draw!"
  case playerWin = " WINS"
}

// MARK: - Structs

// The move a player has made
struct Play {

  var chosen: Bool
  var weapon: Weapon?
}
