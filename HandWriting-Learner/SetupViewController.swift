//
//  SetupViewController.swift
//  HandWriting-Learner
//
//  Created by Alban on 08.03.16.
//  Copyright © 2016 Alban Perli. All rights reserved.
//

import UIKit

struct AlertTextConst {
    static let kLoadAlertText = "Please give a network name"
    static let kCreateAlertText = "Please setup the network correctly"
    static let kAlertTitle = "Wrong Setup"
}

class SetupViewController: UIViewController {

    var networkName : String!
    var learningRate : String!
    var momentum : String!
    
    @IBOutlet weak var networkNameTxtField: UITextField!
    @IBOutlet weak var momentumTxtField: UITextField!
    @IBOutlet weak var learningRateTxtField: UITextField!

    @IBAction func loadBtnClicked(_ sender: UIButton) {
        
        if !networkNameIsEmpty() {
            FFNNManager.instance.createNetworkFromFileName(self.networkName)
            self.performSegue(withIdentifier: "toNetwork", sender: self)
        }else{
            let alert = UIAlertController(title: AlertTextConst.kAlertTitle, message: AlertTextConst.kLoadAlertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func newNetworkBtnClicked(_ sender: AnyObject) {
        
        if !networkNameIsEmpty()
            && !learningRateIsEmpty()
            && !momentumIsEmpty() {
                
            FFNNManager.instance.createNetwork(30*30, hidden: 601, outputs: 4, learningRate: Float(learningRate)!, momentum: Float(momentum)!)
            self.performSegue(withIdentifier: "toNetwork", sender: self)
                
        }else{
            
            let alert = UIAlertController(title: AlertTextConst.kAlertTitle, message: AlertTextConst.kCreateAlertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func learningRateIsEmpty() -> Bool {
        
        self.learningRate = learningRateTxtField.text!
        
        guard learningRate.isEmpty else {
            return false
        }
        
        return true
    }
    
    func momentumIsEmpty() -> Bool {
        
        self.momentum = momentumTxtField.text!
        
        guard momentum.isEmpty else {
            return false
        }
        
        return true
    }

    func networkNameIsEmpty() -> Bool {
        
        self.networkName = networkNameTxtField.text!
        
        guard networkName.isEmpty else {
            return false
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toNetwork"{
            
            let vc : ViewController = segue.destination as! ViewController
            vc.currentNetworkName = networkName
            
        }
        
    }
    

}
