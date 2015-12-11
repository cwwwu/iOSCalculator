//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Wallace Wu on 2015-12-08.
//  Copyright © 2015 Wallace Wu. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let variable):
                    return variable
                case .Constant(let constant, _):
                    return constant
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .Operand(_):
                    return 0
                case .UnaryOperation(_, _):
                    return 3
                case .BinaryOperation(let symbol, _):
                    switch symbol {
                    case "×":
                        return 2
                    case "÷":
                        return 2
                    case "+":
                        return 1
                    case "−":
                        return 1
                    default:
                        return 0
                    }
                case .Variable(_):
                    return 0
                case .Constant(_, _):
                    return 0
                }
            }
        }
    }
    
    private func prettyPrint(ops: [Op], precedence: Int) -> (expression: String?,remainingOps: [Op]) {
        let unknownOp = "?"
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .UnaryOperation(let operation, _):
                let unaryExpr = prettyPrint(remainingOps, precedence: 0)
                var expr = unknownOp
                if let expression = unaryExpr.expression {
                    expr = expression
                }
                return ("\(operation)(\(expr))", unaryExpr.remainingOps)
            case .BinaryOperation(let operation, _):
                let op2Result = prettyPrint(remainingOps, precedence: op.precedence)
                let op1Result = prettyPrint(op2Result.remainingOps, precedence: op.precedence)
                var op2Expr = unknownOp
                var op1Expr = unknownOp
                if let op2 = op2Result.expression {
                    op2Expr = op2
                }
                if let op1 = op1Result.expression {
                    op1Expr = op1
                }
                if precedence > op.precedence {
                    return ("(\(op1Expr) \(operation) \(op2Expr))", op1Result.remainingOps)
                } else {
                    return ("\(op1Expr) \(operation) \(op2Expr)", op1Result.remainingOps)
                }
            case .Variable(let variable):
                return (variable, remainingOps)
            case .Constant(let constant, _):
                return (constant, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    var description: String {
        get {
            var prettyPrintString = ""
            var result: String?
            var remainder = opStack
            while true {
                (result, remainder) = prettyPrint(remainder, precedence: 0)
                if let expression = result {
                    prettyPrintString = expression + prettyPrintString
                }
                
                if remainder.isEmpty {
                    break
                }
                
                prettyPrintString = ", " + prettyPrintString
            }
            return prettyPrintString
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−", {$1 - $0}))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("+/−", {-1 * $0}))
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .Constant(_, let constant):
                return (constant, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        print("\(self)")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func clearOpStack() {
        opStack.removeAll()
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
}