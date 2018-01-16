//
//  Reducers.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - Application reducer

func gameReducer(action: Action, state: GameState?) -> GameState {
  var state = state ?? GameState()

  switch action {
    case let chooseWeaponAction as ChooseWeaponAction:
      switch chooseWeaponAction.player {
        case .local:
          state.localPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
        case .other:
          state.otherPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
      }
    case _ as CountdownTickAction:
      // TODO: Refactor player name handling
      let multipeerState = mainStore.state.multipeerState
      let localName = multipeerState.peerId.displayName
      let otherName = multipeerState.connectedPlayer!
      state = countdownReducer(state: state, playerNames: (localName, otherName))

    case _ as RequestStartGameAction:
      state.gameStatus = .pendingStartSent
    case _ as ReceivedStartGameAction:
      state.gameStatus = .pendingStartReceived
    case let respondStartAction as RespondStartGameAction:
      if respondStartAction.canStart {
        state.localPlay = Play(chosen: false, weapon: nil)
        state.otherPlay = Play(chosen: false, weapon: nil)
        state.result = nil
        state.gameStatus = .countdown
        state.statusMessage = Message.gameStart.rawValue
      } else {
        state.gameStatus = .finished
      }

    default:
      break
  }

  return state
}

// MARK: - Helpers

private func countdownReducer(state: GameState, playerNames: (localName: String, otherName: String)) -> GameState {
  var state = state

  if state.currentCountdown == nil {
    state.currentCountdown = 3
  } else {
    state.currentCountdown! -= 1

    if state.currentCountdown == 0 {
      state.result = resultFrom(player1: state.localPlay, player2: state.otherPlay)
      switch state.result! {
        case .draw:
          state.statusMessage = Message.draw.rawValue
        case .localWin:
          state.statusMessage = playerNames.localName + Message.playerWin.rawValue
        case .otherWin:
          state.statusMessage = playerNames.otherName + Message.playerWin.rawValue
        }
      state.currentCountdown = nil
      state.gameStatus = .finished
    }
  }

  return state
}

// swiftlint:disable cyclomatic_complexity
private func resultFrom(player1: Play, player2: Play) -> Result {

  // defaults to rock as everyone else
  let p1Weapon = player1.weapon ?? .rock
  let p2Weapon = player2.weapon ?? .rock

  switch p1Weapon {
    case .rock:
      switch p2Weapon {
        case .paper: return .otherWin
        case .scrissors: return .localWin
        default: return .draw
      }
    case .paper:
      switch p2Weapon {
        case .rock: return .localWin
        case .scrissors: return .otherWin
        default: return .draw
      }
    case .scrissors:
      switch p2Weapon {
        case .paper: return .localWin
        case .rock: return .otherWin
        default: return .draw
      }
  }
}
