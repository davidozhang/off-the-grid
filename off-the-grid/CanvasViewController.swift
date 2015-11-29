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

class CanvasViewController: UIViewController, UIPopoverPresentationControllerDelegate, UICollectionViewDelegate, ColorViewControllerDelegate , viewControllerDelegate{

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
    var otherStrokes = [Stroke]()
    
    var allMyStrokes = [[Stroke]]()
    
    var allOtherStrokes = [MCPeerID: [[Stroke]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.view.addGestureRecognizer(longPressRecognizer)
        // Do any additional setup after loading the view.
    }
    
    func changeColor(red: CGFloat, blue: CGFloat, green: CGFloat, alpha: CGFloat) {
        self.red = red
        self.blue = blue
        self.green = green
        self.opacity = alpha
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColourSegue" {
            if let colorViewController = segue.destinationViewController as? ColorViewController {
                if let popvc = colorViewController.popoverPresentationController {
                    popvc.delegate = self
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
        
        for stroke in self.strokes {
            CGContextMoveToPoint(context, stroke.fromPoint.x, stroke.fromPoint.y)
            CGContextAddLineToPoint(context, stroke.toPoint.x, stroke.toPoint.y)
                //            let dx = stroke.toPoint.x - stroke.fromPoint.x
                //            let dy = stroke.toPoint.y - stroke.fromPoint.y
                //            let d = sqrt(dx * dx + dy * dy)
                
                // drawStroke(context, stroke: stroke)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, brushWidth)
            CGContextSetRGBStrokeColor(context, stroke.r, stroke.g, stroke.b, stroke.a)
            CGContextStrokePath(context)
        }
        
        for stroke in self.otherStrokes {
            CGContextMoveToPoint(context, stroke.fromPoint.x, stroke.fromPoint.y)
            CGContextAddLineToPoint(context, stroke.toPoint.x, stroke.toPoint.y)
            //            let dx = stroke.toPoint.x - stroke.fromPoint.x
            //            let dy = stroke.toPoint.y - stroke.fromPoint.y
            //            let d = sqrt(dx * dx + dy * dy)
            
            // drawStroke(context, stroke: stroke)
            CGContextSetLineCap(context, CGLineCap.Round)
            CGContextSetLineWidth(context, brushWidth)
            CGContextSetRGBStrokeColor(context, stroke.r, stroke.g, stroke.b, stroke.a)
            CGContextStrokePath(context)
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
        //            let dx = stroke.toPoint.x - stroke.fromPoint.x
        //            let dy = stroke.toPoint.y - stroke.fromPoint.y
        //            let d = sqrt(dx * dx + dy * dy)
        
        // drawStroke(context, stroke: stroke)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, stroke.r, stroke.g, stroke.b, stroke.a)
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
        self.allOtherStrokes[peerID] = strokes
        drawEverything()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
