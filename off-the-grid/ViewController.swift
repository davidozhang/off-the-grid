//
//  ViewController.swift
//  off-the-grid
//
//  Created by Shuangshuang Zhao on 2015-11-28.
//  Copyright © 2015 Team-Off-The-Grid. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol viewControllerDelegate {
    func newStrokesReceived(strokes: [Stroke])
}

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, CanvasViewControllerDelegate {
    private let serviceType = "Off-The-Grid"
    private let myPeerId = MCPeerID.init(displayName: UIDevice.currentDevice().name)
    private var session : MCSession?
    private var advertiser : MCAdvertiserAssistant?
    var vcDelegate : viewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.session = MCSession(peer: self.myPeerId)
        self.session!.delegate = self
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
    
  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        print("finished")
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        print("user denied")
    }
    
    func newStrokes(strokes: [Stroke]) {
        if session?.connectedPeers.count > 0 {
            do {
                var dict: [String: [String: CGFloat]] = Dictionary()
                for i in 0...strokes.count-1 {
                    dict[String(i)] = strokes[i].toDict()
                }
                let data : NSData =  NSKeyedArchiver.archivedDataWithRootObject(dict)
                try session?.sendData(data, toPeers: session!.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("failed to send point")
            }
        }
    }
    
  
    
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("didRecieve")
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: [String: CGFloat]]
        var otherStrokes = [Stroke?](count: dict.count, repeatedValue: nil)
        
        for k in dict.keys {
            let index = Int(k)
            otherStrokes[index!] = Stroke(dict: dict[k]!)
        }
        
        var newOtherStrokes = [Stroke]()
        
        for i in 0...otherStrokes.count-1 {
            newOtherStrokes[i] = otherStrokes[i]!
        }
        
        if vcDelegate != nil {
            vcDelegate!.newStrokesReceived(newOtherStrokes) // Todo: peer id send it here
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("didStartReceivingResourceWithName \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("didFinishRecievingResourceWithName \(resourceName) \(peerID)")
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didRecieveStream \(streamName) \(peerID)")
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("changed State \(peerID)")
        
//        let msgDict : [String: AnyObject] = ["message": 0.5]
//        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(msgDict)
//        //if session.connectedPeers.count > 0 {
//            do {
//                try session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable)
//                print("sent data")
//            } catch {
//                print("failed to send data \(session.connectedPeers.count)")
//            }
//        //}
    }

}

