import Foundation

public enum MartianRobotsError: Error {
    case invalidNumberOfComponentsInWorld
    case invalidTypesInWorld
    case invalidNumberOfComponentsInRobotPosition
    case invalidTypesInRobotPosition
}

public struct World: CustomStringConvertible {
    public let maxX: UInt
    public let maxY: UInt

    public init(_ string: String) throws {
        let components = string.components(separatedBy: .whitespaces)
        guard components.count == 2 else {
            throw MartianRobotsError.invalidNumberOfComponentsInWorld
        }
        guard let maxX = UInt(components[0]),
              let maxY = UInt(components[1]) else {
            throw MartianRobotsError.invalidTypesInWorld
        }
        self.maxX = maxX
        self.maxY = maxY
    }

    public var description: String {
        return "\(maxX) \(maxY)"
    }
}

public enum Direction: String {
    case north = "N"
    case east = "E"
    case south = "S"
    case west = "W"
}

public enum Action: String {
    case left = "L"
    case right = "R"
    case forward = "F"
}

public struct RobotPosition: CustomStringConvertible {
    let x: UInt
    let y: UInt
    let direction: Direction
    let isLost: Bool

    public init(_ string: String) throws {
        let components = string.components(separatedBy: .whitespaces)
        guard components.count == 3 || components.count == 4 else {
            throw MartianRobotsError.invalidNumberOfComponentsInRobotPosition
        }
        guard let x = UInt(components[0]),
              let y = UInt(components[1]),
              let direction = Direction(rawValue: components[2]) else {
            throw MartianRobotsError.invalidTypesInRobotPosition
        }
        var isLost = false
        if components.count == 4 {
            guard components[3] == "LOST" else {
                throw MartianRobotsError.invalidTypesInRobotPosition
            }
            isLost = true
        }
        self.x = x
        self.y = y
        self.direction = direction
        self.isLost = isLost
    }

    public var description: String {
        return "\(x) \(y) \(direction.rawValue)\(isLost ? " LOST" : "")"
    }
}
