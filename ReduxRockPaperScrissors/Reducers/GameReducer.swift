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
      // TODO: Refactor player name handling
      let multipeerState = mainStore.state.multipeerState
      let myName = multipeerState.peerId.displayName
      let otherName = multipeerState.connectedPlayer!
      state = countdownReducer(state: state, playerNames: (myName, otherName))

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

private func countdownReducer(state: GameState, playerNames: (myName: String, otherName: String)) -> GameState {
  var state = state
  
  if state.currentCountdown == nil {
    state.currentCountdown = 3
  } else {
    state.currentCountdown! -= 1
    
    if state.currentCountdown == 0 {
      state.result = resultFrom(player1: state.myPlay, player2: state.otherPlay)
      switch state.result! {
        case .draw:
          state.statusMessage = Message.draw.rawValue
        case .myWin:
          state.statusMessage = playerNames.myName + Message.playerWin.rawValue
        case .otherWin:
          state.statusMessage = playerNames.otherName + Message.playerWin.rawValue
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
        case .paper: return .otherWin
        case .scrissors: return .myWin
        default: return .draw
      }
    case .paper:
      switch p2Weapon {
        case .rock: return .myWin
        case .scrissors: return .otherWin
        default: return .draw
      }
    case .scrissors:
      switch p2Weapon {
        case .paper: return .myWin
        case .rock: return .otherWin
        default: return .draw
      }
  }
}
