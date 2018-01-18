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

  // MARK: - IBOutlets

  @IBOutlet weak var otherPlayerNameLabel: UILabel!
  @IBOutlet weak var localPlayerNameLabel: UILabel!

  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var playerLabel: UILabel!
  @IBOutlet weak var pendingStartLabel: UILabel!

  @IBOutlet weak var localPlayerWeapon: UIImageView!
  @IBOutlet weak var otherPlayerWeapon: UIImageView!

  @IBOutlet weak var localPlayerScoreLabel: UILabel!
  @IBOutlet weak var otherPlayerScoreLabel: UILabel!

  @IBOutlet weak var rockImageView: UIImageView!
  @IBOutlet weak var paperImageView: UIImageView!
  @IBOutlet weak var scrissorsImageView: UIImageView!

  @IBOutlet weak var startGameButton: UIButton!
  @IBOutlet weak var leaveButton: UIButton!
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

    mainStore.subscribe(self) { state in
      state.select { $0.gameState }
    }
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
      ChooseWeaponAction(player: .local, weapon: .rock)
    )
  }
  @IBAction func onPaperTap(_ sender: UITapGestureRecognizer) {
    mainStore.dispatch(
      ChooseWeaponAction(player: .local, weapon: .paper)
    )
  }
  @IBAction func onScrissorsTap(_ sender: Any) {
    mainStore.dispatch(
      ChooseWeaponAction(player: .local, weapon: .scrissors)
    )
  }

  @IBAction func onStartGameTapped(_ sender: UIButton) {
    mainStore.dispatch(
      RequestStartGameAction()
    )
  }

  @IBAction func onLeaveTapped(_ sender: UIButton) {
    self.dismiss(animated: true)
    mainStore.dispatch(
      StopBrowsingPeersAction()
    )
  }

  // MARK: -
  // MARK: Redux Render
  // --------------------

  func newState(state: GameState) {

    playerLabel.text = state.playerMessage
    renderPlayerNames(from: state.playerNames)
    updateScore(from: state)
    renderCountdown(from: state)
    
    toggleWeaponInteraction(enabled: state.result == nil)
    toggleWeaponVisibility(isHidden: state.gameStatus != .countdown)
    renderResult(from: state)

    renderGameStatus(state.gameStatus, for: state.result)
  }

  // MARK: -
  // MARK: Render methods
  // --------------------

  private func renderPlayerNames(from playerNames: PlayerNames) {
    localPlayerNameLabel.text = playerNames.localPlayerName
    otherPlayerNameLabel.text = playerNames.otherPlayerName
  }

  private func renderGameStatus(_ gameStatus: GameStatus, for result: Result? = nil) {
    if gameStatus != .countdown && isCountdownRunning {
      toggleTimer(enabled: false)
    }

    switch gameStatus {
      case .opponentLeft:
        self.dismiss(animated: true) {
          self.showOpponentLeftAlert()
        }
      case .pendingStartReceived:
        showRequestGameStartAlert { didAccept in
          mainStore.dispatch(
            RespondStartGameAction(canStart: didAccept, gameStatus: gameStatus)
          )
        }
      case .pendingStartSent:
        startGameButton.isHidden = true
        leaveButton.isHidden = true
        pendingStartLabel.isHidden = false
      case .finished:
        startGameButton.isHidden = false
        leaveButton.isHidden = false
        pendingStartLabel.isHidden = true
        if let result = result {
          grayscaleImagesForResult(result, playerOne: &localPlayerWeapon.image!, playerTwo: &otherPlayerWeapon.image!)
        }
      case .countdown:
        toggleTimer(enabled: true)
        startGameButton.isHidden = true
        leaveButton.isHidden = true
        pendingStartLabel.isHidden = true
    }
  }
  
  private func renderCountdown(from state: GameState) {
    if let countdown = state.currentCountdown, statusLabel.text != String(countdown) {
      statusLabel.text = String(countdown)
      statusLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
      UIView.animate(withDuration: 1, animations: {
        self.statusLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
      })
    }
    if state.gameStatus != .countdown {
      statusLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
      statusLabel.text = state.statusMessage
    }
  }
  
  private func renderResult(from state: GameState) {
    if state.result != nil {
      otherPlayerWeapon.image = imageFor(weapon: state.otherPlay.weapon!, player: .other)
      localPlayerWeapon.image = imageFor(weapon: state.localPlay.weapon!, player: .local)
    } else {
      otherPlayerWeapon.image = imageFor(weapon: nil, player: .other)
      localPlayerWeapon.image = imageFor(weapon: state.localPlay.weapon, player: .local)
    }
  }
  
  private func updateScore(from state: GameState) {
    guard let p1Score = state.score[Player.local],
      let p2Score = state.score[Player.other] else { return }
    
    localPlayerScoreLabel.text = String(p1Score)
    otherPlayerScoreLabel.text = String(p2Score)
  }
  
  // MARK: -
  // MARK: Alerts
  // --------------------

  typealias AlertResult = (_ didAccept: Bool) -> Void

  private func showRequestGameStartAlert(completion: @escaping AlertResult) {
    let opponent = mainStore.state.gameState.playerNames.otherPlayerName
    let alert = UIAlertController(title: "Start game",
                                  message: "\(opponent) would like to start the game. Are you ready?",
                                  preferredStyle: .alert)
    let acceptAction = UIAlertAction(title: "Accept", style: .cancel) { _ in
      completion(true)
    }
    let declineAction = UIAlertAction(title: "Decline", style: .default) { _ in
      completion(false)
    }

    alert.addAction(acceptAction)
    alert.addAction(declineAction)

    present(alert, animated: true, completion: nil)
  }

  private func showOpponentLeftAlert() {
    let alert = UIAlertController(title: nil,
                                  message: "Your opponent has left the game.",
                                  preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Done", style: .default)
    alert.addAction(okAction)

    let appDelegate = UIApplication.shared.delegate as! AppDelegate // swiftlint:disable:this force_cast
    let rootVC = appDelegate.window!.rootViewController!
    rootVC.present(alert, animated: true, completion: nil)
  }

  // MARK: -
  // MARK: Togglers
  // --------------------
  
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
      // Countdown expired
      countdownTimer.invalidate()
      isCountdownRunning = false
      vibratePhone()

      mainStore.dispatch(
        UpdateScoreAction()
      )
      return
    }

    if !isCountdownRunning {
      countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        mainStore.dispatch(
          CountdownTickAction()
        )
      }
      isCountdownRunning = true
      vibratePhone()
    }
  }
  
  // MARK: -
  // MARK: Helpers
  // --------------------

  private func imageFor(weapon: Weapon?, player: Player) -> UIImage? {
    guard let weapon = weapon else {
      return UIImage(named: "none")
    }

    let playerPrefix = player == .local ? "p1-" : "p2-"
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
      case .localWin:
        playerTwo = convertToGrayScale(image: playerTwo)
      case .otherWin:
        playerOne = convertToGrayScale(image: playerOne)
      default: // draw
        break
    }
  }
}
