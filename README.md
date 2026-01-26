# AutoDefaultsSetting

A Swift macro that automatically generates type-safe UserDefaults setting wrappers for use with the [Defaults](https://github.com/sindresorhus/Defaults) package.

## Overview

`AutoDefaultsSetting` is a freestanding declaration macro designed to work seamlessly with the [Defaults](https://github.com/sindresorhus/Defaults) package. It generates boilerplate code for creating `DefaultsSetting` conforming structures, reducing repetitive code when defining your app's user defaults keys. Instead of manually creating setting structures, the macro generates them for you based on a key, type, and default value.

> **Note:** This macro is designed to be used in conjunction with the [Defaults](https://github.com/sindresorhus/Defaults) package. Make sure you have it installed in your project.

## Installation

### Prerequisites

This macro requires the [Defaults](https://github.com/sindresorhus/Defaults) package. Add both packages to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/sindresorhus/Defaults.git", from: "8.0.0"),
    .package(url: "https://github.com/YOUR_USERNAME/swift-macro-autodefaultssetting.git", from: "1.0.0")
]
```

Then add them to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Defaults", package: "Defaults"),
        .product(name: "AutoDefaultsSetting", package: "swift-macro-autodefaultssetting")
    ]
)
```

### Required Protocol Definition

You must include the following `DefaultsSetting` protocol definition **once** in your project. This protocol provides the foundation for the generated setting structures:

```swift
public import Defaults

public protocol DefaultsSetting {
  associatedtype Value: Defaults.Serializable

  var key: Defaults.Key<Value> { get }
}

extension DefaultsSetting {
  public var value: Value {
    Defaults[key]
  }

  public func set(_ value: Value) {
    Defaults[key] = value
  }

  public func updates(
    initial: Bool = true
  ) -> AsyncStream<Value> {
    Defaults.updates(
      key,
      initial: initial
    )
  }
}
```

## Usage

### Basic Example

```swift
import AutoDefaultsSetting
import Defaults

// Generate a settings wrapper for a String value
#AutoDefaultsSetting(key: "username", type: String.self, default: "Guest")

// This generates:
// public struct UsernameSetting: DefaultsSetting {
//     public static var shared = Self()
//     public let key = Key<String>("username", default: "Guest")
// }
```

### Using the Generated Setting with Defaults

The generated settings come with convenient methods from the `DefaultsSetting` protocol:

```swift
import Defaults

// Access the generated setting
let setting = UsernameSetting.shared

// Read using the value property
let username = setting.value

// Write using the set method
setting.set("John")

// Or use Defaults directly with the key
Defaults[setting.key] = "Jane"

// Observe changes using Swift concurrency
Task {
    for await newValue in setting.updates() {
        print("Username changed to: \(newValue)")
    }
}

// Or use Combine publisher
Defaults.publisher(setting.key)
    .sink { newValue in
        print("Username changed to: \(newValue)")
    }
    .store(in: &cancellables)
```

### Examples with Different Types

```swift
// Boolean setting
#AutoDefaultsSetting(key: "isDarkMode", type: Bool.self, default: false)

// Integer setting
#AutoDefaultsSetting(key: "launchCount", type: Int.self, default: 0)

// Double setting
#AutoDefaultsSetting(key: "volume", type: Double.self, default: 0.5)

// Enum setting (enums must conform to Defaults.Serializable)
enum SortOrder: String, Defaults.Serializable {
    case ascending
    case descending
}
#AutoDefaultsSetting(key: "sortOrder", type: SortOrder.self, default: .ascending)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
