//
//  Colours.swift
//  DraggieViewer
//
//  Created by Gregg Jaskiewicz on 29/08/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {

    static func randomColor() -> NSColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return NSColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    static func randomDarkColor() -> NSColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return NSColor(red: randomRed/1.5, green: randomGreen/1.5, blue: randomBlue/1.5, alpha: 1.0)
    }
}

extension NSColor {

    func brightness(multipliedBy factor: CGFloat) -> NSColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        self.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha)
        return NSColor(hue: currentHue,
                       saturation: currentSaturation,
                       brightness: currentBrigthness + factor,
                       alpha: currentAlpha)
    }

    func modified(withAdditionalHue hue: CGFloat = 0, additionalSaturation: CGFloat = 0, additionalBrightness: CGFloat = 0) -> NSColor {

        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        self.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha)
        return NSColor(hue: currentHue + hue,
                       saturation: currentSaturation + additionalSaturation,
                       brightness: currentBrigthness + additionalBrightness,
                       alpha: currentAlpha)
    }
}
