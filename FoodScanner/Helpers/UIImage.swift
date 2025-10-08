//
//  UIImage.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 07/10/25.
//

import SwiftUI

extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation {
            switch imageOrientation {
                case .up: return .up
                case .down: return .down
                case .left: return .left
                case .right: return .right
                case .upMirrored: return .upMirrored
                case .downMirrored: return .downMirrored
                case .leftMirrored: return .leftMirrored
                case .rightMirrored: return .rightMirrored
                @unknown default: return .up
            }
        }
}
