//
//  ReduxRockPaperScrissorsTests.swift
//  ReduxRockPaperScrissorsTests
//
//  Created by Roland Tolnay on 10/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import XCTest
import ReSwift
@testable import ReduxRockPaperScrissors

class ReduxRockPaperScrissorsTests: XCTestCase {
  
  func testResultDraw() {
    let store = Store<AppState>(reducer: weaponReducer, state: nil)
    
    // Player 1 choosing weapon
    store.dispatch(ChooseWeaponAction(weapon: .paper))
    // Player 2 choosing weapon
    store.dispatch(ChooseWeaponAction(weapon: .paper))
    
    // Check result
    XCTAssertEqual(store.state.result, .draw)
  }
}
