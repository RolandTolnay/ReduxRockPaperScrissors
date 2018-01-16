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

  state.gameState = gameReducer(action: action, state: state.gameState)
  state.multipeerState = multipeerReducer(action: action, state: state.multipeerState)

  switch action {
    case _ as UpdateScoreAction:
      if let result = state.gameState.result {
        switch result {
          case .localWin:
            state.score[.local]! += 1
          case .otherWin:
            state.score[.other]! += 1
          default:
            break
        }
      }
    case _ as StopBrowsingPeers:
      state.score = [.local: 0,
                    .other: 0]
      state.gameState = GameState()
    default:
      break
  }

  return state
}
