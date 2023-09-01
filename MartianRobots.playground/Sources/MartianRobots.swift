import Foundation

public enum MartianRobotsError: Error {
    case invalidNumberOfComponentsInWorld
    case invalidTypesInWorld
    case invalidNumberOfComponentsInRobotPosition
    case invalidTypesInRobotPosition
    case invalidDirection
    case invalidInstruction
    case invalidNumberOfComponentsInMartianRobotsInput
    case missingRobotInstructionsInMartianRobotsInput
}

public struct World: CustomStringConvertible, Equatable {
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

public enum Direction: String, Equatable {
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

public enum Instruction: String, Equatable {
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

public struct RobotPosition: CustomStringConvertible, Equatable {
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

public struct MartianRobotsInput {
    let world: World
    let robotPositionAndInstructionsList: [(robotPosition: RobotPosition, instructions: [Instruction])]

    public init(_ string: String) throws {
        let components = string
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter{ !$0.isEmpty }

        guard let worldLine = components.first else {
            throw MartianRobotsError.invalidNumberOfComponentsInMartianRobotsInput
        }
        let world = try World(worldLine)
        var robotPositionAndInstructionsList: [(robotPosition: RobotPosition, instructions: [Instruction])] = []

        var i = 1
        while components.count > i {
            let robotPositionLine = components[i]
            let robotPosition = try RobotPosition(robotPositionLine)
            i+=1
            guard components.count > i else {
                throw MartianRobotsError.missingRobotInstructionsInMartianRobotsInput
            }
            let instructionsLine = components[i]
            let instructions = try instructionsLine.map { try Instruction(String($0)) }
            i+=1
            robotPositionAndInstructionsList.append((robotPosition: robotPosition, instructions: instructions))
        }

        self.world = world
        self.robotPositionAndInstructionsList = robotPositionAndInstructionsList
    }
}

public struct MartianRobotsOutput: CustomStringConvertible {
    let robotPositions: [RobotPosition]

    public var description: String {
        return robotPositions.map { $0.description } .joined(separator: "\n")
    }
}

public func process(inputString: String) throws -> String {
    let input = try MartianRobotsInput(inputString)
    let output = process(input: input)
    return output.description
}

public func process(input: MartianRobotsInput) -> MartianRobotsOutput {
    let world = input.world
    var robotPositions: [RobotPosition] = []
    for (robotPosition, instructions) in input.robotPositionAndInstructionsList {
        let robotPosition = moveRobot(at: robotPosition, in: world, instructions: instructions)
        robotPositions.append(robotPosition)
    }
    return MartianRobotsOutput(robotPositions: robotPositions)
}

func moveRobot(at robotPosition: RobotPosition, in world: World, instructions: [Instruction]) -> RobotPosition {
    var robotPosition = robotPosition
    for instruction in instructions {
        robotPosition = moveRobot(at: robotPosition, in: world, instruction: instruction)
    }
    return robotPosition
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
    if robotPosition.isLost {
        // If the robot is already lost, then don't alter its position
        return robotPosition
    }
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
    if robotPosition.isLost {
        // If the robot is already lost, then don't alter its position
        return robotPosition
    }
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
    if robotPosition.isLost {
        // If the robot is already lost, then don't alter its position
        return robotPosition
    }
    var x = Int(robotPosition.x)
    var y = Int(robotPosition.y)
    switch robotPosition.direction {
    case .north:
        y = y + 1
    case .east:
        x = x + 1
    case .south:
        y = y - 1
    case .west:
        x = x - 1
    }

    guard areCoordinates(x: x, y: y, inside: world) else {
        // Mark robot as lost and do not update position
        return RobotPosition(x: robotPosition.x,
                             y: robotPosition.y,
                             direction: robotPosition.direction,
                             isLost: true)
    }
    return RobotPosition(x: UInt(x),
                         y: UInt(y),
                         direction: robotPosition.direction,
                         isLost: robotPosition.isLost)
}

func areCoordinates(x: Int, y: Int, inside world: World) -> Bool {
    return 0 <= x && x <= world.maxX && 0 <= y && y <= world.maxY
}
