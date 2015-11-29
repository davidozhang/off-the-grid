//
//  CanvasViewController.swift
//  Off The Grid
//
//  Created by Shuangshuang Zhao on 2015-11-28.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit

protocol CanvasViewControllerDelegate {
    func newStroke(fromPoint: CGPoint, toPoint: CGPoint)
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

        
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        let dx = toPoint.x - fromPoint.x
        let dy = toPoint.y - fromPoint.y
        let d = sqrt(dx * dx + dy * dy)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth * d / 10)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextStrokePath(context)
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipe = true
        let touch = touches.first! as UITouch
        let currentPoint = touch.locationInView(view)
        print(currentPoint)
        drawLineFrom(lastPoint, toPoint: currentPoint)
        
        if delegate != nil {
            delegate!.newStroke(lastPoint, toPoint: currentPoint)
        }
        
        lastPoint = currentPoint

    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swipe {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        
        
    }
    
    func newStrokeReceived(fromPoint: CGPoint, toPoint: CGPoint) {
        if (!NSThread.isMainThread()) {
            dispatch_async(dispatch_get_main_queue(), {
                
                // DO SOMETHING ON THE MAINTHREAD
                self.drawLineFrom(fromPoint, toPoint: toPoint)
            })
        } else {
            drawLineFrom(fromPoint, toPoint: toPoint)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
