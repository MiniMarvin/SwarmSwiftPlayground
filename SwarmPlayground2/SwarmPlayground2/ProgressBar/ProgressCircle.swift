//
//  ProgressCircle.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 20/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

public class CircularProgressBar: SKNode {
    
    // Visual settings
    public var radius: CGFloat = 90
    public var width: CGFloat = 12
    public var fontSize: CGFloat = 48
    
    private let circleNode = SKShapeNode(circleOfRadius: 0)
    private let valueLabel = SKLabelNode(text: "NaN %")
    
    // Sets or returns the value of the progress bar
    public var value: Double {
        didSet {
            // Label to display the percentage
            valueLabel.text = "\(Int(value)) %"
            
            // Calculate the Bezier path for the circle
            let endAngle = CGFloat.pi/2 - 2 * CGFloat.pi * CGFloat(value)/100
            let size = radius*2
            
            #if os(OSX)
//            circleNode.path = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: size, yRadius: size).cgPath
            #else
            circleNode.path = UIBezierPath(
                arcCenter: CGPoint(x: 0 , y: 0),
                radius: radius * 2,
                startAngle: CGFloat.pi/2,
                endAngle: endAngle,
                clockwise: false)
                .cgPath
            #endif
        }
    }
    
    public override init() {
        value = 100
        
        super.init()
        
        // Full circle node in the background
        let backCircle = SKShapeNode(circleOfRadius: radius * 2)
        backCircle.lineWidth = width * 2
        backCircle.alpha = 0.4
        circleNode.addChild(backCircle)
        
        // label that displays the current value as text
        valueLabel.fontName = "Helvetica"
        valueLabel.fontSize = fontSize * 2
        valueLabel.position.y = -valueLabel.frame.size.height / 2.2
        circleNode.addChild(valueLabel)
        
        // The arc circle displaying the current value
        circleNode.lineWidth = width * 2
        addChild(circleNode)
        
        // Smooth scaling (retina devices)
        setScale(0.5)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
