//
//  ColorViewController.swift
//  Off The Grid
//
//  Created by David on 11/28/15.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit

protocol ColorViewControllerDelegate {
    func changeColor(red: CGFloat, blue: CGFloat, green: CGFloat, alpha: CGFloat)
}

class ColorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var colours = [(CGFloat, CGFloat, CGFloat)]()
    var delegate: ColorViewControllerDelegate?
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ColorCell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCell", forIndexPath: indexPath) as! ColorCell
        let colour = colours[indexPath.row]
        cell.backgroundColor = UIColor.init(red: (colour.0)/255, green: (colour.1)/255, blue: (colour.2)/255, alpha: 1.0)
        print(cell.backgroundColor)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (delegate != nil) {
            let colour = colours[indexPath.row]
            delegate?.changeColor((colour.0)/255, blue: (colour.1)/255, green: (colour.2)/255, alpha: 0.5)
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.collectionView = UICollectionView.init(frame: )
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        colours.append((98, 65, 247))
        colours.append((61, 96, 241))
        colours.append((44, 175, 233))
        colours.append((39, 211, 154))
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
