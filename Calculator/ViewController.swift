//
//  ViewController.swift
//  Calculator
//
//  Created by Wallace Wu on 2015-12-07.
//  Copyright © 2015 Wallace Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsTheMiddleOfTypingANumber = false
    
    @IBAction func clearOperandStack() {
        userIsTheMiddleOfTypingANumber = false
        displayValue = 0
        operandStack.removeAll()
        history.text = " "
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTheMiddleOfTypingANumber {
            if digit != "." || display.text!.rangeOfString(".") == nil {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func enterConstant(sender: UIButton) {
        if userIsTheMiddleOfTypingANumber {
            enter()
        }
        
        var validConstant = true
        let constant = sender.currentTitle!
        switch constant {
        case "π":
            displayValue = M_PI
            enter()
        default: validConstant = false
        }
        
        if validConstant {
            history.text = history.text! + " \(constant)"
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsTheMiddleOfTypingANumber {
            enter()
        }
        
        var validOperation = true
        
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        default: validOperation = false
        }
        
        if validOperation {
            history.text = history.text! + " \(operation)"
        }
    }
    
    @nonobjc
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    @nonobjc
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        if userIsTheMiddleOfTypingANumber {
            history.text = history.text! + " " + display.text!
        }
        
        userIsTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        print("operandStack = \(operandStack)")
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        
        set {
            display.text = "\(newValue)"
            userIsTheMiddleOfTypingANumber = false
        }
    }
}

