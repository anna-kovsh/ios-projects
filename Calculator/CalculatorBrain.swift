//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Anna Kovsh on 11/14/16.
//  Copyright © 2016 Anna Kovsh. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    func setOperand (operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({-$0}),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "xⁿ" : Operation.BinaryOperation(pow),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "-" : Operation.BinaryOperation({$0 - $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation (symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value): accumulator = value
            case .UnaryOperation(let foo): accumulator = foo(accumulator)
            case .BinaryOperation(let foo):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: foo, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func getOperationType(symbol: String) -> String {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(_): return "CONST"
            case .UnaryOperation(_): return "UNARY"
            case .BinaryOperation(_): return "BINARY"
            case .Equals: return "EQUALS"
            }
        }
        return "NONE"
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    func reset() {
        pending = nil
        accumulator = 0
        internalProgram.removeAll()
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias ProperyList = AnyObject
    
    var program: ProperyList {
        get {
            return internalProgram as CalculatorBrain.ProperyList
        }
        set {
            reset()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
        set {
            
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
}
