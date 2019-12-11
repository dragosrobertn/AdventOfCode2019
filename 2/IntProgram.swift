#!/usr/bin/swift

import Foundation

struct Operation {
    var operation: Int
    var noun: Int
    var verb: Int
    var destinationIndex: Int

    init(_ opCodes: [Int], startingIndex: Int) {
        self.operation = opCodes[startingIndex]
        self.noun = opCodes[startingIndex + 1]
        self.verb = opCodes[startingIndex + 2]
        self.destinationIndex = opCodes[startingIndex + 3]
    }

    func perform(with opCodes: [Int]) -> Int {
        var performOperation: (Int, Int) -> Int
        switch operation {
            case 1: performOperation = (+)
            case 2: performOperation = (*)
            default: return 0
        }
        return performOperation(opCodes[noun], opCodes[verb])
    }
}

func readIntProgram(from filePath: String) -> [Int]? {
    do {
        return try String(contentsOfFile: filePath, encoding: .utf8)
                        .filter({!$0.isNewline && !$0.isWhitespace})
                        .components(separatedBy: ",")
                        .compactMap({ Int($0) })
    } catch {
        print("Couldn't read file at \(filePath)")
        print(error)
    }  
    return nil
}

func substituteNounAndVerbIn1202Program(for opCodes: [Int], _ noun: Int, _ verb: Int) -> [Int] {
    var updatedOpCodes = opCodes
    if opCodes.indices.contains(1) && opCodes.indices.contains(2) {
        updatedOpCodes[1] = noun
        updatedOpCodes[2] = verb
    }
    return updatedOpCodes
}

func run(_ opCodes: [Int], _ noun: Int, _ verb: Int) -> Int {
    var opCodes1202 = substituteNounAndVerbIn1202Program(for: opCodes, noun, verb)

    for index in stride(from: 0, to: opCodes1202.count.advanced(by: -1), by: 4) {
        let operation = Operation(opCodes1202, startingIndex: index)
        if [1,2].contains(operation.operation) {
            opCodes1202[operation.destinationIndex] = operation.perform(with: opCodes1202)
        }
        else if operation.operation == 99 {
            break
        }
    } 
    return opCodes1202[0]  
}

func findIndexes(for opCodes: [Int], matching value: Int) -> (noun: Int, verb: Int) {
    for nounIndex in 0...99 {
        for verbIndex in 0...99 {
            if run(opCodes, nounIndex, verbIndex) == value {
                return (nounIndex, verbIndex)
            }
        }
    }
    return (0, 0)
}

func runIntProgram() {
    let filePath = CommandLine.arguments.indices.contains(1) ? CommandLine.arguments[1] : "input.txt"
    guard let opCodes = readIntProgram(from: filePath), !opCodes.isEmpty else { return }
    print("First Half - Value at 0: \(run(opCodes, 12, 2))")
    
    let foundIndexes = findIndexes(for: opCodes, matching: 19690720)
    print("Second Half - Result is: \(100 * foundIndexes.noun + foundIndexes.verb)")
    
}

runIntProgram()