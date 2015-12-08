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
        displayValue = nil
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
            if history.text!.hasSuffix("=") {
                history.text = history.text!.substringToIndex(history.text!.endIndex.advancedBy(-2))
            }
        }
    }
    
    @IBAction func deleteDigit() {
        if userIsTheMiddleOfTypingANumber {
            if display.text!.characters.count == 1 {
                userIsTheMiddleOfTypingANumber = false
                displayValue = nil
            } else {
                display.text = String(display.text!.characters.dropLast())
            }
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
            if history.text!.hasSuffix("=") {
                history.text = history.text!.substringToIndex(history.text!.endIndex.advancedBy(-2))
            }
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
            history.text = history.text! + " \(operation) ="
        }
    }
    
    @IBAction func negate() {
        if userIsTheMiddleOfTypingANumber {
            if display.text!.hasPrefix("−") {
                display.text = display.text!.substringFromIndex(display.text!.startIndex.advancedBy(1))
            } else {
                display.text = "−" + display.text!
            }
        } else if operandStack.count >= 1 {
            if history.text!.hasSuffix("=") {
                history.text = history.text!.substringToIndex(history.text!.endIndex.advancedBy(-2))
            }
            history.text = history.text! + " − ="
            displayValue = -operandStack.removeLast()
            enter()
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
        operandStack.append(displayValue!)
        print("operandStack = \(operandStack)")
    }
    
    var displayValue: Double? {
        get {
            if let number = NSNumberFormatter().numberFromString(display.text!) {
                return number.doubleValue
            } else {
                return nil;
            }
        }
        
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                display.text = "0"
            }
            userIsTheMiddleOfTypingANumber = false
        }
    }
}

