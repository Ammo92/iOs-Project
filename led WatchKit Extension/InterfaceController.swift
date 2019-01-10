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
import HealthKit // import this at the top of the file


class InterfaceController: WKInterfaceController,WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }

    var heartRateQuery:HKQuery?
    var fetchLatestHeartRateSample: HKHeartRateMotionContext?
    var healthStore : HKHealthStore?
    var calm = ["blue":"255", "red" : "0", "green" : "0"]
    var normal = ["blue":"0", "red" : "0", "green" : "255"]
    var sport = ["blue":"0", "red" : "255", "green" : "155"]
    var tired = ["blue":"0", "red" : "255", "green" : "0"]
    var blue = "0"
    var green = "0"
    var red = "0"
    let session = WCSession.default
    
    @IBOutlet var rythme: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session.delegate = self
        session.activate()
        
        _ = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.updateColor), userInfo: nil, repeats: true)
     
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
    
    func processApplicationContext() {
        let iPhoneContext = session.receivedApplicationContext as [String : Any]
        if(iPhoneContext["type"] as! Int == 2){
            self.calm["red"] = iPhoneContext["red"] as? String
            self.calm["blue"] = iPhoneContext["blue"] as? String
            self.calm["green"] = iPhoneContext["green"] as? String
        }
        if(iPhoneContext["type"] as! Int == 3){
            self.normal["red"] = iPhoneContext["red"] as? String
            self.normal["blue"] = iPhoneContext["blue"] as? String
            self.normal["green"] = iPhoneContext["green"] as? String
        }
        if(iPhoneContext["type"] as! Int == 4){
            self.sport["red"] = iPhoneContext["red"] as? String
            self.sport["blue"] = iPhoneContext["blue"] as? String
            self.sport["green"] = iPhoneContext["green"] as? String
        }
        if(iPhoneContext["type"] as! Int == 5){
            self.tired["red"] = iPhoneContext["red"] as? String
            self.tired["blue"] = iPhoneContext["blue"] as? String
            self.tired["green"] = iPhoneContext["green"] as? String
        }
    }
    
    @objc func updateColor() {

        let n = Int(arc4random_uniform(70) + 50)
        
        if(n < 70){
            self.blue = self.calm["blue"] ?? "255"
            self.red = self.calm["red"] ?? "0"
            self.green = self.calm["green"] ?? "0"
            self.rythme.setText(String(n) + " are you dying ?")
        }else if(n >= 70 && n < 85){
            self.blue = self.normal["blue"] ?? "0"
            self.red = self.normal["red"] ?? "0"
            self.green = self.normal["green"] ?? "255"
            self.rythme.setText(String(n) + " everythings fine !")
        }else if(n >= 85 && n < 105){
            self.blue = self.sport["blue"] ?? "255"
            self.red = self.sport["red"] ?? "255"
            self.green = self.sport["green"] ?? "0"
            self.rythme.setText(String(n) + " Doing some sport ?")
        }else{
            self.blue = self.tired["blue"] ?? "0"
            self.red = self.tired["red"] ?? "255"
            self.green = self.tired["green"] ?? "0"
            self.rythme.setText(String(n) + " Calm down !")
        }
        
        sendMessage()
        
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    
    // GET HEAT BEAT
    public func subscribeToHeartBeatChanges() {
        
        // Creating the sample for the heart rate
        guard let sampleType: HKSampleType =
            HKObjectType.quantityType(forIdentifier: .heartRate) else {
                return
        }
        
        /// Creating an observer, so updates are received whenever HealthKit’s
        // heart rate data changes.
        self.heartRateQuery = HKObserverQuery.init(
            sampleType: sampleType,
            predicate: nil) { [weak self] _, _, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                /// When the completion is called, an other query is executed
                /// to fetch the latest heart rate
                self?.fetchLatestHeartRateSample(completion: { sample in
                    guard let sample = sample else {
                        return
                    }
                    
                    /// The completion in called on a background thread, but we
                    /// need to update the UI on the main.
                    DispatchQueue.main.async {
                        
                        /// Converting the heart rate to bpm
                        let heartRateUnit = HKUnit(from: "count/min")
                        let heartRate = sample
                            .quantity
                            .doubleValue(for: heartRateUnit)
                        
                        /// Updating the UI with the retrieved value
                        print("\(Int(heartRate))")
                    }
                })
        }
    }
    
    public func fetchLatestHeartRateSample(
        completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
        
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
        }
        
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                completion(results?[0] as? HKQuantitySample)
        }
        
        self.healthStore?.execute(query)
    }
    // END GET HEART BEAT
    
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
