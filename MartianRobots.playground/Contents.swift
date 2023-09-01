import Foundation

print(try process(inputString: ("""
            5 3
            1 1 E
            RFRFRFRF

            3 2 N
            FRRFLLFFRRFLL

            0 3 W
            LLFFFLFLFL
        """)))

print("---")

print(try World("4 5"))
print(try RobotPosition("1 2 E"))
print(try RobotPosition("1 3 S"))
print(try RobotPosition("50 2323 W LOST"))

TestRunner().runAllTests()
