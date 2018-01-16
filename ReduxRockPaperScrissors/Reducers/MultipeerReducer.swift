//
//  MultipeerReducer.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift
import MultipeerConnectivity

// swiftlint:disable cyclomatic_complexity
func multipeerReducer(action: Action, state: MultipeerState?) -> MultipeerState {
  var state = state ?? MultipeerState()

  switch action {
  // Multipeer
    case _ as BrowsePeersAction:
      state.session = MCSession(peer: state.peerId, securityIdentity: nil, encryptionPreference: .required)
      state.session?.delegate = state.sessionService
    case _ as StopBrowsingPeers:
      state.session = nil
      if state.connectedPlayer != nil {
        state.connectedPlayer = nil
        state.sessionService.sendMultipeerAction(.leftGame)
      }
    case _ as FoundPeerAction:
      if let session = state.session,
        let peerId = session.connectedPeers.first {

        state.connectedPlayer = peerId.displayName
      }
  // Start game requests
    case _ as RequestStartGameAction:
      state.sessionService.sendMultipeerAction(.gameStartRequest)
    case let respondStartAction as RespondStartGameAction:
      if let gameStatus = respondStartAction.gameStatus,
        gameStatus == .pendingStartReceived {

        let multipeerAction: MultipeerAction =
          respondStartAction.canStart ? .gameStartApproved : .gameStartDeclined
        state.sessionService.sendMultipeerAction(multipeerAction)
      }
  // Weapon chosen
    case let chooseWeaponAction as ChooseWeaponAction:
      if chooseWeaponAction.player == .local {
        switch chooseWeaponAction.weapon {
          case .paper:
            state.sessionService.sendMultipeerAction(.chosenPaper)
          case .rock:
            state.sessionService.sendMultipeerAction(.chosenRock)
          case .scrissors:
            state.sessionService.sendMultipeerAction(.chosenScrissors)
        }
      }

      default:
        break
  }

  return state
}
