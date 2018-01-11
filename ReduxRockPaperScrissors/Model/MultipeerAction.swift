//
//  MultipeerAction.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 11/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import Foundation

enum MultipeerAction: String {
  
  case gameStartRequest
  case gameStartApproved
  case gameStartDeclined
  case chosenRock
  case chosenPaper
  case chosenScrissors
}
