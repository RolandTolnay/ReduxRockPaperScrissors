//
//  MultipeerSessionService.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerSessionService: NSObject {

  func sendMultipeerAction(_ multipeerAction: MultipeerAction) {
    print("sendMultipeerAction - \(multipeerAction.rawValue)")

    if let session = mainStore.state.multipeerState.session,
      session.connectedPeers.count > 0 {

      do {
        let actionString = multipeerAction.rawValue
        if let actionData = actionString.data(using: .utf8) {
          try session.send(actionData, toPeers: session.connectedPeers, with: .reliable)
        } else { throw MultipeerError.encoding }
      } catch let error {
        print("[ERROR] Unable to send \(multipeerAction.rawValue): \(error.localizedDescription)")
      }
    }
  }
}

extension MultipeerSessionService: MCSessionDelegate {

  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    print("didChangeState \(state)")
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    print("session:didReceiveData")
    if let receivedString = String(data: data, encoding: .utf8),
      let receivedAction = MultipeerAction(rawValue: receivedString) {

      DispatchQueue.main.async {
        switch receivedAction {
          case .gameStartRequest:
              mainStore.dispatch(
                ReceivedStartGameAction()
              )
          case .gameStartApproved:
            mainStore.dispatch(
              RespondStartGameAction(canStart: true)
            )
          case .gameStartDeclined:
            mainStore.dispatch(
              RespondStartGameAction(canStart: false)
            )
          case .leftGame:
            mainStore.dispatch(
              StopBrowsingPeers()
            )

          case .chosenPaper:
            mainStore.dispatch(
              ChooseWeaponAction(player: .other, weapon: .paper)
            )
          case .chosenRock:
            mainStore.dispatch(
              ChooseWeaponAction(player: .other, weapon: .rock)
            )
          case .chosenScrissors:
            mainStore.dispatch(
              ChooseWeaponAction(player: .other, weapon: .scrissors)
            )
        }
      }
    } else {
      print("[ERROR] Received unrecognized data from \(peerID.displayName)")
    }
  }

  func session(_ session: MCSession, didReceive stream: InputStream,
               withName streamName: String, fromPeer peerID: MCPeerID) {
    print("didReceiveInputStream")
  }

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID, with progress: Progress) {
    print("didStartReceivingResourceWithName")
  }

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    print("didFinishReceivingResourceWithName")
  }
}

private enum MultipeerError: Error, LocalizedError {
  case encoding

  var errorDescription: String? {
    switch self {
    case .encoding:
      return "Unable to encode action to data"
    }
  }
}
