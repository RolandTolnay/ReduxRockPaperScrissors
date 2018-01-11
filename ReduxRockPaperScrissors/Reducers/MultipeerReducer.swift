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

func multipeerReducer(action: Action, state: MultipeerState?) -> MultipeerState {
  var state = state ?? MultipeerState()
  
  switch action {
    case _ as BrowsePeersAction:
      state.session = MCSession(peer: state.peerId, securityIdentity: nil, encryptionPreference: .required)
      state.session?.delegate = state.sessionService
    case _ as StopBrowsingPeers:
      state.session = nil
    case _ as FoundPeerAction:
      if let session = state.session,
        let peerId = session.connectedPeers.first {
        
        state.connectedPlayer = peerId.displayName
      }
    
    case _ as RequestStartGameAction:
      state.sessionService.sendMultipeerAction(.gameStartRequest)
    case let startGameAction as StartGameAction:
      if let gameStatus = startGameAction.gameStatus,
        gameStatus == .pendingStartReceived {
        
        state.sessionService.sendMultipeerAction(.gameStartApproved)
      }
    
    case let chooseWeaponAction as ChooseWeaponAction:
      if chooseWeaponAction.player == .me {
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
