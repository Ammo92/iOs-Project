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
    
    
    @IBOutlet var rythme: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
     
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
    
    @objc func update() {

        let n = Int(arc4random_uniform(42))
        
        self.rythme.setText(String(n))
    }

}
