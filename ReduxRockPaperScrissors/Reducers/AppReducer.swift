//
//  AppReducer.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 14/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
  var state = state ?? AppState()

  switch action {
    case _ as StopBrowsingPeersAction:
      state.gameState = GameState()

    default:
      state.gameState = gameReducer(action: action, state: state.gameState)
  }
  state.multipeerState = multipeerReducer(action: action, state: state.multipeerState)

  return state
}
