//
//  BluetoothViewController.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import ReSwift

class MultipeerViewController: UIViewController, StoreSubscriber {

  @IBOutlet weak var backgroundView: UIView!

  var advertiserAssistant: MCAdvertiserAssistant?

  // MARK: -
  // MARK: Lifecycle
  // --------------------

  override func viewDidLoad() {
    backgroundView.backgroundColor = UIColor(displayP3Red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self) { state in
      state.select { $0.multipeerState }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  // MARK: -
  // MARK: Tap handlers
  // --------------------

  @IBAction func onLookForDevicesTapped(_ sender: UIButton) {
    mainStore.dispatch(
      BrowsePeersAction()
    )
  }

  // MARK: -
  // MARK: Redux Render
  // --------------------

  func newState(state: MultipeerState) {
    if state.connectedPlayer != nil {
      navigateToGameScreen()
      return
    }

    if let session = state.session,
      state.connectedPlayer == nil {

      let serviceType = state.serviceType
      advertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
      advertiserAssistant?.start()

      let peerBrowser = MCBrowserViewController(serviceType: serviceType, session: session)
      peerBrowser.minimumNumberOfPeers = 1
      peerBrowser.maximumNumberOfPeers = 1
      peerBrowser.delegate = self
      self.present(peerBrowser, animated: true, completion: nil)
    }
  }

  // MARK: -
  // MARK: Utility
  // --------------------

  private func navigateToGameScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let gameViewController =
      storyboard.instantiateViewController(withIdentifier: String(describing: GameViewController.self))
    self.present(gameViewController, animated: true, completion: nil)
  }

  fileprivate func stopAdvertising() {
    advertiserAssistant?.stop()
    advertiserAssistant = nil
  }

  deinit {
    stopAdvertising()
  }
}

// MARK: -
// MARK: MCBrowserViewControllerDelegate
// --------------------
extension MultipeerViewController: MCBrowserViewControllerDelegate {

  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {

    let localName = browserViewController.session.myPeerID.displayName
    let otherName = browserViewController.session.connectedPeers.first?.displayName ?? "Opponent"
    mainStore.dispatch(
      FoundPeerAction(playerNames: (localPlayerName: localName, otherPlayerName: otherName))
    )
    DispatchQueue.main.async {
      browserViewController.dismiss(animated: true) {
        self.stopAdvertising()
      }
    }
  }

  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {

    mainStore.dispatch(
      StopBrowsingPeersAction()
    )
    DispatchQueue.main.async {
      browserViewController.dismiss(animated: true) {
        self.stopAdvertising()
      }
    }
  }
}
