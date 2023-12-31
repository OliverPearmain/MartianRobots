import XCTest

// This class helps surface test failures by issuing an assertionFailure
public class TestRunner: NSObject, XCTestObservation {
    private var testFailures: [(XCTestCase, String, UInt)] = []

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        testFailures.append((testCase, description, UInt(lineNumber)))
    }

    public func runAllTests() {
        XCTestObservationCenter.shared.addTestObserver(self)

        WorldTests.defaultTestSuite.run()
        RobotPositionTests.defaultTestSuite.run()
        MartianRobotsInputTests.defaultTestSuite.run()
        MartianRobotsOutputTests.defaultTestSuite.run()
        ProcessInputStringTests.defaultTestSuite.run()
        ProcessInputTests.defaultTestSuite.run()
        MoveRobotInstructionsTests.defaultTestSuite.run()
        MoveRobotInstructionTests.defaultTestSuite.run()
        TurnRobotLeftTests.defaultTestSuite.run()
        TurnRobotRightTests.defaultTestSuite.run()
        MoveRobotForwardTests.defaultTestSuite.run()
        AreCoordinatesInsideTests.defaultTestSuite.run()
        AreCoordinatesOnAScentTests.defaultTestSuite.run()

        if testFailures.isEmpty {
            print("\n***** ALL TESTS SUCCEEDED *****")
        } else {
            print("\n***** TEST FAILURES *****")
            for testFailure in testFailures {
                print("\(testFailure.0), line: \(testFailure.2)")
                print("   \(testFailure.1)")
            }
            print("")
            assertionFailure("Tests failed, please see console output for details)")
        }
    }
}

class WorldTests: XCTestCase {

    func test_init_tooFewComponents_throws() {
        XCTAssertThrowsError(try World("1"))
    }

    func test_init_tooManyComponents_throws() {
        XCTAssertThrowsError(try World("1 2 3"))
    }

    func test_init_invalidComponent_throws() {
        XCTAssertThrowsError(try World("A 0"))
    }

    func test_init_negativeInt_throws() {
        XCTAssertThrowsError(try World("0 -1"))
    }

    func test_init_successA() throws {
        let world = try World("0 0")
        XCTAssertEqual(world.maxX, 0)
        XCTAssertEqual(world.maxY, 0)
    }

    func test_init_successB() throws {
        let world = try World("125 2099")
        XCTAssertEqual(world.maxX, 125)
        XCTAssertEqual(world.maxY, 2099)
    }
}

public class RobotPositionTests: XCTestCase {

    func test_init_tooFewComponents_throws() {
        XCTAssertThrowsError(try RobotPosition("1 2"))
    }

    func test_init_tooManyComponents_throws() {
        XCTAssertThrowsError(try RobotPosition("1 2 S LOST X"))
    }

    func test_init_fourthComponentIsNotLOST_throws() {
        XCTAssertThrowsError(try RobotPosition("0 0 N NOT-LOST"))
    }

    func test_init_negativeInt_throws() {
        XCTAssertThrowsError(try RobotPosition("0 -1 N"))
    }

    func test_init_successA() throws {
        let robotPosition = try RobotPosition("0 0 S")
        XCTAssertEqual(robotPosition.x, 0)
        XCTAssertEqual(robotPosition.y, 0)
        XCTAssertEqual(robotPosition.direction, .south)
        XCTAssertEqual(robotPosition.description, "0 0 S")
    }

    func test_init_successB() throws {
        let robotPosition = try RobotPosition("125 2099 W")
        XCTAssertEqual(robotPosition.x, 125)
        XCTAssertEqual(robotPosition.y, 2099)
        XCTAssertEqual(robotPosition.direction, .west)
        XCTAssertEqual(robotPosition.description, "125 2099 W")
    }
}

class MartianRobotsInputTests: XCTestCase {

    func test_init_tooFewComponents_throws() {
        XCTAssertThrowsError(try MartianRobotsInput(""))
    }

