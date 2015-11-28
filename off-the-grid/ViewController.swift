//
//  ViewController.swift
//  off-the-grid
//
//  Created by Shuangshuang Zhao on 2015-11-28.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, MCBrowserViewControllerDelegate {
    private let serviceType = "Off-The-Grid"
    private let myPeerId = MCPeerID.init(displayName: UIDevice.currentDevice().name)
    private var session : MCSession?
    private var advertiser : MCAdvertiserAssistant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.session = MCSession(peer: self.myPeerId)
        self.advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session!)
        self.advertiser?.start()
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        let browser = MCBrowserViewController(serviceType: serviceType, session: self.session!)
        
        self.addChildViewController(browser)
        let tempFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!)
        browser.view.frame = tempFrame
        self.view.addSubview(browser.view)
        browser.delegate = self
//        browser.modalPresentationStyle = .Popover
//        let popoverBrowserController = browser.popoverPresentationController
//        popoverBrowserController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        popoverBrowserController?.delegate = self
//        popoverBrowserController?.sourceView = self.view
//        popoverBrowserController?.sourceRect = CGRectMake(self.view.frame.width/2 - 10, self.view.frame.height/2 - 10, 0, 0)
   //     presentViewController(browser, animated: true, completion: {})
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        NSLog("%@", "finished")
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        print("user denied")
    }

}

