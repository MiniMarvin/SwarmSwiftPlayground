//
//  Utils.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

// MARK: Enums

public enum Errors:Error {
    case runtimeError(String)
}

// MARK: Conversion Functions

public func convertDouble2CGVector(_ value:vector_float2) -> CGVector {
    return CGVector(dx: CGFloat(value.x), dy: CGFloat(value.y))
}

public func convertCGVector2Double(_ value: CGVector) -> vector_float2 {
    return vector_float2(Float(value.dx), Float(value.dy))
}

public func convertDouble2CGPoint(_ value:vector_float2) -> CGPoint {
    return CGPoint(x: CGFloat(value.x), y: CGFloat(value.y))
}

public func convertCGPoint2Double(_ value:CGPoint) -> vector_float2 {
    return vector_float2(x: Float(value.x), y: Float(value.y))
}

// MARK: Random Functions

public func randomDoublesVector(max:Float) -> [Float] {
    var f = Float(randomInterval(min: 0, max: max, precision: 5))
    var t = sqrt(max*max - f*f)
    
    if (randomInterval(min: 0, max: 1, precision: 5)) > 0.5 { f *= -1 }
    if (randomInterval(min: 0, max: 1, precision: 5)) > 0.5 { t *= -1 }
    
    return [f, t]
}

public func randomDoubles(min:Float, max:Float, n:Int) -> [Float] {
    var arr:[Float] = []
    for _ in 0...(n-1) {
        let a:Float = Float(randomInterval(min: min, max: max, precision: 5))
        arr.append(a)
    }
    return arr
}

public func randomInterval(min:Float, max:Float, precision:Int) -> Float {
    var m:Int = 1
    for _ in 1...precision {
        m *= 10
    }
    let r = (max - min)*Float(arc4random()%(UInt32(m) + UInt32(1)))/Float(m)
    return r
}



// Play Song
// WARNING: modifying function
public func playBackgroundSound(player:inout AVAudioPlayer?) {
    guard let url = Bundle.main.url(forResource: "Forest Song", withExtension: "mp3") else { return }
    
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        
        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        
        guard let player = player else { return }
        
        player.volume = 0.4
        player.numberOfLoops = -1
        player.play()
    }
    catch let error {
        print(error.localizedDescription)
    }
}

public func stopBackgroundSound(player: inout AVAudioPlayer?) {
    player?.stop()
}


// Add Custom fonts
public func addCustomFonts() {
    let cfURL = NSBundle.mainBundle().URLForResource("Proxima Nova Semibold", withExtension: "ttf") as! CFURL
    CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.Process, nil)
//    let font = UIFont(name: "ProximaNova-Semibold", size:  14.0)
}


// Global variables

var __GLOBAL_POINTING_SPOT:CGPoint? = nil
var __GLOBAL_POINTING_LOCK:Bool = false
var __GLOBAL_POINTER_IS_WORKING:Int = 0

func setGlobalPointing(point:CGPoint?) {
    if !__GLOBAL_POINTING_LOCK {
        __GLOBAL_POINTING_SPOT = point
    }
}

func lockGlobalPointing() {
    __GLOBAL_POINTING_LOCK = true
}

func unlockGlobalPointing() {
    __GLOBAL_POINTING_LOCK = false
}

