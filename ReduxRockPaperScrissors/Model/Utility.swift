//
//  Utility.swift
//  ReduxRockPaperScrissors
//
//  Created by Roland Tolnay on 13/12/2017.
//  Copyright © 2017 Roland Tolnay. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

func convertToGrayScale(image: UIImage) -> UIImage {
  let imageRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
  let colorSpace = CGColorSpaceCreateDeviceGray()
  let width = image.size.width
  let height = image.size.height

  let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
  let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

  if let context = context {
    context.draw(image.cgImage!, in: imageRect)
    let imageRef = context.makeImage()
    let newImage: UIImage = imageRef != nil ? UIImage(cgImage: imageRef!) : image

    return newImage
  } else {
    print("[ERROR] Context was nil at convertToGrayScale(image:) in Utility.swift")
    return image
  }
}

func vibratePhone() {
  AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}
