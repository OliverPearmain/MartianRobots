import Foundation

print(try World("4 5"))
print(try RobotPosition("1 2 E"))
print(try RobotPosition("1 3 S"))
print(try RobotPosition("50 2323 W LOST"))

TestRunner().runAllTests()
