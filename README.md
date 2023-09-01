# MartianRobots

## Instructions

1. Clone the repository

2. Open `MartianRobots.playground` in Xcode

3. In the playgrounds root code file (`Contents.swift`) invoke the global function `process(inputString: String)`. The function will return the appropriate `String` output, or throw an error if the input is invalid.

### Example 

```
print(try process(inputString: ("""
            5 3
            1 1 E
            RFRFRFRF

            3 2 N
            FRRFLLFFRRFLL

            0 3 W
            LLFFFLFLFL
        """)))
```

Output

```
1 1 E
3 3 N LOST
2 3 S
```

## Unit Test

The code is fully unit tested. To invoke the tests from within the playground you can use the following code:

```
TestRunner().runAllTests()
```


## A Few Notes on the Implementation

Since the task required no UI and the input and outputs are just String's I opt'ed to implement the solution in a Swift playground so there was no AppDelegate, xcproj files, Info.plist baggage and no UI to implement.

There were a number of ways to achieve the objective but a functional approach seemed the most obvious since the whole task can be broken down into simple operations that take immutable inputs and returns immutable outputs. I think this ultimately made the code more testable. 