    func test_init_noRobots_success() throws {
        let input = try MartianRobotsInput("""
            10 10
        """)
        XCTAssertEqual(input.world, World(maxX: 10, maxY: 10, scents: []))
        XCTAssertEqual(input.robotPositionAndInstructionsList.count, 0)
    }

    func test_init_oneRobot_success() throws {
        let input = try MartianRobotsInput("""
            10 10
            1 2 W
            LFR
        """)
        XCTAssertEqual(input.world, World(maxX: 10, maxY: 10, scents: []))
        XCTAssertEqual(input.robotPositionAndInstructionsList.count, 1)
        XCTAssertEqual(input.robotPositionAndInstructionsList[0].robotPosition, RobotPosition(x: 1, y: 2, direction: .west, isLost: false))
        XCTAssertEqual(input.robotPositionAndInstructionsList[0].instructions, [.left, .forward, .right])
    }

    func test_init_manyRobots_success() throws {
        let input = try MartianRobotsInput("""
            5 3
            1 1 E
            RFRFRFRF

            3 2 N
            FRRFLLFFRRFLL

            0 3 W
            LLFFFLFLFL
        """)
        XCTAssertEqual(input.world, World(maxX: 5, maxY: 3, scents: []))
        XCTAssertEqual(input.robotPositionAndInstructionsList.count, 3)
        XCTAssertEqual(input.robotPositionAndInstructionsList[0].robotPosition, RobotPosition(x: 1, y: 1, direction: .east, isLost: false))
        XCTAssertEqual(input.robotPositionAndInstructionsList[0].instructions, [.right, .forward, .right, .forward, .right, .forward, .right, .forward])
        XCTAssertEqual(input.robotPositionAndInstructionsList[1].robotPosition, RobotPosition(x: 3, y: 2, direction: .north, isLost: false))
        XCTAssertEqual(input.robotPositionAndInstructionsList[1].instructions, [.forward, .right, .right, .forward, .left, .left, .forward, .forward, .right, .right, . forward, .left, .left])
        XCTAssertEqual(input.robotPositionAndInstructionsList[2].robotPosition, RobotPosition(x: 0, y: 3, direction: .west, isLost: false))
        XCTAssertEqual(input.robotPositionAndInstructionsList[2].instructions, [.left, .left, .forward, .forward, .forward, .left, .forward, .left, .forward, .left])
    }

    func test_init_misingInstructions_throw() {
        XCTAssertThrowsError(try MartianRobotsInput("""
            5 3
            1 1 E
        """))
    }
}

class MartianRobotsOutputTests: XCTestCase {

    func test_description_noRobotPositions_empty() {
        let output = MartianRobotsOutput(robotPositions: [])
        XCTAssertEqual(output.description, "")
    }

    func test_description_oneRobotPosition_success() {
        let output = MartianRobotsOutput(robotPositions: [
            RobotPosition(x: 1, y: 1, direction: .east, isLost: false),
        ])
        XCTAssertEqual(output.description, "1 1 E")
    }

    func test_description_manyRobotPosition_success() {
        let output = MartianRobotsOutput(robotPositions: [
            RobotPosition(x: 1, y: 1, direction: .east, isLost: false),
            RobotPosition(x: 3, y: 2, direction: .north, isLost: false),
            RobotPosition(x: 0, y: 3, direction: .west, isLost: true)
        ])
        XCTAssertEqual(output.description, """
        1 1 E
        3 2 N
        0 3 W LOST
        """)
    }
}

public class ProcessInputStringTests: XCTestCase {

    public func test_badInputString_throws() {
        let inputString = """
            10 10
            1 2 W
        """
        XCTAssertThrowsError(try process(inputString: inputString))
    }

    public func test_goodInputString_success() throws {
        let inputString = """
            5 3
            1 1 E
            RFRFRFRF

            3 2 N
            FRRFLLFFRRFLL

            0 3 W
            LLFFFLFLFL
        """

        let outputString = try process(inputString: inputString)

        XCTAssertEqual(outputString, """
        1 1 E
        3 3 N LOST
        2 3 S
        """)
    }
}

