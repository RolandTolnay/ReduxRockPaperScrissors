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
  
  var advertiserAssistant: MCAdvertiserAssistant?
  
  override func viewDidLoad() {
    super.viewDidLoad()

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
  
  @IBAction func onLookForDevicesTapped(_ sender: UIButton) {
    mainStore.dispatch(
      BrowsePeersAction()
    )
  }
  
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
  
  private func navigateToGameScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let gameViewController = storyboard.instantiateViewController(withIdentifier: String(describing: GameViewController.self))
    self.present(gameViewController, animated: true, completion: nil)
  }
  
  fileprivate func stopAdvertising() {
    advertiserAssistant?.stop()
    advertiserAssistant = nil
  }
}

extension MultipeerViewController: MCBrowserViewControllerDelegate {
  
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {

    DispatchQueue.main.async {
      browserViewController.dismiss(animated: true) {
        self.stopAdvertising()
        mainStore.dispatch(
          FoundPeerAction()
        )
      }
    }
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {

    DispatchQueue.main.async {
      browserViewController.dismiss(animated: true) {
        self.stopAdvertising()
      }
    }
  }
}
