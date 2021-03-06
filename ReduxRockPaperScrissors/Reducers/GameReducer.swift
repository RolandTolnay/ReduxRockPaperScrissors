//
//  Reducers.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift


// MARK: -
// MARK: Game Reducer
// --------------------
func gameReducer(action: Action, state: GameState?) -> GameState {
  var state = state ?? GameState()

  switch action {
  // Multipeer actions
    case _ as StopBrowsingPeersAction:
      state.gameStatus = .opponentLeft
    case let foundPeerAction as FoundPeerAction:
      state.gameStatus = .finished
      state.playerNames = foundPeerAction.playerNames
  // Start game actions
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
  // Weapon Actions
    case let chooseWeaponAction as ChooseWeaponAction:
      switch chooseWeaponAction.player {
      case .local:
        state.localPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
      case .other:
        state.otherPlay = Play(chosen: true, weapon: chooseWeaponAction.weapon)
      }
    case _ as CountdownTickAction:
      state = countdownReducer(state: state)
  // Score
    case _ as UpdateScoreAction:
      if let result = state.result {
        switch result {
          case .localWin:
            state.score[.local]! += 1
          case .otherWin:
            state.score[.other]! += 1
          default:
            break
          }
      }

    default:
      break
  }

  return state
}

// MARK: -
// MARK: Sub-Reducers
// --------------------
private func countdownReducer(state: GameState) -> GameState {
  var state = state

  if state.currentCountdown == nil {
    state.currentCountdown = 3
  } else {
    state.currentCountdown! -= 1

    if state.currentCountdown == 0 {
      state = resultReducer(state: state)
      state.currentCountdown = nil
      state.gameStatus = .finished
    }
  }

  return state
}

private func resultReducer(state: GameState) -> GameState {
  var state = state

  // Set default weapon to rock if none chosen
  if !state.localPlay.chosen {
    state.localPlay = Play(chosen: true, weapon: .rock)
  }
  if !state.otherPlay.chosen {
    state.otherPlay = Play(chosen: true, weapon: .rock)
  }
  state.result = resultFrom(localPlay: state.localPlay, otherPlay: state.otherPlay)
  switch state.result! {
    case .draw:
      state.statusMessage = Message.draw.rawValue
    case .localWin:
      state.statusMessage = state.playerNames.localPlayerName + Message.playerWin.rawValue
    case .otherWin:
      state.statusMessage = state.playerNames.otherPlayerName + Message.playerWin.rawValue
  }

  return state
}

// MARK: -
// MARK: Helpers
// --------------------
private func resultFrom(localPlay: Play, otherPlay: Play) -> Result {

  let localWeapon = localPlay.weapon!
  let otherWeapon = otherPlay.weapon!

  switch localWeapon {
    case .rock:
      switch otherWeapon {
        case .paper: return .otherWin
        case .scrissors: return .localWin
        default: return .draw
      }
    case .paper:
      switch otherWeapon {
        case .rock: return .localWin
        case .scrissors: return .otherWin
        default: return .draw
      }
    case .scrissors:
      switch otherWeapon {
        case .paper: return .localWin
        case .rock: return .otherWin
        default: return .draw
      }
  }
}
