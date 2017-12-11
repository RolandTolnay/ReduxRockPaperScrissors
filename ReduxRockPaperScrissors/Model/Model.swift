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

// MARK: - Utility

enum Message: String {
  
  case prepare = "Prepare to battle!"
  case player1Win = "Player 1 WINS"
  case player2Win = "Player 2 WINS"
  case player1Choose = "Player 1 - Choose weapon"
  case player2Choose = "Player 2 - Choose weapon"
  case draw = "Wow it's a draw!"
}

// MARK: - Structs

// The player who has to make the next move
struct Turn {
  
  var player: Player
}

// The move a player has made
struct Play {
  
  var chosen: Bool
  var weapon: Weapon?
}




