//
//  LoggingMiddleware.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 15/01/2018.
//  Copyright © 2018 Roland Tolnay. All rights reserved.
//

import Foundation
import ReSwift

let loggingMiddleware: Middleware<Any> = { dispatch, getState in
  return { next in
    return { action in
      // perform middleware logic
      print(action)
      
      // call next middleware
      return next(action)
    }
  }
}
