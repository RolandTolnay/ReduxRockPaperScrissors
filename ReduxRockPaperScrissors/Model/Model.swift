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
  
  case one
  case two
}

enum Weapon {
  
  case rock
  case paper
  case scrissors
}

enum Result {
  
  case draw
  case player1Win
  case player2Win
}

enum GameStatus {
  
  case finished
  case pendingStartSent
  case pendingStartReceived
  case countdown
}

typealias Score = [Player:Int]

// MARK: - Utility

enum Message: String {
  
  case prepare = "Prepare to battle!"
  case player1Win = "Player 1 WINS"
  case player2Win = "Player 2 WINS"
  case playerChoose = "Choose weapon"
  case draw = "Wow it's a draw!"
  case empty = ""
}

// MARK: - Structs

// TODO Remove Turn
// The player who has to make the next move
struct Turn {
  
  var player: Player
}

// The move a player has made
struct Play {
  
  var chosen: Bool
  var weapon: Weapon?
}




