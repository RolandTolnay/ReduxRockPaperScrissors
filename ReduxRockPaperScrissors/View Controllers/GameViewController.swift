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
  @IBOutlet weak var pendingStartLabel: UILabel!
  
  @IBOutlet weak var myPlayerWeapon: UIImageView!
  @IBOutlet weak var otherPlayerWeapon: UIImageView!
  
  @IBOutlet weak var myPlayerScoreLabel: UILabel!
  @IBOutlet weak var otherPlayerScoreLabel: UILabel!
  
  @IBOutlet weak var rockImageView: UIImageView!
  @IBOutlet weak var paperImageView: UIImageView!
  @IBOutlet weak var scrissorsImageView: UIImageView!
  
  @IBOutlet weak var startGameButton: UIButton!
  @IBOutlet weak var lowerBackgroundView: UIView!
  @IBOutlet weak var upperBackgroundView: UIView!
  
  var isCountdownRunning = false
  var countdownTimer = Timer()
  
  // MARK: -
  // MARK: Lifecycle
  // --------------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lowerBackgroundView.backgroundColor = UIColor(displayP3Red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
    upperBackgroundView.backgroundColor = UIColor(displayP3Red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    view.sendSubview(toBack: lowerBackgroundView)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  // MARK: -
  // MARK: Tap handlers
  // --------------------
  
  @IBAction func onRockTap(_ sender: UITapGestureRecognizer) {
    mainStore.dispatch(
      ChooseWeaponAction(player: .me, weapon: .rock)
    )
  }
  @IBAction func onPaperTap(_ sender: UITapGestureRecognizer) {
    mainStore.dispatch(
      ChooseWeaponAction(player: .me, weapon: .paper)
    )
  }
  @IBAction func onScrissorsTap(_ sender: Any) {
    mainStore.dispatch(
      ChooseWeaponAction(player: .me, weapon: .scrissors)
    )
  }
  
  @IBAction func onStartGameTapped(_ sender: UIButton) {
    mainStore.dispatch(
      RequestStartGameAction()
    )
  }
  
  // MARK: -
  // MARK: Render state
  // --------------------
  
  func newState(state: AppState) {
    let gameState = state.gameState
    
    renderPlayerNames(from: state.multipeerState)
    
    statusLabel.text = gameState.statusMessage
    playerLabel.text = gameState.playerMessage.rawValue
    
    if let countdown = gameState.currentCountdown {
      statusLabel.text = String(countdown)
    }
    
    updateScore(from: state)
    
    if gameState.result != nil {
      // TODO: Set rock default in single place, rather than both here and GameReducer
      otherPlayerWeapon.image = imageFrom(weapon: gameState.otherPlay.weapon ?? .rock, player: .other)
      myPlayerWeapon.image = imageFrom(weapon: gameState.myPlay.weapon ?? .rock, player: .me)
    } else {
      otherPlayerWeapon.image = imageFrom(weapon: nil, player: .other)
      myPlayerWeapon.image = imageFrom(weapon: gameState.myPlay.weapon, player: .me)
    }
    
    toggleWeaponInteraction(enabled: gameState.result == nil)
    toggleWeaponVisibility(isHidden: gameState.gameStatus != .countdown)
    
    renderGameStatus(gameState.gameStatus, for: gameState.result)
  }
  
  // MARK: -
  // MARK: Utility
  // --------------------
  
  private func renderPlayerNames(from multipeerState: MultipeerState) {
    myPlayerNameLabel.text = UIDevice.current.name
    otherPlayerNameLabel.text = multipeerState.connectedPlayer
  }
  
  private func renderGameStatus(_ gameStatus: GameStatus, for result: Result? = nil) {
    print("renderGameStatus called: \(gameStatus), result: \(result)")
    
    if gameStatus != .countdown && isCountdownRunning {
      toggleTimer(enabled: false)
    }
    
    switch gameStatus {
      case .pendingStartReceived:
        showRequestGameStartAlert() { didAccept in
          if didAccept {
            mainStore.dispatch(
              StartGameAction(gameStatus: gameStatus)
            )
          }
        }
      case .pendingStartSent:
        startGameButton.isHidden = true
        pendingStartLabel.isHidden = false
      case .finished:
        startGameButton.isHidden = false
        pendingStartLabel.isHidden = true
        if let result = result {
          grayscaleImagesForResult(result, playerOne: &myPlayerWeapon.image!, playerTwo: &otherPlayerWeapon.image!)
        }
      case .countdown:
        toggleTimer(enabled: true)
        startGameButton.isHidden = true
        pendingStartLabel.isHidden = true
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
  
  private func toggleTimer(enabled: Bool) {
    guard enabled else {
      countdownTimer.invalidate()
      isCountdownRunning = false
      return
    }
    
    if !isCountdownRunning {
      countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        mainStore.dispatch(
          CountdownTickAction()
        )
      }
      isCountdownRunning = true
    }
  }
  
  private func imageFrom(weapon: Weapon?, player: Player) -> UIImage? {
    guard let weapon = weapon else {
      return UIImage(named: "none")
    }
    
    let playerPrefix = player == .me ? "p1-" : "p2-"
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
    case .myWin:
      playerTwo = convertToGrayScale(image: playerTwo)
      break;
    case .otherWin:
      playerOne = convertToGrayScale(image: playerOne)
      break;
    default:
      break;
    }
  }
  
  private func updateScore(from state: AppState) {
    guard let p1Score = state.score[Player.me],
      let p2Score = state.score[Player.other] else { return }
    
    myPlayerScoreLabel.text = String(p1Score)
    otherPlayerScoreLabel.text = String(p2Score)
  }
}