public class ProcessInputTests: XCTestCase {

    public func test_success() throws {
        let input = try MartianRobotsInput("""
            5 3
            1 1 E
            RFRFRFRF

            3 2 N
            FRRFLLFFRRFLL

            0 3 W
            LLFFFLFLFL
        """)

        let output = process(input: input)

        XCTAssertEqual(output.robotPositions, [
            RobotPosition(x: 1, y: 1, direction: .east, isLost: false),
            RobotPosition(x: 3, y: 3, direction: .north, isLost: true),
            RobotPosition(x: 2, y: 3, direction: .south, isLost: false)
        ])
    }
}

public class MoveRobotInstructionsTests: XCTestCase {

    public func test_left_forward_right() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")
        let inputInstructions: [Instruction] = [.left, .forward, .right]

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instructions: inputInstructions)

        XCTAssertEqual(robotPosition.description, "0 2 N")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_forward_right_forward() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")
        let inputInstructions: [Instruction] = [.forward, .right, .forward]

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instructions: inputInstructions)

        XCTAssertEqual(robotPosition.description, "2 3 E")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_whenLost_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N LOST")
        let inputWorld = try World("100 100")
        let inputInstructions: [Instruction] = [.forward, .right, .forward]

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instructions: inputInstructions)

        XCTAssertEqual(robotPosition.description, "0 2 N LOST")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_whenOnScentAndWouldGoOffGrid_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N")
        let inputWorld = World(maxX: 2, maxY: 2, scents: [Scent(x: 0, y: 2)])
        let inputInstructions: [Instruction] = [.forward]

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instructions: inputInstructions)

        XCTAssertEqual(robotPosition.description, "0 2 N")
        XCTAssertEqual(world, inputWorld)
    }
}

public class MoveRobotInstructionTests: XCTestCase {

    public func test_left() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")
        let inputInstruction = try Instruction("L")

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instruction: inputInstruction)

        XCTAssertEqual(robotPosition.description, "1 2 W")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_right() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")
        let inputInstruction = try Instruction("R")

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instruction: inputInstruction)

        XCTAssertEqual(robotPosition.description, "1 2 E")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_forward() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")
        let inputInstruction = try Instruction("F")

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instruction: inputInstruction)

        XCTAssertEqual(robotPosition.description, "1 3 N")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_whenLost_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N LOST")
        let inputWorld = try World("100 100")
        let inputInstruction = try Instruction("F")

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instruction: inputInstruction)

        XCTAssertEqual(robotPosition.description, "0 2 N LOST")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_whenOnScentAndWouldGoOffGrid_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N")
        let inputWorld = World(maxX: 2, maxY: 2, scents: [Scent(x: 0, y: 2)])
        let inputInstruction = try Instruction("F")

        let (robotPosition, world) = moveRobot(at: inputRobotPosition, in: inputWorld, instruction: inputInstruction)

        XCTAssertEqual(robotPosition.description, "0 2 N")
        XCTAssertEqual(world, inputWorld)
    }
}

public class TurnRobotLeftTests: XCTestCase {

    public func test_north_to_west() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotLeft(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 W")
    }

    public func test_east_to_north() throws {
        let inputRobotPosition = try RobotPosition("1 2 E")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotLeft(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 N")
    }

    public func test_south_to_east() throws {
        let inputRobotPosition = try RobotPosition("1 2 S")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotLeft(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 E")
    }

    public func test_west_to_south() throws {
        let inputRobotPosition = try RobotPosition("1 2 W")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotLeft(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 S")
    }

    public func test_whenLost_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N LOST")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotLeft(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 N LOST")
    }
}

public class TurnRobotRightTests: XCTestCase {

    public func test_north_to_east() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotRight(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 E")
    }

