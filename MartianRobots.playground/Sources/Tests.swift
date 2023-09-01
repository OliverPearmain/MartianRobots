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
        XCTAssertEqual(world.description, "0 0")
    }

    func test_init_successB() throws {
        let world = try World("125 2099")
        XCTAssertEqual(world.maxX, 125)
        XCTAssertEqual(world.maxY, 2099)
        XCTAssertEqual(world.description, "125 2099")
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


// TODO:
//public class GameTests: XCTestCase {
//
//    func test_() {
//        let input = """
//            5 3
//            1 1 E
//            RFRFRFRF
//
//            3 2 N
//            FRRFLLFFRRFLL
//
//            0 3 W
//            LLFFFLFLFL
//        """
//
//        let expectedOutput = """
//            1 1 E
//            3 3 N LOST
//            2 3 S
//        """
//    }
//}