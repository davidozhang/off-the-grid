//
//  Stroke.swift
//  Off The Grid
//
//  Created by David Rusu on 2015-11-28.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import Foundation
import UIKit

class Stroke {
    let fromPoint: CGPoint
    let toPoint: CGPoint
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat
    let timeStamp : CGFloat
    
    init(fromPoint: CGPoint, toPoint: CGPoint, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat, timeStamp: CGFloat) {
        self.fromPoint = fromPoint
        self.toPoint = toPoint
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.timeStamp = timeStamp
    }
    
    init(dict: [String: CGFloat]) {
        self.fromPoint = CGPointMake(dict["x1"]!, dict["y1"]!)
        self.toPoint = CGPointMake(dict["x2"]!, dict["y2"]!)
        self.r = dict["r"]!
        self.g = dict["g"]!
        self.b = dict["b"]!
        self.a = dict["a"]!
        self.timeStamp = dict["timeStamp"]!
    }
    
    func toDict() -> [String: CGFloat]{
        return [
            "x1": fromPoint.x,
            "y1": fromPoint.y,
            "x2": toPoint.x,
            "y2": toPoint.y,
            "r": r,
            "g": g,
            "b": b,
            "a": a,
            "timeStamp": timeStamp
        ]
    }
}