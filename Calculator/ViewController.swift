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
    var brain = CalculatorBrain()
    
    @IBAction func clearOperandStack() {
        userIsTheMiddleOfTypingANumber = false
        brain.clearOpStack()
        brain.clearVariables()
        displayValue = nil
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
            history.text = " \(brain)"
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
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func negate(sender: UIButton) {
        if userIsTheMiddleOfTypingANumber {
            if display.text!.hasPrefix("−") {
                display.text = display.text!.substringFromIndex(display.text!.startIndex.advancedBy(1))
            } else {
                display.text = "−" + display.text!
            }
        } else {
            if let operation = sender.currentTitle {
                brain.performOperation(operation)
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
    }
    
    @IBAction func enter() {
        userIsTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func setVariable() {
        userIsTheMiddleOfTypingANumber = false
        if let value = displayValue {
            brain.variableValues["M"] = value
        }
        
        if let result = brain.evaluate() {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func enterVariable() {
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            displayValue = nil
        }
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
                history.text = "\(brain) ="
            } else {
                display.text = "0"
                history.text = " \(brain)"
            }
            userIsTheMiddleOfTypingANumber = false
        }
    }
}

