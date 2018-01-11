//
//  SessionActions.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 11/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

struct RematchAction: Action { }

struct StartGameAction: Action {
  
  var gameStatus: GameStatus?
}

struct RequestStartGameAction: Action { }

struct ReceivedStartGameAction: Action { }

// -

struct CountdownTickAction: Action { }
