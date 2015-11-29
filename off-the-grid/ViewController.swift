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
    func newStrokeReceived(stroke: Stroke)
    func updateGlobalReceived(strokes: [[Stroke]], peerID: MCPeerID)
    func newPeer()
}

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, CanvasViewControllerDelegate {
    private let serviceType = "Off-The-Grid"
    internal let myPeerId = MCPeerID.init(displayName: UIDevice.currentDevice().name)
    private var session : MCSession?
    private var advertiser : MCAdvertiserAssistant?
    private var nearbyAdvertiser : MCNearbyServiceAdvertiser?
    var vcDelegate : viewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.session = MCSession(peer: self.myPeerId)
        self.session!.delegate = self
        self.nearbyAdvertiser = MCNearbyServiceAdvertiser.init(peer: myPeerId, discoveryInfo: ["hi": "hello"], serviceType: serviceType)
        self.nearbyAdvertiser?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        let browser = MCBrowserViewController(serviceType: serviceType, session: self.session!)
        
        self.addChildViewController(browser)
        let tempFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!)
        browser.view.frame = tempFrame
        self.view.addSubview(browser.view)
        browser.delegate = self
        self.nearbyAdvertiser?.startAdvertisingPeer()
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
    
    
    func newStroke(stroke: Stroke) {
        if session?.connectedPeers.count > 0 {
            do {
                let dict = stroke.toDict()
                let data : NSData =  NSKeyedArchiver.archivedDataWithRootObject(dict)
                try session?.sendData(data, toPeers: session!.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("failed to send point")
            }

        }
    }
    
    
    func updateAllStrokes(strokess:[[Stroke]]) {
        if session?.connectedPeers.count > 0 {
            do {
                print("updating all strokes")
                var dict: [String: [String: [String: CGFloat]]] = Dictionary()
                if (strokess.count > 0) {
                    for i in 0...(strokess.count - 1) {
                        var innerDict: [String: [String: CGFloat]] = Dictionary()
                        for j in 0...(strokess[i].count - 1) {
                            innerDict[String(j)] = strokess[i][j].toDict()
                        }
                        dict[String(i)] = innerDict
                    }
                }
                let data : NSData =  NSKeyedArchiver.archivedDataWithRootObject(dict)
                try session?.sendData(data, toPeers: session!.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("failed to send [[stroke]]")
            }
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("receiveData")
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: CGFloat] {
            if (dict.count > 0) {
                let otherStroke: Stroke = Stroke(dict: dict)
                if vcDelegate != nil {
                    vcDelegate!.newStrokeReceived(otherStroke)
                }
            } else {
                if vcDelegate != nil
                {
                    vcDelegate!.updateGlobalReceived([[Stroke]](), peerID: peerID)
                }
            }
        } else {
            let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: [String: [String: CGFloat]]]
            
            var otherActions = [[Stroke?]](count: dict.count, repeatedValue:[Stroke?]())
            
            for k in dict.keys {
                let innerDict = dict[k]!
                var singleAction = [Stroke?](count: innerDict.count, repeatedValue:nil)
                for j in innerDict.keys {
                    let strokeDict = innerDict[j]!
                    let otherStroke : Stroke = Stroke(dict: strokeDict)
                    singleAction[Int(j)!] = otherStroke
                }
                
                otherActions[Int(k)!] = singleAction
            }
            
            var confirmedActions = [[Stroke]]()
            
            for i in 0...(otherActions.count-1) {
                var singleConfirmedAction = [Stroke]()
                for j in 0...(otherActions[i].count-1) {
                    singleConfirmedAction.append(otherActions[i][j]!)
                }
                confirmedActions.append(singleConfirmedAction)
            }
            
            if vcDelegate != nil {
                vcDelegate!.updateGlobalReceived(confirmedActions, peerID: peerID)
            }
            
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
        if vcDelegate != nil {
            vcDelegate!.newPeer()
        }
    }
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("didreceiveinvitation")
        var inputTextField = UITextField()
        let confirmAlert = UIAlertController(title: "Off The Grid", message: "\(peerID.displayName) wants to connect", preferredStyle: UIAlertControllerStyle.Alert)
        confirmAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "0000"
            textField.secureTextEntry = true
            inputTextField = textField
        })
        
        confirmAlert.addAction(UIAlertAction(title:"Accept", style: UIAlertActionStyle.Default, handler: { action in
            if inputTextField.text == "0000" {
                invitationHandler(true, self.session!)
            }
        }))
        confirmAlert.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
}

