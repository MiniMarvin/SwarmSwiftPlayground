//
//  Stages.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 20/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

public struct ZoneBuilder {
    var intervalX:ClosedRange<CGFloat>
    var intervalY:ClosedRange<CGFloat>
    var numOfAgents:Int
}


public protocol Stage {
    func levelZone(canvas:CGRect) -> Scenario
    func levelPrizes(canvas:CGRect) -> [Prize]
}

