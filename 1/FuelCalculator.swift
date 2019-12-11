#!/usr/bin/swift

import Foundation

func readModules(from filePath: String) -> [String]? {
    do {
        return try String(contentsOfFile: filePath, encoding: .utf8)
                        .components(separatedBy: .newlines)
                        .filter({ $0 != "" })
    } catch {
        print("Couldn't read file at \(filePath)")
        print(error)
    }  
    return nil
}

func calculateFuelRecursively(for mass: Int) -> Int {
    let fuel = calculateFuelRequired(for: mass)
    return fuel > 0 ? fuel + calculateFuelRecursively(for: fuel) : 0
}

func calculateFuelRequired(for mass: Int) -> Int { mass / 3 - 2 }

func run() {
    let filePath = CommandLine.arguments.indices.contains(1) ? CommandLine.arguments[1] : "input.txt"
    guard let modules = readModules(from: filePath), !modules.isEmpty  else { return }

    print("Fuel needed 1st half: \(modules.map({ calculateFuelRequired(for: Int($0) ?? 2) }).reduce(0, +))")
    print("Fuel needed 2nd half: \(modules.map({ calculateFuelRecursively(for: Int($0) ?? 2) }).reduce(0, +))")
}

run()