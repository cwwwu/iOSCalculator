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
        displayValue = nil
        history.text = " "
        brain.clearOpStack()
        brain.clearVariables()
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
            history.text = "\(brain)"
        }
    }
    
    @IBAction func negate() {
        if userIsTheMiddleOfTypingANumber {
            if display.text!.hasPrefix("−") {
                display.text = display.text!.substringFromIndex(display.text!.startIndex.advancedBy(1))
            } else {
                display.text = "−" + display.text!
            }
        } else {
            //TODO:
        }
    }
    
    @IBAction func enter() {
        userIsTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
        history.text = "\(brain)"
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
        history.text = "\(brain)"
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
                display.text = " "
            }
            userIsTheMiddleOfTypingANumber = false
        }
    }
}

