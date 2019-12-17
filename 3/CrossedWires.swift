#!/usr/bin/swift

import Foundation

protocol Command {
    func perform (currentPosition: PositionWithSteps) -> PositionWithSteps
}

struct GoLeft: Command {
    func perform (currentPosition: PositionWithSteps) -> PositionWithSteps {
        let position = Position(x: currentPosition.position.x - 1, y: currentPosition.position.y)
        return PositionWithSteps(position: position, steps: currentPosition.steps + 1)
    }
}

struct GoRight: Command {
    func perform (currentPosition: PositionWithSteps) -> PositionWithSteps {
        let position = Position(x: currentPosition.position.x + 1, y: currentPosition.position.y)
        return PositionWithSteps(position: position, steps: currentPosition.steps + 1)
    }
}

struct GoUp: Command {
    func perform (currentPosition: PositionWithSteps) -> PositionWithSteps {
        let position = Position(x: currentPosition.position.x, y: currentPosition.position.y + 1)
        return PositionWithSteps(position: position, steps: currentPosition.steps + 1)
    }
}

struct GoDown: Command {
    func perform (currentPosition: PositionWithSteps) -> PositionWithSteps {
        let position = Position(x: currentPosition.position.x, y: currentPosition.position.y - 1)
        return PositionWithSteps(position: position, steps: currentPosition.steps + 1)
    }
}

struct PositionWithSteps: Hashable {
    let position: Position
    let steps: Int

    init(position: Position, steps: Int) {
        self.position = position
        self.steps = steps
    }

}

struct Position: Hashable {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func getManhattanDistance() -> Int {
        return abs(self.x) + abs(self.y)
    }
}

struct Wire {
    private var currentPosition: PositionWithSteps = PositionWithSteps(position: Position(x: 0, y: 0), steps: 0)
    private var commands: [Command] = []
    private var routePositions: [Position] = []
    private var routePositionsWithSteps: [PositionWithSteps] = []
    let wireCommands: [String]

    init(wireCommands: [String]) {
        self.wireCommands = wireCommands
        for stringCommands in self.wireCommands {
            let commandTimes = transformStringToCommand(stringCommands)
            self.addCommand(commandTimes.command, times: commandTimes.times)
        }
    }

    func getCommands() -> [Command] {
        return commands
    }

    mutating func addCommand(_ command: Command, times: Int) {
        for _ in 1...times {
            self.commands.append(command)
        }
    }

    mutating func addCommands(_ commands: [Command]) {
        self.commands.append(contentsOf: commands)
    }

    func getPosition() -> PositionWithSteps {
        return currentPosition
    }

    func getRoutePositions() -> [Position] {
        return self.routePositions
    }

    func getRoutePositionsWithSteps() -> [PositionWithSteps] {
        return self.routePositionsWithSteps
    }

    mutating func changeCurrentPosition(_ newPosition: PositionWithSteps) {
        self.routePositions.append(newPosition.position)
        self.routePositionsWithSteps.append(newPosition)
        self.currentPosition = newPosition
    }
}

func getCommand(from input: Character) -> Command {
    switch input {
        case "U": 
            return GoUp()
        case "D":
            return GoDown()
        case "L":
            return GoLeft()
        case "R":
            return GoRight()
        default:
            return GoDown()
    }
}

func parseCrossedWires(from filePath: String) -> [Wire]? {
    do {
        return try String(contentsOfFile: filePath, encoding: .utf8)
                        .components(separatedBy: "\n")
                        .map({ Wire(wireCommands: $0.components(separatedBy: ","))})

                        
    } catch {
        print("Couldn't read file at \(filePath)")
        print(error)
    }  
    return nil
}

func transformStringToCommand(_ commandString: String) -> (command: Command, times: Int) {
    let command = getCommand(from: commandString.first!)
    let times = Int(commandString.dropFirst())!
    return (command, times)
}

func findCommonPositions(_ firstPositions: [Position], _ secondPositions: [Position]) -> [Position] {
    let firstSet = Set(firstPositions)
    let secondSet = Set(secondPositions)
    return Array(firstSet.intersection(secondSet))
}

func shortedStepCountWithCommonPosition(_ stepDictionary: [Position: [PositionWithSteps]], _ commonPositions: [Position]) -> Int {
    return stepDictionary.filter({ commonPositions.contains($0.key )})
                                        .map({ $0.key })
                                        .compactMap({  return stepDictionary[$0]?.map({ $0.steps }).reduce(0, +) })
                                        .min()!
}

func runCrossedWires(){
    let filePath = CommandLine.arguments.indices.contains(1) ? CommandLine.arguments[1] : "input.txt"
    guard var wires = parseCrossedWires(from: filePath), !wires.isEmpty else { return }
    
    var stepDictionary: [Position: [PositionWithSteps]] = [:]
    
    for index in 0..<wires.count {
        for command in wires[index].getCommands() {
            let newPosition = command.perform(currentPosition: wires[index].getPosition())
            wires[index].changeCurrentPosition(newPosition)
            var array = stepDictionary[newPosition.position] ?? []
            array.append(newPosition)
            stepDictionary[newPosition.position] = array
        }
    }

    if wires.count == 2 {
        let commonPositions = findCommonPositions(wires[0].getRoutePositions(), wires[1].getRoutePositions())
        let lowestManhattanDistance = commonPositions.map({ $0.getManhattanDistance() }).min() ?? 0
        print("Lowest Manhattan Distance: \(lowestManhattanDistance)")

        let minArray = shortedStepCountWithCommonPosition(stepDictionary, commonPositions)
        print("Shortest step: \(minArray)")   
    }

}

runCrossedWires()