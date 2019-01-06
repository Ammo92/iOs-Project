//
//  InterfaceController.swift
//  led WatchKit Extension
//
//  Created by Mohamed Gasmi on 09/12/2018.
//  Copyright © 2018 Mohamed Gasmi. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController,WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    var blue = "0"
    var green = "0"
    var red = "0"
    let session = WCSession.default
    
    @IBOutlet var rythme: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session.delegate = self
        session.activate()
        
        let timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.updateColor), userInfo: nil, repeats: true)
     
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @objc func updateColor() {

        let n = Int(arc4random_uniform(70) + 50)
        
        self.red = "0"
        self.blue = "0"
        self.green = "0"
        
        if(n < 70){
            self.blue = "255"
            self.rythme.setText(String(n) + " are you dying ?")
        }else if(n >= 70 && n < 85){
            self.green = "255"
            self.rythme.setText(String(n) + " everythings fine !")
        }else if(n >= 85 && n < 105){
            self.blue = "255"
            self.red = "255"
            self.rythme.setText(String(n) + " Doing some sport ?")
        }else{
            self.red = "255"
            self.rythme.setText(String(n) + " Calm down !")
        }
        
        sendMessage()
        
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    // 3. With our session property which allows implement a method for start communication
    // and manage the counterpart response
    @IBAction func sendMessage() {
        /**
         *  The iOS device is within range, so communication can occur and the WatchKit extension is running in the
         *  foreground, or is running with a high priority in the background (for example, during a workout session
         *  or when a complication is loading its initial timeline data).
         */
        if isReachable() {
            session.sendMessage(["blue" : self.blue,"red" : self.red,"green":self.green], replyHandler: { (response) in
                
            }) { (error) in
                print("Error sending message: %@", error)
            }
        } else {
            print("iPhone is not reachable!!")
        }
    }

}
