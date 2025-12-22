# CodedError

A Swift package that provides macros for generating `CodedError` conformance for enums with error code annotations.

## Overview

The `@CodedError` macro replaces Sourcery stencils for generating `CodedError` conformance. It supports two approaches for specifying error codes:

1. **New `@ErrorCode` annotation approach** (recommended) - Clean, type-safe annotations
2. **Comment-based approach** (legacy) - For backward compatibility

The macro automatically generates the required extension with `erpErrorCode` and `erpErrorCodeList` properties.

## Installation

Add this package to your Swift project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/CodedError", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["CodedError"]
)
```

## Usage

### Recommended: Using @ErrorCode Annotations

```swift
import CodedError

@CodedError("029")
enum NetworkError: Error {
    @ErrorCode("01")
    case connectionTimeout
    
    @ErrorCode("02")
    case invalidResponse
    
    @ErrorCode("03")
    case serverError(statusCode: Int)
}
```

### Legacy: Comment-Based Approach

```swift
import CodedError

@CodedError("029")
enum CardWallIntroductionDomainError: Swift.Error, LocalizedError {
    // sourcery: errorCode = "01"
    case idpError(IDPError)
    // sourcery: errorCode = "02"
    case universalLinkFailed
    // sourcery: errorCode = "03"
    case kkNotFound

    var errorDescription: String? {
        switch self {
        case let .idpError(error):
            return error.localizedDescription
        case .universalLinkFailed:
            return "Universal link failed"
        case .kkNotFound:
            return "KK not found"
        }
    }
}
```

### Mixed Approach (Backward Compatibility)

You can mix both approaches in the same enum:

```swift
@CodedError("030")
enum MixedError: Error {
    @ErrorCode("01") 
    case newStyleError
    
    // sourcery: errorCode = "02"
    case legacyStyleError
}
```

**Note:** When using comment-based syntax, the macro will emit warnings suggesting to use the modern `@ErrorCode` annotation for better type safety and consistency.

## Generated Code

Both approaches automatically generate the same extension:

```swift
extension CardWallIntroductionDomainError: CodedError {
    internal var erpErrorCode: String {
        switch self {
            case .idpError: return "i-02901"
            case .universalLinkFailed: return "i-02902"
            case .kkNotFound: return "i-02903"
        }
    }
    
    internal var erpErrorCodeList: [String] {
        switch self {
            case let .idpError(error as CodedError): return [erpErrorCode] + error.erpErrorCodeList
            case .idpError(_): return [erpErrorCode]
            default: return [erpErrorCode]
        }
    }
}
```

## Features

- **Base Error Code**: Specified as macro argument (e.g., `@CodedError("029")`)
- **Case Error Codes**: Parsed from `// sourcery: errorCode = "01"` comments
- **Associated Values**: Handles cases with associated values that may conform to `CodedError`
- **Access Level**: Matches the enum's access level (public, internal, private, etc.)
- **Error Code Format**: Generates codes in format `i-{baseCode}{caseCode}` (e.g., `i-02901`)
- **Modern Syntax Suggestions**: Emits warnings when legacy comment syntax is used, suggesting to upgrade to `@ErrorCode` annotations

## Error Code List Logic

- For cases with associated values that conform to `CodedError`: Combines current error code with nested error codes
- For other cases: Returns only the current error code
- Uses pattern matching to handle both `CodedError` conforming and non-conforming associated values

## Replacing Sourcery

The `@CodedError` macro is designed as a drop-in replacement for Sourcery stencils. Simply:

1. Replace your Sourcery annotations with the `@CodedError("baseCode")` macro
2. Keep your existing `// sourcery: errorCode = "XX"` comments (the macro will suggest upgrading to `@ErrorCode` annotations)
3. Optionally, migrate to the modern `@ErrorCode("XX")` syntax for better type safety
3. Remove the Sourcery build phase from your project
4. The macro will generate the same `CodedError` extension automatically

## Building and Testing

### Build the package
```bash
swift build
```

### Run tests
```bash
swift test
```

## Requirements

- Swift 5.9 or later
- macOS 10.15, iOS 13, tvOS 13, watchOS 6, or macCatalyst 13

## Structure

- `Sources/CodedError/` - Public API and macro declarations
- `Sources/CodedErrorMacros/` - Macro implementation
- `Tests/CodedErrorMacrosTests/` - Unit tests for the macro
