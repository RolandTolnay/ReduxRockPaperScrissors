//
//  Reducers.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

// MARK:- Application reducer

func gameReducer(action: Action, state: GameState?) -> GameState {
  
  // create initial state if none provided
  var state = state ?? GameState()
  
  switch action {
    case let chooseWeaponAction as ChooseWeaponAction:
      switch chooseWeaponAction.player {
        case .me:
          state.myPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
        case .other:
          state.otherPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
      }
    case _ as CountdownTickAction:
      state = countdownReducer(state: state)

    case _ as RematchAction:
      state = GameState()
    case _ as StartGameAction:
      state.myPlay = Play(chosen: false, weapon: nil)
      state.otherPlay = Play(chosen: false, weapon: nil)
      state.result = nil
      state.gameStatus = .countdown
    
    case _ as RequestStartGameAction:
      state.gameStatus = .pendingStartSent
    case _ as ReceivedStartGameAction:
      state.gameStatus = .pendingStartReceived
    
    default:
      break
  }
  
  return state
}

// MARK:- Helpers

private func countdownReducer(state: GameState) -> GameState {
  var state = state
  
  if state.currentCountdown == nil {
    state.currentCountdown = 3
  } else {
    state.currentCountdown! -= 1
    if state.currentCountdown == 0 {
      state.result = resultFrom(player1: state.myPlay, player2: state.otherPlay)
      switch state.result! {
        case .draw:
          state.statusMessage = .draw
        case .player1Win:
          state.statusMessage = .player1Win
        case .player2Win:
          state.statusMessage = .player2Win
        }
      state.currentCountdown = nil
      state.gameStatus = .finished
    }
  }
  
  return state
}

private func resultFrom(player1: Play, player2: Play) -> Result {
  
  // defaults to rock as everyone else
  let p1Weapon = player1.weapon ?? .rock
  let p2Weapon = player2.weapon ?? .rock
  
  switch p1Weapon {
    case .rock:
      switch p2Weapon {
        case .paper: return .player2Win
        case .scrissors: return .player1Win
        default: return .draw
      }
    case .paper:
      switch p2Weapon {
        case .rock: return .player1Win
        case .scrissors: return .player2Win
        default: return .draw
      }
    case .scrissors:
      switch p2Weapon {
        case .paper: return .player1Win
        case .rock: return .player2Win
        default: return .draw
      }
  }
}
