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
    case _ as ChooseWeaponAction:
      if let result = state.gameState.result {
        switch result {
          case .player1Win:
            state.score[.me]! += 1
          case .player2Win:
            state.score[.other]! += 1
          default:
            break
        }
      }
    default:
      break;
  }
  
  return state
}
