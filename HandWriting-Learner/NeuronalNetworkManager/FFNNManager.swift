//
//  FFNNManager.swift
//  DrawingApp
//
//  Created by Alban on 23.02.16.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

import UIKit

class FFNNManager: NSObject {

    static let instance : FFNNManager = FFNNManager()
    // Initialize neural network with pre-trained weights (may need to change activation function if yours was trained with a different one)
    var network:FFNN?
    
    func createNetwork(_ inputs: Int, hidden: Int, outputs:Int, learningRate: Float, momentum:Float){
        // Initialize neural network with pre-trained weights (may need to change activation function if yours was trained with a different one)
        network = FFNN(inputs: inputs, hidden:hidden , outputs: outputs, learningRate: learningRate, momentum: momentum, weights:nil, activationFunction: .Sigmoid, errorFunction: .default(average: false))
        
    }
    
    func createNetworkFromFileName(_ fileName:String){
        network = FFNN.fromFile(fileName)
    }
    
    func trainNetwork(_ inputs:[Float],answer:[Float], epoch:Int)->(output:[Float],error:Float){
        
        guard network != nil else {
            return ([],-1.0)
        }
        var output: [Float] = []
        var error: Float = 0.0
        
        for _ in 0...epoch{
            output = try! network!.update(inputs: inputs)
            error = try! network!.backpropagate(answer: answer)
        }
        return (output,error)
        
    }
    
    func predictionForInput(_ input:[Float])->[Float]{
        return try! network!.update(inputs: input)
    }
    

    func getWeights()->[Float]{
        return network!.getWeights()
    }
    
    func setNewWeight(_ weights:[Float]){
        try! network!.resetWithWeights(weights)
    }
    
    func saveNetworkWithName(_ name:String){
        FFNNManager.instance.network?.writeToFile(name)
    }
    
}
