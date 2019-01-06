//
//  ViewController.swift
//  led
//
//  Created by Mohamed Gasmi on 09/12/2018.
//  Copyright © 2018 Mohamed Gasmi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import ChromaColorPicker
import WatchConnectivity

class ViewController: UIViewController, ChromaColorPickerDelegate,WCSessionDelegate {
    
    
        var session: WCSession?
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let red = message["red"] as! String
        let blue = message["blue"] as! String
        let green = message["green"] as! String
        changeColor(red : red,blue: blue,green: green)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
   
    
    @IBAction func UpdateColor(_ sender: Any) {
        
        
        let col = UIColor(hexString: neatColorPicker.hexLabel.text!)

    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
//        ref.observe(DataEventType.value, with: { (snapshot) in
//
//            if !snapshot.exists() { return }
//
//              let value = snapshot.value as? NSDictionary
//            if let color = value?["blue"] as? String {
//                print(color)
//            }
//
//
//            // snapshot.childSnapshotForPath("full_name").value as! String
//        });
        
        
        
    }
    
    let screenRect = UIScreen.main.bounds
    lazy var screenWidth = screenRect.size.width
    lazy var screenHeight = screenRect.size.height
    lazy var neatColorPicker = ChromaColorPicker(frame: CGRect(x: screenWidth/4-50, y: screenHeight/4, width: 300, height: 300))
    
    override func viewDidAppear(_ animated: Bool) {
        

        neatColorPicker.delegate = self
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        view.addSubview(neatColorPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}

func changeColor(red:String,blue:String,green:String){
    
    let ref:DatabaseReference!
    
    let color2 = [
        "red":   red,
        "blue":  blue,
        "green": green
    ]
    
    ref = Database.database().reference().child("color")
    
    ref.setValue(color2)
    
}
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
        
        let re = "\(r)"
        let ge  = "\(g)"
        let be  = "\(b)"
        
        
        changeColor(red: re, blue:be , green: ge)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

