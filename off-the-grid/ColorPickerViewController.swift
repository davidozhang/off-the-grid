//
//  ColorPickerViewController.swift
//  Off The Grid
//
//  Created by David on 11/28/15.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit

protocol ColorPickerViewDelegate {
    func changeColour(color: UIColor)
}

class ColorPickerViewController: UIViewController {

    var delegate: ColorPickerViewDelegate?
    @IBOutlet var colour1: UIButton!
    @IBOutlet var colour2: UIButton!
    @IBOutlet var colour3: UIButton!
    @IBOutlet var colour4: UIButton!
    @IBOutlet var colour5: UIButton!
    @IBOutlet var colour6: UIButton!
    @IBOutlet var colour7: UIButton!
    
    @IBAction func changeButtonColour(sender: UIButton) {
        self.delegate?.changeColour(sender.backgroundColor!)
        dismissViewControllerAnimated(true) { () -> Void in
        }
    }
    
    @IBOutlet var wrapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.colour1.layer.cornerRadius = self.colour1.frame.width/2
        self.colour1.setTitle("", forState: UIControlState.Normal)
        self.colour1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
 
        
        self.colour2.layer.cornerRadius = self.colour2.frame.width/2
        self.colour2.setTitle("", forState: UIControlState.Normal)
        self.colour2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.colour2.layer.borderWidth = 1
        self.colour2.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        
        self.colour3.layer.cornerRadius = self.colour3.frame.width/2
        self.colour3.setTitle("", forState: UIControlState.Normal)
        self.colour3.backgroundColor = UIColor(red: 61/255, green: 96/255, blue: 241/255, alpha: 0.5)
        
        self.colour4.layer.cornerRadius = self.colour4.frame.width/2
        self.colour4.setTitle("", forState: UIControlState.Normal)
        self.colour4.backgroundColor = UIColor(red: 44/255, green: 175/255, blue: 233/255, alpha: 0.5)

        self.colour5.layer.cornerRadius = self.colour5.frame.width/2
        self.colour5.setTitle("", forState: UIControlState.Normal)
        self.colour5.backgroundColor = UIColor(red: 39/255, green: 211/255, blue: 154/255, alpha: 0.5)

        self.colour6.layer.cornerRadius = self.colour6.frame.width/2
        self.colour6.setTitle("", forState: UIControlState.Normal)
        self.colour6.backgroundColor = UIColor(red: 250/255, green: 197/255, blue: 65/255, alpha: 0.5)

        self.colour7.layer.cornerRadius = self.colour7.frame.width/2
        self.colour7.setTitle("", forState: UIControlState.Normal)
        self.colour7.backgroundColor = UIColor(red: 249/255, green: 62/255, blue: 68/255, alpha: 0.5)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
