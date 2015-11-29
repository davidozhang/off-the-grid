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

class ViewController: UIViewController, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, CanvasViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    private let serviceType = "Off-The-Grid"
    internal let myPeerId = MCPeerID.init(displayName: UIDevice.currentDevice().name)
    private var session : MCSession?
    
    private var advertiser : MCAdvertiserAssistant?
    private var nearbyAdvertiser : MCNearbyServiceAdvertiser?
    private var nearbyBrowser: MCNearbyServiceBrowser?
    
    private var inviteesTableView: UITableView?
    private var inviteTableView: UITableView?
    private var inviteesIDs: [MCPeerID]?
    private var inviteIDs: [MCPeerID]?
    private var code: String?
    
    let CellIdentifier : String = "Cell"
    
    var vcDelegate : viewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.session = MCSession(peer: self.myPeerId)
        self.session!.delegate = self
        
        self.nearbyAdvertiser = MCNearbyServiceAdvertiser.init(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.nearbyAdvertiser?.delegate = self
        
        self.nearbyBrowser = MCNearbyServiceBrowser.init(peer: myPeerId, serviceType: serviceType)
        self.nearbyBrowser?.delegate = self
        
        self.inviteesIDs = [MCPeerID]()
        self.inviteIDs = [MCPeerID]()
    }
    
    override func viewWillAppear(animated: Bool) {
        let myBrowser = UIViewController()
        myBrowser.view.backgroundColor = UIColor(red: 200 , green: 200, blue: 200, alpha: 1)
        
        
        // Make an inviteesLabel
        let inviteesLabel = UILabel(frame: CGRectMake(20, 30, self.view.frame.width - 20, 40))
        inviteesLabel.text = "Invitees"
        inviteesLabel.font = UIFont(name: "Avenir-Light", size: 15)
        inviteesLabel.textAlignment = NSTextAlignment.Left
        inviteesLabel.textColor = UIColor.darkGrayColor()
        myBrowser.view.addSubview(inviteesLabel)
        //inviteesLabel.hidden = true
        
        
        // Make inviteesTableView
        self.inviteesTableView = UITableView(frame: CGRectMake(0, 60, self.view.frame.width, 120))
        self.inviteesTableView!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.inviteesTableView?.delegate = self
        self.inviteesTableView?.dataSource = self
        myBrowser.view.addSubview(inviteesTableView!)
        //inviteesTableView.hidden = true
        
        
        // Make an 'Choose to invite' label
        let inviteLabel = UILabel(frame: CGRectMake(20, 200, self.view.frame.width - 20, 40))
        inviteLabel.text = "Choose 1 to 7 invitees:"
        inviteLabel.font = UIFont(name: "Avenir-Light", size: 15)
        inviteLabel.textAlignment = NSTextAlignment.Left
        inviteLabel.textColor = UIColor.darkGrayColor()
        myBrowser.view.addSubview(inviteLabel)
        //myBrowser.view.addSubview(inviteLabel)
        
        // Make inviteTableView
        self.inviteTableView = UITableView(frame: CGRectMake(0, 300, self.view.frame.width, 120))
        self.inviteTableView!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.inviteTableView?.delegate = self
        self.inviteTableView?.dataSource = self
        myBrowser.view.addSubview(inviteTableView!)
        //inviteesTableView.hidden = true
        
        
        
        //self.addChildViewController(browser)
//        let tempFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!)
//        browser.view.frame = tempFrame
//        self.view.addSubview(browser.view)
        //browser.delegate = self
        
        
        self.addChildViewController(myBrowser)
                let tempFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!)
                myBrowser.view.frame = tempFrame
                self.view.addSubview(myBrowser.view)
        
        self.inviteTableView?.reloadData()
        self.inviteesTableView?.reloadData()
        
        self.nearbyAdvertiser?.startAdvertisingPeer()
        self.nearbyBrowser?.startBrowsingForPeers()
    }
    
    deinit {
        self.nearbyAdvertiser?.stopAdvertisingPeer()
        self.nearbyBrowser?.stopBrowsingForPeers()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
        if self.inviteesIDs!.contains(peerID) {
            self.inviteesIDs!.removeAtIndex(self.inviteesIDs!.indexOf(peerID)!)
            self.inviteesTableView?.reloadData()
        } else {
            self.inviteIDs!.removeAtIndex(self.inviteIDs!.indexOf(peerID)!)
            self.inviteTableView?.reloadData()
        }
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundpeer")
        self.inviteIDs!.append(peerID)
        self.inviteTableView?.reloadData()
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
    
//    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
//        certificateHandler(true);
//    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print(peerID)
        if (state == MCSessionState.NotConnected) {
            print("not Connected")
            self.inviteesIDs?.removeAtIndex((self.inviteesIDs?.indexOf(peerID))!)
            self.inviteIDs?.append(peerID)
        }
        
//        if (state ==  MCSessionState.Connecting) {
//            self.inviteesIDs?.append(peerID)
//            self.inviteIDs?.removeAtIndex((self.inviteIDs?.indexOf(peerID))!)
//        }
        
        if (state == MCSessionState.Connected) {
            print("connected")
            self.inviteesIDs?.append(peerID)
            self.inviteIDs?.removeAtIndex((self.inviteIDs?.indexOf(peerID))!)
        }
        
        self.inviteesTableView?.reloadData()
        self.inviteTableView?.reloadData()
        if vcDelegate != nil {
            vcDelegate!.newPeer()
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
        var inputTextField = UITextField()
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(context!) as? [String: String]
        let code = dict!["code"]
        
        let confirmAlert = UIAlertController(title: "Off The Grid", message: "\(peerID.displayName) wants to connect", preferredStyle: UIAlertControllerStyle.Alert)
        confirmAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "0000"
            textField.secureTextEntry = true
            inputTextField = textField
        })
        
        confirmAlert.addAction(UIAlertAction(title:"Accept", style: UIAlertActionStyle.Default, handler: { action in
            if inputTextField.text == code {
                invitationHandler(true, self.session!)
            }
        }))
        confirmAlert.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.inviteesTableView) {
            return self.inviteesIDs!.count
        } else {
            return self.inviteIDs!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        var cell : UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        }
        
        if (tableView == self.inviteesIDs) {
            cell!.textLabel?.text = self.inviteesIDs![indexPath.row].displayName
        } else {
            cell!.textLabel?.text = self.inviteIDs![indexPath.row].displayName
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == self.inviteTableView) {
            var targetPeerID = MCPeerID(displayName: self.myPeerId.displayName)
            for i in 0...(self.inviteIDs!.count-1) {
                if self.inviteIDs![i].displayName == tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
                    targetPeerID = self.inviteIDs![i]
                }
            }
            
            var inputTextField = UITextField()
            let confirmAlert = UIAlertController(title: "Off The Grid", message: "Enter a 4-digit code before you connect with \((targetPeerID.displayName))", preferredStyle: UIAlertControllerStyle.Alert)
            confirmAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "0000"
                textField.secureTextEntry = true
                inputTextField = textField
            })
            
            confirmAlert.addAction(UIAlertAction(title:"Accept", style: UIAlertActionStyle.Default, handler: { action in
                var codeString = ""
                if inputTextField.text != "" {
                    codeString = inputTextField.text!
                }
                let dict = ["code": codeString]
                let data : NSData =  NSKeyedArchiver.archivedDataWithRootObject(dict)
                self.nearbyBrowser!.invitePeer(targetPeerID, toSession: self.session!, withContext: data, timeout: 30)
            }))
            confirmAlert.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(confirmAlert, animated: true, completion: nil)

        }
    }
    
}

