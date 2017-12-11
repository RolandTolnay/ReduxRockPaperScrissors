//
//  ViewController.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController, StoreSubscriber {
 
  // MARK:- IBOutlets
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var playerLabel: UILabel!
  
  @IBOutlet weak var playerOneWeapon: UIImageView!
  @IBOutlet weak var playerTwoWeapon: UIImageView!
  
  @IBOutlet weak var rockImageView: UIImageView!
  @IBOutlet weak var paperImageView: UIImageView!
  @IBOutlet weak var scrissorsImageView: UIImageView!
  
  @IBOutlet weak var rematchButton: UIButton!
  @IBOutlet weak var backgroundView: UIView!
  
  // MARK:- View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mainStore.subscribe(self)
    
    // sun flower - rgba(241, 196, 15,1.0)
    backgroundView.backgroundColor = UIColor(displayP3Red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    view.sendSubview(toBack: backgroundView)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  // MARK:- Tap handlers
  
  @IBAction func onRockTap(_ sender: UITapGestureRecognizer) {
    mainStore.dispatch(
      ChooseWeaponAction(weapon: .rock)
    )
  }
  @IBAction func onPaperTap(_ sender: UITapGestureRecognizer) {
    mainStore.dispatch(
      ChooseWeaponAction(weapon: .paper)
    )
  }
  @IBAction func onScrissorsTap(_ sender: Any) {
    mainStore.dispatch(
      ChooseWeaponAction(weapon: .scrissors)
    )
  }
  
  @IBAction func onRematchTapped(_ sender: UIButton) {
    mainStore.dispatch(
      RematchAction()
    )
  }
  
  // MARK:- State handling
  
  func newState(state: AppState) {
    // update messages
    statusLabel.text = state.statusMessage.rawValue
    playerLabel.text = state.playerMessage.rawValue
    
    // update weapons
    if state.player2Play.chosen {
      // reveal weapons
      playerOneWeapon.image = imageFrom(weapon: state.player1Play.weapon)
      playerTwoWeapon.image = imageFrom(weapon: state.player2Play.weapon)
      
      // rotate image
      playerOneWeapon.transform = playerOneWeapon.transform.rotated(by: CGFloat(CGFloat.pi/2))
      playerTwoWeapon.transform = playerTwoWeapon.transform.rotated(by: -CGFloat(CGFloat.pi/2))
    } else {
      // mark player 1 ready if chosen weapon
      playerOneWeapon.image = state.player1Play.chosen ? UIImage(named: "ready") : UIImage(named: "none")
      playerTwoWeapon.image = UIImage(named: "none")
    }
    
    // toggle weapon interaction
    toggleWeapons(enabled: state.result == nil)
    // toggle rematch button
    rematchButton.isHidden = state.result == nil
  }
  
  // MARK:- Utility
  
  private func toggleWeapons(enabled: Bool) {
    rockImageView.isUserInteractionEnabled = enabled
    paperImageView.isUserInteractionEnabled = enabled
    scrissorsImageView.isUserInteractionEnabled = enabled
  }
  
  private func imageFrom(weapon: Weapon?) -> UIImage? {
    guard let weapon = weapon else {
      return UIImage(named: "none")
    }
    switch weapon {
      case .rock:
        return UIImage(named: "rock")
      case .paper:
        return UIImage(named: "paper")
      case .scrissors:
        return UIImage(named: "scrissors")
    }
  }
}

