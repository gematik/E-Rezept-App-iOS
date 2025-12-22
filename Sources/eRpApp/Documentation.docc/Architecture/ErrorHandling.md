# Error Handling

Error Codes are used for identifying individual Errors as well as recognizing cascading errors.

## Format

Errors follow a simple format as follows:

`i-ABCXY`

  - ABC: 3-Digit Identifier for the Error Type
  - XY: 2-Digit Identifier for the individual Error

## Implementation

Conforming Error Types are annotated with the `@CodedError("ABC")` macro where `ABC` is the 3-Digit identifier for the individual Error. While introducing the annotation, all Modules receive a number range, such as  `1xx` for all IDP Module related Errors. This might change whenever a Error moves into another module for refactoring purposes. Error Codes **MUST NOT** change in these cases, to minimize communication errors.

Each Error case is annotated with `@ErrorCode("XY")`, where `XY` is the 2-Digit identifier of the individual case. The number **MUST NOT** neither change, nor be duplicated over the live span of the Error Type.

The two macros are generate the conformance to `CodedError`. The conformance can then be used to implement user facing error messages which include the Error identifier.

## Generated Documentation

The documentation is generated using a fastlane action. See Fastfile for the implementation. The output contains a simple list as well as complex search helper html files, that should help understanding user facing errors for support cases.
