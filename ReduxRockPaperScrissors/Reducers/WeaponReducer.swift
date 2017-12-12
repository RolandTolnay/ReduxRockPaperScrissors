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

func weaponReducer(action: Action, state: AppState?) -> AppState {
  
  // create initial state if none provided
  var state = state ?? AppState()
  
  switch action {
    case let chooseWeaponAction as ChooseWeaponAction:
      let turn = state.turn
      switch turn.player {
        case .one:
          state = playerOneReducer(action: chooseWeaponAction, state: state)
        case .two:
          state = playerTwoReducer(action: chooseWeaponAction, state: state)
      }
    
    case _ as RematchAction:
        state = AppState()
    
    // case for each action type handled by reducer
    
    default:
      break;
  }
  
  return state
}

// MARK:- Helpers

private func playerOneReducer(action: ChooseWeaponAction, state: AppState) -> AppState {
  var state = state
  
  // create play
  let play = Play(chosen: true, weapon: action.weapon)
  state.player1Play = play
  
  // pass the turn to the next player
  state.turn = Turn(player: .two)
  
  // update message
  state.playerMessage = .player2Choose
  
  return state
}

private func playerTwoReducer(action: ChooseWeaponAction, state: AppState) -> AppState {
  var state = state
  
  // create play
  let play = Play(chosen: true, weapon: action.weapon)
  state.player2Play = play
  
  // update result
  state.result = resultFrom(player1: state.player1Play, player2: state.player2Play)
  
  // update message
  switch state.result! {
    case .draw:
      state.statusMessage = .draw
    case .player1Win:
      state.statusMessage = .player1Win
    case .player2Win:
      state.statusMessage = .player2Win
  }
  state.playerMessage = .player1Choose
  
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
