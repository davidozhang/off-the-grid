//
//  CanvasViewController.swift
//  Off The Grid
//
//  Created by Shuangshuang Zhao on 2015-11-28.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreFoundation

protocol CanvasViewControllerDelegate {
    func newStroke(stroke: Stroke)
    func updateAllStrokes(strokes: [[Stroke]])
}

class CanvasViewController: UIViewController, UIPopoverPresentationControllerDelegate, UICollectionViewDelegate, viewControllerDelegate, ColorPickerViewDelegate{

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var delegate : CanvasViewControllerDelegate?
    
    var swipe = false
    var lastPoint = CGPoint.zero
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    
    var strokes = [Stroke]()
    
    var allMyStrokes = [[Stroke]]()
    
    var allOtherStrokes = [MCPeerID: [[Stroke]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.view.addGestureRecognizer(longPressRecognizer)
        // Do any additional setup after loading the view.
    }

    
    func changeColour(color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            self.red = CGFloat(r)
            self.green = CGFloat(g)
            self.blue = CGFloat(b)
            self.opacity = CGFloat(a)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColourSegue" {
            if let colorPickerViewController = segue.destinationViewController as? ColorPickerViewController {
                colorPickerViewController.delegate = self
                let tempwidth = self.view.frame.width
                let tempHeight = self.view.frame.height
                colorPickerViewController.preferredContentSize = CGSize(width: tempwidth, height: tempHeight * 0.089)
                //colorViewController.view.frame = CGRectMake(0, 0, tempwidth, tempHeight * 0.1)
                if let popvc = colorPickerViewController.popoverPresentationController {

                    popvc.delegate = self
                    popvc.sourceView = self.view
                    popvc.sourceRect = CGRectMake(lastPoint.x, lastPoint.y, 0, 0)
                }
            }
        }
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        performSegueWithIdentifier("ColourSegue", sender: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipe = false
        let touch = touches.first! as UITouch
        lastPoint = touch.locationInView(self.view)
        self.strokes = []
        
    }
    
    func drawEverything() {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        let rect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0)
        CGContextClearRect(context, rect)
        CGContextAddRect(context, rect)
        
        
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        var allStrokes = [Stroke]()
        
        if (self.allMyStrokes.count > 0) {
            for i in 0...(self.allMyStrokes.count-1) {
                if (self.allMyStrokes[i].count > 0) {
                    for j in 0...(self.allMyStrokes[i].count-1) {
                        allStrokes.append(self.allMyStrokes[i][j])
                    }
                }
            }
        }
        
        for k in self.allOtherStrokes.keys {
            if (self.allOtherStrokes[k]!.count > 0) {
                for i in 0...(self.allOtherStrokes[k]!.count-1) {
                    if (self.allOtherStrokes[k]![i].count > 0) {
                        for j in 0...(self.allOtherStrokes[k]![i].count-1) {
                            allStrokes.append(self.allOtherStrokes[k]![i][j])
                        }
                    }
                }
            }
        }
        
        // Sort allStrokes based on timestamp
        
        let sortedArray = allStrokes.sort({ $0.timeStamp < $1.timeStamp })
        
        if sortedArray.count > 0 {
            for i in 0...(sortedArray.count-1) {
                drawStroke(sortedArray[i])
            }
        }
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func drawStroke(stroke: Stroke) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        CGContextMoveToPoint(context, stroke.fromPoint.x, stroke.fromPoint.y)
        CGContextAddLineToPoint(context, stroke.toPoint.x, stroke.toPoint.y)
        let dx = stroke.toPoint.x - stroke.fromPoint.x
        let dy = stroke.toPoint.y - stroke.fromPoint.y
        let d = sqrt(dx * dx + dy * dy)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth * d / 30)
        CGContextSetRGBStrokeColor(context, stroke.r, stroke.g, stroke.b, stroke.a)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextStrokePath(context)
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipe = true
        let touch = touches.first! as UITouch
        let currentPoint = touch.locationInView(view)
        let latestStroke = Stroke(fromPoint: lastPoint, toPoint: currentPoint, r: self.red, g: self.green, b: self.blue, a: self.opacity, timeStamp: CGFloat(CFAbsoluteTimeGetCurrent()))
        self.strokes.append(latestStroke)
        drawStroke(latestStroke)
        lastPoint = currentPoint
        
        if delegate != nil {
            delegate!.newStroke(latestStroke)
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swipe {
            let latestStroke = Stroke(fromPoint: lastPoint, toPoint: lastPoint, r: self.red, g: self.green, b: self.blue, a: self.opacity, timeStamp: CGFloat(CFAbsoluteTimeGetCurrent()))
            self.strokes.append(latestStroke)
            drawStroke(latestStroke)
            if delegate != nil {
                delegate!.newStroke(latestStroke)
            }
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        
        self.allMyStrokes.append(self.strokes)
        
        if delegate != nil {
            delegate!.updateAllStrokes(self.allMyStrokes)
        }
    }
    
    func undo() {
        self.allMyStrokes = (([[Stroke]]) (self.allMyStrokes.dropLast()))
        if delegate != nil {
            delegate!.updateAllStrokes(self.allMyStrokes)
        }
        drawEverything()
    }
    
    
    func newStrokeReceived(stroke: Stroke) {
        if (!NSThread.isMainThread()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.drawStroke(stroke)
            })
        } else {
            self.drawStroke(stroke)
        }
    }
    
    
    func updateGlobalReceived(strokes: [[Stroke]], peerID: MCPeerID) {
        if (self.allOtherStrokes[peerID]!.count > strokes.count) {
            // peer undid an action, need to redraw
            self.allOtherStrokes[peerID] = strokes
            drawEverything()
        } else {
            // peer drew an action, add it to other strokes
            self.allOtherStrokes[peerID] = strokes
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
