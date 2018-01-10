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
    case _ as FoundPeerAction:
      if let session = state.session,
        let peerId = session.connectedPeers.first {
        
        state.connectedPlayer = peerId.displayName
      }
    
    default:
      break
  }
  
  return state
}
