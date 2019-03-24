//
//  ProgressCircle.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 20/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//
//  Copyright © 2018 – Samuel Oechsler

import Foundation
import SpriteKit

public class CircularProgressBar: SKNode {
    
    // Visual settings
    public var radius: CGFloat = 90
    public var width: CGFloat = 12
    public var isAvaiable: Bool = true
    public var isWorking: Bool = true
//    public var fontSize: CGFloat = 48
    
    private let circleNode = SKShapeNode(circleOfRadius: 0)
    private let backCircle = SKShapeNode(circleOfRadius: 0)
    private let valueLabel = SKLabelNode(text: "NaN %")
    
    
    // Sets or returns the valaue of the progress bar
    public var value: Double {
        didSet {
            // Label to display the percentage
//            valueLabel.text = "\(Int(value)) %"
            
            if !isAvaiable {
                return
            }
            
            if !isWorking {
                self.isHidden = true
                return
            }
            else {
                self.isHidden = false
            }
            
            // Calculate the Bezier path for the circle
            let endAngle = CGFloat.pi/2 - 2 * CGFloat.pi * CGFloat(value)/100
            
            if value < 1 {
                self.isHidden = true
            }
            else {
                self.isHidden = false
            }
            
            
//            #if os(OSX)
            // TODO: Add MacOS Version
//            #else
            circleNode.path = UIBezierPath(
                arcCenter: CGPoint(x: 0 , y: 0),
                radius: radius * 2,
                startAngle: CGFloat.pi/2,
                endAngle: endAngle,
                clockwise: false)
                .cgPath
//            #endif
        }
    }
    
    public init(radius: CGFloat=90, width: CGFloat=12) {
        value = 100
        self.radius = radius
        self.width = width
        
        super.init()
        
        // Full circle node in the background
        let backCircle = SKShapeNode(circleOfRadius: self.radius*2)
        backCircle.lineWidth = width * 2
        backCircle.alpha = 0.4
        circleNode.addChild(backCircle)
        
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
