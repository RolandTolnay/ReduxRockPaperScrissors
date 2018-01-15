//
//  SessionActions.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 11/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

struct RequestStartGameAction: Action { }

struct ReceivedStartGameAction: Action { }

struct RespondStartGameAction: Action {
  
  var canStart: Bool
  var gameStatus: GameStatus?
  
  init(canStart: Bool, gameStatus: GameStatus? = nil) {
    self.canStart = canStart
    self.gameStatus = gameStatus
  }
}

// -

struct CountdownTickAction: Action { }

struct UpdateScoreAction: Action { }
