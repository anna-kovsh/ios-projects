//
//  ViewController.swift
//  Calculator
//
//  Created by Anna Kovsh on 11/13/16.
//  Copyright © 2016 Anna Kovsh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTiping = false    
    private var brain = CalculatorBrain()
    
    var savedProgram: CalculatorBrain.ProperyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTiping && textCurrentlyInDisplay != "0" {
            display.text = textCurrentlyInDisplay + digit
            descriptionLabel.text! = descriptionLabel.text! + digit
        } else {
            display.text = digit
            if brain.isPartialResult {
                let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -3))
                descriptionLabel.text = str + digit
            } else {
                descriptionLabel.text = digit
            }
        }
        userIsInTheMiddleOfTiping = true
        
    }
    
    @IBAction private func touchFloatingPoint(_ sender: UIButton) {
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTiping {
            if textCurrentlyInDisplay.contains(".") == false {
                display.text = textCurrentlyInDisplay + "."
                descriptionLabel.text! = descriptionLabel.text! + "."
            }
        } else {
            display.text = "0."
            if brain.isPartialResult {
                let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -3))
                descriptionLabel.text = str + "0."
            } else {
                descriptionLabel.text = "0."
            }
            userIsInTheMiddleOfTiping = true
        }
    }
  
    @IBAction private func reset(_ sender: UIButton) {
        brain.reset()
        display.text! = "0"
        userIsInTheMiddleOfTiping = false
        descriptionLabel.text! = ""
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var equalsPressed = false;
    
    @IBAction private func performOperation(_ sender: UIButton) {
        addOperationToDescription(operation: sender.currentTitle!)
        
        if userIsInTheMiddleOfTiping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTiping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        
        // show int result without zero
        let strDisplayValue = String(displayValue)
        let index1 = strDisplayValue.index(strDisplayValue.endIndex, offsetBy: -2)
        print(strDisplayValue.substring(from: index1))
        if strDisplayValue.substring(from: index1) == ".0" {
            display.text = strDisplayValue.substring(to: index1)
        }
    }
    
    private func addOperationToDescription(operation: String) {
        let operationSymbols = operation + "..."
        let lastSymbol = descriptionLabel.text! != "" ? descriptionLabel.text!.substring(from: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -1)) : ""
        switch brain.getOperationType(symbol: operation) {
            case "CONST":
                if brain.isPartialResult {
                    let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -3))
                    descriptionLabel.text = str + operation
                } else {
                    descriptionLabel.text = operation
                }
            case "UNARY":
                if (userIsInTheMiddleOfTiping) {
                    let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -String(display.text!).characters.count))
                    descriptionLabel.text = str + operation + display.text!
                } else if brain.isPartialResult {
                    descriptionLabel.text = operation + descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -4))
                } else {
                    descriptionLabel.text = operation + "(" + descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -1)) + ")="
                }
            case "BINARY":
                if userIsInTheMiddleOfTiping || display.text! == "0" || lastSymbol != "=" {
                    descriptionLabel.text! = descriptionLabel.text! + operationSymbols
                } else {
                    let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: brain.isPartialResult ? -4 : -1))
                    descriptionLabel.text = str + operationSymbols
            }
            case "EQUALS":
                if (brain.isPartialResult && lastSymbol == ".") {
                    let str = descriptionLabel.text!.substring(to: descriptionLabel.text!.index(descriptionLabel.text!.endIndex, offsetBy: -3))
                    descriptionLabel.text = str + display.text!
                }
                if lastSymbol != "=" {
                    descriptionLabel.text! = descriptionLabel.text! + operation
                }
            case "NONE": break
            default: break
        }
       

    }
    


}

