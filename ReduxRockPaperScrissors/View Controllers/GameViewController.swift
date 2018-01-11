//
//  ViewController.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import UIKit
import ReSwift

class GameViewController: UIViewController, StoreSubscriber {
  
  // MARK:- IBOutlets
  
  @IBOutlet weak var otherPlayerNameLabel: UILabel!
  @IBOutlet weak var myPlayerNameLabel: UILabel!
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var playerLabel: UILabel!
  
  @IBOutlet weak var playerOneWeapon: UIImageView!
  @IBOutlet weak var playerTwoWeapon: UIImageView!
  
  @IBOutlet weak var playerOneScoreLabel: UILabel!
  @IBOutlet weak var playerTwoScoreLabel: UILabel!
  
  @IBOutlet weak var rockImageView: UIImageView!
  @IBOutlet weak var paperImageView: UIImageView!
  @IBOutlet weak var scrissorsImageView: UIImageView!
  
  @IBOutlet weak var rematchButton: UIButton!
  @IBOutlet weak var backgroundView: UIView!
  
  // MARK:- View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundView.backgroundColor = UIColor(displayP3Red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self)
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
  
  @IBAction func onStartGameTapped(_ sender: UIButton) {
    mainStore.dispatch(
      RequestStartGameAction()
    )
  }
  
  // MARK:- State handling
  
  func newState(state: AppState) {
    let gameState = state.gameState
    
    renderPlayerNames(from: state.multipeerState)
    
    statusLabel.text = gameState.statusMessage.rawValue
    playerLabel.text = gameState.playerMessage.rawValue
    
    updateScore(from: state)
    
    if gameState.player2Play.chosen {
      playerOneWeapon.image = imageFrom(weapon: gameState.player1Play.weapon, player: .one)
      playerTwoWeapon.image = imageFrom(weapon: gameState.player2Play.weapon, player: .two)
      grayscaleImagesForResult(gameState.result, playerOne: &playerOneWeapon.image!, playerTwo: &playerTwoWeapon.image!)
    } else {
      playerOneWeapon.image = gameState.player1Play.chosen ? UIImage(named: "ready") : UIImage(named: "none")
      playerTwoWeapon.image = UIImage(named: "none")
    }
    
    toggleWeaponInteraction(enabled: gameState.result == nil)
    toggleWeaponVisibility(isHidden: gameState.gameStatus != .countdown)
    rematchButton.isHidden = gameState.result == nil
    
    renderGameStatus(gameState.gameStatus)
  }
  
  // MARK:- Utility
  
  private func renderPlayerNames(from multipeerState: MultipeerState) {
    myPlayerNameLabel.text = UIDevice.current.name
    otherPlayerNameLabel.text = multipeerState.connectedPlayer
  }
  
  private func renderGameStatus(_ gameStatus: GameStatus) {
    switch gameStatus {
      case .pendingStartReceived:
        showRequestGameStartAlert() { didAccept in
          print("Can start game: \(didAccept)")
          // TODO: dispatch game start if accepted
        }
      
      default:
        break
    }
  }
  
  typealias AlertResult = (_ didAccept: Bool) -> Void
  
  private func showRequestGameStartAlert(completion: @escaping AlertResult) {
    let opponent = mainStore.state.multipeerState.connectedPlayer!
    let alert = UIAlertController(title: "Start game",
                                  message: "\(opponent) would like to start the game. Are you ready?",
                                  preferredStyle: .alert)
    let acceptAction = UIAlertAction(title: "Accept", style: .cancel) { action in
      completion(true)
    }
    let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
      completion(false)
    }
    
    alert.addAction(acceptAction)
    alert.addAction(declineAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func toggleWeaponInteraction(enabled: Bool) {
    rockImageView.isUserInteractionEnabled = enabled
    paperImageView.isUserInteractionEnabled = enabled
    scrissorsImageView.isUserInteractionEnabled = enabled
  }
  
  private func toggleWeaponVisibility(isHidden: Bool) {
    rockImageView.isHidden = isHidden
    paperImageView.isHidden = isHidden
    scrissorsImageView.isHidden = isHidden
    playerLabel.isHidden = isHidden
  }
  
  private func imageFrom(weapon: Weapon?, player: Player) -> UIImage? {
    guard let weapon = weapon else {
      return UIImage(named: "none")
    }
    
    let playerPrefix = player == .one ? "p1-" : "p2-"
    switch weapon {
    case .rock:
      return UIImage(named: playerPrefix+"rock")
    case .paper:
      return UIImage(named: playerPrefix+"paper")
    case .scrissors:
      return UIImage(named: playerPrefix+"scrissors")
    }
  }
  
  private func grayscaleImagesForResult(_ result: Result?, playerOne: inout UIImage, playerTwo: inout UIImage) {
    guard let result = result else { return }
    
    switch result {
    case .player1Win:
      playerTwo = convertToGrayScale(image: playerTwo)
      break;
    case .player2Win:
      playerOne = convertToGrayScale(image: playerOne)
      break;
    default:
      break;
    }
  }
  
  private func updateScore(from state: AppState) {
    guard let p1Score = state.score[Player.one],
      let p2Score = state.score[Player.two] else { return }
    
    playerOneScoreLabel.text = String(p1Score)
    playerTwoScoreLabel.text = String(p2Score)
  }
}

