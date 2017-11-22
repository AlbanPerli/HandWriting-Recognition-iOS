//
//  ViewController.swift
//  HandWriting-Learner
//
//  Created by Alban on 29.02.16.
//  Copyright © 2016 Alban Perli. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {
    
    var currentNetworkName:String!
    //
    var lastPoint:CGPoint!
    var isSwiping:Bool!
    var red:CGFloat!
    var green:CGFloat!
    var blue:CGFloat!
    var xPoints:[Float] = []
    var yPoints:[Float] = []
    //
    
    var historyDatasource = [NSDictionary]()
    
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var trainingSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var imageView: UIImageView!
    
    
    //MARK: Data preprocessing methods
    
    func preprocessedImagePixelArray()->(pixels:[Float]?,resizedImg:UIImage)?{
        
        guard self.imageView.image != nil else {
            return nil
        }
        
        let framedImg = self.framedImg()
        
        let resizedImg = framedImg!.toSize(CGSize(width: 30, height: 30))
        
        return (resizedImg.pixelsArray().pixelValues,resizedImg)
    }
    
    func framedImg() -> UIImage? {
        
        guard self.imageView.image != nil else {
            return nil
        }
        
        let freeSpaceAroundDrawinFrame:CGFloat = 5.0
        
        let topLeft = CGPoint(x: CGFloat(xPoints.min()!), y: CGFloat(yPoints.min()!))
        let bottomRight = CGPoint(x: CGFloat(xPoints.max()!), y: CGFloat(yPoints.max()!))
        
        return self.imageView.image!.extractFrame(topLeft,bottomRight: bottomRight, pixelMargin: freeSpaceAroundDrawinFrame)
    }
    
    //MARK: FFNN methods
    func trainNeurons(){
        
        // Retreive pixel from drawn image
        if let preProcessedDatas = self.preprocessedImagePixelArray() {
            
            let pixelArray = preProcessedDatas.pixels
            let img = preProcessedDatas.resizedImg
            
            guard pixelArray != nil else {
                return
            }
            
            let answer : [Float]
            
            switch segmented.selectedSegmentIndex {
            case 0:  // A
                answer = [1.0,0.0,0.0,0.0]
            case 1:  // B
                answer = [0.0,1.0,0.0,0.0]
            case 2:  // C
                answer = [0.0,0.0,1.0,0.0]
            case 3:  // D
                answer = [0.0,0.0,0.0,1.0]
            default:
                answer = []
            }
            
            let trainingValues = FFNNManager.instance.trainNetwork(pixelArray!, answer:answer, epoch: 1)
            let result = String(describing: trainingValues.output)
            
            self.result.text = result
            
            historyDatasource.insert(NSDictionary(dictionaryLiteral: ("img",img),("result",result)), at: 0)
            
            tableView.reloadData()
            
            print(trainingValues.error)
            
        }
        
        return
    }
    
    func askNeurons(){
        
        // Retreive pixel from drawn image
        if let preProcessedDatas = self.preprocessedImagePixelArray() {
            
            let pixelArray = preProcessedDatas.pixels
            
            guard pixelArray != nil else {
                return
            }
            
            // Send pixel arrays to the network and receive "prediction"
            let output = FFNNManager.instance.predictionForInput(pixelArray!)
            
            print(output)
            
            let maxValue = output.max()!
            
            // Not sure enough
            if maxValue < 0.8 {
                self.result.text = "Not sure enough"
                return
            }
            
            // Convert the max value (> 0.8) to int to get 
            // the index value of the switch
            let index = output.index(of: maxValue)! as Int
            
            self.segmented.selectedSegmentIndex = index
            
            switch index {
            case 0:
                self.result.text = "A"
            case 1:
                self.result.text = "B"
            case 2:
                self.result.text = "C"
            case 3:
                self.result.text = "D"
            default:
                self.result.text = "Not Sure"
            }
        }
    }
    
    //MARK: UI Actions
    
    @IBAction func trainingModeSwitchDidChangeValue(_ sender: UISwitch) {
        
        if sender.isOn {
            actionButton.title = "Train"
        }else {
            actionButton.title = "Ask"
        }
        
        self.tableView.isHidden = !sender.isOn
        self.result.isHidden = !sender.isOn

    }
    
    @IBAction func actionBtnClicked(_ sender: AnyObject) {
        
        if trainingSwitch.isOn {
            trainNeurons()
        }else{
            askNeurons()
        }
        
        // Release all the point
        xPoints = []
        yPoints = []
        
        // Clear the image view
        self.imageView.image = nil
        
    }
    
    
    @IBAction func saveNetworkBtnClicked(_ sender: AnyObject) {
        self.imageView.image = nil
        FFNNManager.instance.saveNetworkWithName(currentNetworkName)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: UI Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.gray.cgColor
        
        self.tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        let dico = historyDatasource[indexPath.row]
        
        cell.sentImg.image = dico["img"] as? UIImage
        cell.sentImg.layer.borderWidth = 1.0
        cell.sentImg.layer.borderColor = UIColor.gray.cgColor
        
        cell.predictionLabel.text = dico["result"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyDatasource.count
    }
    
    
    
    //MARK: Drawing methods
    override func touchesBegan(_ touches: Set<UITouch>,
        with event: UIEvent?){
            isSwiping    = false
            let touch = touches.first
            lastPoint = touch!.location(in: imageView)
            xPoints.append(Float(lastPoint.x))
            yPoints.append(Float(lastPoint.y))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
        with event: UIEvent?){
            
            isSwiping = true;
            let touch = touches.first
            let currentPoint = touch!.location(in: imageView)
            UIGraphicsBeginImageContext(self.imageView.frame.size)
            self.imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height))
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            UIGraphicsGetCurrentContext()?.strokePath()
            self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            lastPoint = currentPoint
            xPoints.append(Float(lastPoint.x))
            yPoints.append(Float(lastPoint.y))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
        with event: UIEvent?){
            if(!isSwiping) {
                // This is a single touch, draw a point
                UIGraphicsBeginImageContext(self.imageView.frame.size)
                self.imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.imageView.frame.size.width, height: self.imageView.frame.size.height))
                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                UIGraphicsGetCurrentContext()?.strokePath()
                self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
    }

}

