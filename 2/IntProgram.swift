#!/usr/bin/swift

import Foundation

func readIntProgram(from filePath: String) -> [Int]? {
    do {
        return try String(contentsOfFile: filePath, encoding: .utf8)
                        .filter({!$0.isNewline && !$0.isWhitespace})
                        .components(separatedBy: ",")
                        .filter({ $0 != "" }).compactMap({ Int($0) })
    } catch {
        print("Couldn't read file at \(filePath)")
        print(error)
    }  
    return nil
}

func runOperation(for opCodes: [Int], at index: Int, _ function: (Int, Int) -> Int) -> [Int] {
    var updatedOpCodes = opCodes
    let indexValue1 = updatedOpCodes[index+1]
    let indexValue2 = updatedOpCodes[index+2]
    let indexValue3 = updatedOpCodes[index+3]
    updatedOpCodes[indexValue3] = function(updatedOpCodes[indexValue1], updatedOpCodes[indexValue2])
    return updatedOpCodes
}

func apply1202Program(for opCodes: [Int], _ value1: Int, _ value2: Int) -> [Int] {
    var updatedOpCodes = opCodes
    if updatedOpCodes.indices.contains(1) && opCodes.indices.contains(2) {
        updatedOpCodes[1] = value1
        updatedOpCodes[2] = value2
    }
    return updatedOpCodes
}

func run(_ opCodes: [Int], _ value1: Int, _ value2: Int) -> Int {
    var opCodes1202 = apply1202Program(for: opCodes, value1, value2)

    opCodeLoop: for index in stride(from: 0, to: opCodes1202.count.advanced(by: -1), by: 4) {
        let operation = opCodes1202[index]
        
        switch operation {
            case 1: 
                opCodes1202 = runOperation(for: opCodes1202, at: index, +)
            case 2:
                opCodes1202 = runOperation(for: opCodes1202, at: index, *)
            case 99:
                break opCodeLoop
            default:
                break
        }

    } 
    return opCodes1202[0]  
}

func findIndexes(for opCodes: [Int], matching value: Int) -> (noun: Int, verb: Int) {
    var noun = 0
    var verb = 0

    bigLoop: for nounIndex in 0...99 {
        for verbIndex in 00...99 {
            if run(opCodes, nounIndex, verbIndex) == value {
                noun = nounIndex
                verb = verbIndex
                break bigLoop
            }
        }
    }
    return (noun, verb)
}

func runIntProgram() {
    let filePath = CommandLine.arguments.indices.contains(1) ? CommandLine.arguments[1] : "input.txt"
    guard let opCodes = readIntProgram(from: filePath), !opCodes.isEmpty else { return }
    print("First Half - Value at 0: \(run(opCodes, 12, 2))")
    
    let foundIndexes = findIndexes(for: opCodes, matching: 19690720)
    print("Second Half - Result is: \(100 * foundIndexes.noun + foundIndexes.verb)")
    
}

runIntProgram()