    public func test_east_to_south() throws {
        let inputRobotPosition = try RobotPosition("1 2 E")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotRight(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 S")
    }

    public func test_south_to_west() throws {
        let inputRobotPosition = try RobotPosition("1 2 S")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotRight(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 W")
    }

    public func test_west_to_north() throws {
        let inputRobotPosition = try RobotPosition("1 2 W")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotRight(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 2 N")
    }

    public func test_whenLost_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N LOST")
        let inputWorld = try World("100 100")

        let robotPosition = turnRobotRight(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 N LOST")
    }
}

public class MoveRobotForwardTests: XCTestCase {

    public func test_north() throws {
        let inputRobotPosition = try RobotPosition("1 2 N")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 3 N")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_east() throws {
        let inputRobotPosition = try RobotPosition("1 2 E")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "2 2 E")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_south() throws {
        let inputRobotPosition = try RobotPosition("1 2 S")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "1 1 S")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_west() throws {
        let inputRobotPosition = try RobotPosition("1 2 W")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 W")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_movesOffGrid_isLost_updatesScents() throws {
        let inputRobotPosition = try RobotPosition("0 2 W")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 W LOST")
        XCTAssertEqual(world.scents, [Scent(x: 0, y: 2)])
    }

    public func test_whenLost_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N LOST")
        let inputWorld = try World("100 100")

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 N LOST")
        XCTAssertEqual(world, inputWorld)
    }

    public func test_whenOnScentAndWouldGoOffGrid_doesNotMove() throws {
        let inputRobotPosition = try RobotPosition("0 2 N")
        let inputWorld = World(maxX: 2, maxY: 2, scents: [Scent(x: 0, y: 2)])

        let (robotPosition, world) = moveRobotForward(at: inputRobotPosition, in: inputWorld)

        XCTAssertEqual(robotPosition.description, "0 2 N")
        XCTAssertEqual(world, inputWorld)
    }
}

public class AreCoordinatesInsideTests: XCTestCase {

    public func test_1x1_grid() throws {
        let inputWorld = try World("0 0")
        XCTAssertEqual(areCoordinates(x: 0, y: 0, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: -1, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: -1, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 1, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: 1, inside: inputWorld), false)
    }

    public func test_1x2_grid() throws {
        let inputWorld = try World("0 1")
        XCTAssertEqual(areCoordinates(x: 0, y: 0, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: 0, y: 1, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: -1, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: -1, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 1, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: 2, inside: inputWorld), false)
    }


    public func test_2x1_grid() throws {
        let inputWorld = try World("1 0")
        XCTAssertEqual(areCoordinates(x: 0, y: 0, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: 1, y: 0, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: -1, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: -1, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 2, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: 1, inside: inputWorld), false)
    }

    public func test_35x401_grid() throws {
        let inputWorld = try World("34 400")
        XCTAssertEqual(areCoordinates(x: 0, y: 0, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: 34, y: 400, inside: inputWorld), true)
        XCTAssertEqual(areCoordinates(x: -1, y: 400, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 34, y: -1, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 35, y: 0, inside: inputWorld), false)
        XCTAssertEqual(areCoordinates(x: 0, y: 401, inside: inputWorld), false)
    }
}

public class AreCoordinatesOnAScentTests: XCTestCase {

    public func test_scentsEmpty() throws {
        let inputScents: Set<Scent> = []
        XCTAssertEqual(areCoordinatesOnAScent(x: 0, y: 0, scents: inputScents), false)
    }

    public func test_scentsPopulated() throws {
        let inputScents: Set<Scent> = [
            Scent(x: 0, y: 1),
            Scent(x: 1, y: 0)
        ]
        XCTAssertEqual(areCoordinatesOnAScent(x: 0, y: 0, scents: inputScents), false)
        XCTAssertEqual(areCoordinatesOnAScent(x: 0, y: 1, scents: inputScents), true)
        XCTAssertEqual(areCoordinatesOnAScent(x: 1, y: 0, scents: inputScents), true)
        XCTAssertEqual(areCoordinatesOnAScent(x: 1, y: 1, scents: inputScents), false)
    }
}
