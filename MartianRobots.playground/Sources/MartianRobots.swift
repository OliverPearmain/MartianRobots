import Foundation

public enum MartianRobotsError: Error {
    case invalidNumberOfComponentsInWorld
    case invalidTypesInWorld
    case invalidNumberOfComponentsInRobotPosition
    case invalidTypesInRobotPosition
    case invalidDirection
    case invalidInstruction
}

public struct World: CustomStringConvertible {
    public let maxX: UInt
    public let maxY: UInt

    public init(maxX: UInt, maxY: UInt) {
        self.maxX = maxX
        self.maxY = maxY
    }

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

    init(_ rawValue: String) throws {
        guard let direction = Self(rawValue: rawValue) else {
            throw MartianRobotsError.invalidDirection
        }
        self = direction
    }
}

public enum Instruction: String {
    case left = "L"
    case right = "R"
    case forward = "F"

    init(_ rawValue: String) throws {
        guard let instruction = Self(rawValue: rawValue) else {
            throw MartianRobotsError.invalidInstruction
        }
        self = instruction
    }
}

public struct RobotPosition: CustomStringConvertible {
    let x: UInt
    let y: UInt
    let direction: Direction
    let isLost: Bool

    public init(x: UInt, y: UInt, direction: Direction, isLost: Bool) {
        self.x = x
        self.y = y
        self.direction = direction
        self.isLost = isLost
    }

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

func moveRobot(at robotPosition: RobotPosition, in world: World, instruction: Instruction) -> RobotPosition {
    switch instruction {
    case .left:
        return turnRobotLeft(at: robotPosition, in: world)
    case .right:
        return turnRobotRight(at: robotPosition, in: world)
    case .forward:
        return moveRobotForward(at: robotPosition, in: world)
    }
}

func turnRobotLeft(at robotPosition: RobotPosition, in world: World) -> RobotPosition {
    let direction: Direction
    switch robotPosition.direction {
    case .north:
        direction = .west
    case .east:
        direction = .north
    case .south:
        direction = .east
    case .west:
        direction = .south
    }
    return RobotPosition(x: robotPosition.x,
                         y: robotPosition.y,
                         direction: direction,
                         isLost: false)
}

func turnRobotRight(at robotPosition: RobotPosition, in world: World) -> RobotPosition {
    let direction: Direction
    switch robotPosition.direction {
    case .north:
        direction = .east
    case .east:
        direction = .south
    case .south:
        direction = .west
    case .west:
        direction = .north
    }
    return RobotPosition(x: robotPosition.x,
                         y: robotPosition.y,
                         direction: direction,
                         isLost: false)
}

func moveRobotForward(at robotPosition: RobotPosition, in world: World) -> RobotPosition {
    switch robotPosition.direction {
    case .north:
        let y = robotPosition.y + 1
        return RobotPosition(x: robotPosition.x,
                             y: y,
                             direction: robotPosition.direction,
                             isLost: false)
    case .east:
        let x = robotPosition.x + 1
        return RobotPosition(x: x,
                             y: robotPosition.y,
                             direction: robotPosition.direction,
                             isLost: false)
    case .south:
        let y = robotPosition.y - 1
        return RobotPosition(x: robotPosition.x,
                             y: y,
                             direction: robotPosition.direction,
                             isLost: false)
    case .west:
        let x = robotPosition.x - 1
        return RobotPosition(x: x,
                             y: robotPosition.y,
                             direction: robotPosition.direction,
                             isLost: false)
    }
}
