//
//  MultipeerState.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift
import MultipeerConnectivity

struct MultipeerState: StateType {
  
  let serviceType = "rt-rps-game"
  let peerId = MCPeerID(displayName: UIDevice.current.name)
  
  let sessionService = MultipeerSessionService()
  
  var session: MCSession?
  var connectedPlayer: String?
}
