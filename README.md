# DataMapper

[![CI Status](http://img.shields.io/travis/Brightify/DataMapper.svg?style=flat)](https://travis-ci.org/Brightify/DataMapper)
[![Version](https://img.shields.io/cocoapods/v/DataMapper.svg?style=flat)](http://cocoapods.org/pods/DataMapper)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/DataMapper.svg?style=flat)](http://cocoapods.org/pods/DataMapper)
[![Platform](https://img.shields.io/cocoapods/p/DataMapper.svg?style=flat)](http://cocoapods.org/pods/DataMapper)
[![Slack Status](http://swiftkit.brightify.org//badge.svg)](http://swiftkit.brightify.org)

## Introduction

DataMapper is a framework for safe deserialization/serialization of objects from/to different data representation (JSON but it can be practically everything).

Among its advantages belongs:

* Easy to use API
* Compile time safety (as much as possible)
* Support for custom Serializers (allows you to simply change target data representation by implementing one class)
* Polymorph
* Thread safety (depends on your usage)
* Support for one direction use (if you don't need the other one, you don't have to implement it)

## Changelog

List of all changes and new features can be found [here](CHANGELOG.md).

## TODO

* XMLSerializer
* NSUserDefaultsSerializer
* Dynamic polymorph (once Swift allows it)

## Requirements

- **Swift 3**
- **iOS 8+**

## Installation

### CocoaPods

DataMapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your test target in your Podfile:

```Ruby
pod "DataMapper"
```

This will automatically include every subspec (Core and all Serializers).

If you want DataMapper without serializers (you have your own implementation), use:

```Ruby
pod "DataMapper/Core"
```

Each implementation of serializer has its own subspec. For example:

```Ruby
pod "DataMapper/JsonSerializer"
```

These subspecs have Core as dependency, so there is no need to specify it explicitly.

### Carthage

To use DataMapper with [Carthage](https://github.com/Carthage/Carthage) add in your Cartfile this line:
```
github "Brightify/DataMapper"
```

## Usage

Below is complete list of all features this library offers and how to use them. Some examples of usage can be found in [tests](Tests).

Used terminology:

* mapping - either deserialization or serialization
* Map protocol - `Deserializable`, `Serializable` or `Mappable`

### Quick overview

```Swift
	/*
		[{
			"number": 1,
			"text": "A"
		}, {
			"number": 2,
			"text": "B"
		}]
	*/
	let inputData: NSData = ... // Some data in JSON to be deserialized.

	let objectMapper = ObjectMapper()
	let serializer = JsonSerializer()

	// Deserialization
	let type = serializer.deserialize(inputData)
	let objects: [MyObject]? = objectMapper.deserialize(type)

	... // Do some stuff with objects.

	// Serialization
	let changedType = objectMapper.serialize(objects)
	let outputData = serializer.serialize(changedType)

	// Can be deserilized and serialized.
	struct MyObject: Mappable {

		var number: Int?
		var text: String?

		init(_ data: DeserializableData) throws {
			try mapping(data)
		}

		mutating func mapping(_ data: inout MappableData) throws {
			data["number"].map(&number)
			data["text"].map(&text)
		}
	}

	// Can be only deserialized.
	struct MyDeserializableObject: Deserializable {

		let number: Int?
		let text: String?

		init(_ data: DeserializableData) throws {
			number = data["number"].get()
			text = data["text"].get()
		}
	}

	// Can be only serialized.
	struct MySerializableObject: Serializable {

		let number: Int?
		let text: String?

		init(number: Int?, text: String?) {
			self.number = number
			self.text = text
		}

		func serialize(to data: inout SerializableData) {
			data["number"].set(number)
			data["text"].set(text)
		}
	}
```

### SupportedType

`SupportedType` creates intermediate level between ObjectMapper and Serializers. It is an enum representing basic data types (`null`, `string`, `number`, `array`, `dictionary`). Each type has associated property which return its value if it is correct type or nil otherwise. With small exception for `null` which property is named `isNull` and returns `Bool`. For example:

```Swift
let type: SupportedType = .string("A")
type.string // "A"
type.number // nil
```

#### SupportedNumber

SupportedNumber handles problem of numbers being ambiguous when represented as text. For example is 1 `Int` or `Double` or even `Bool`? (thanks `NSNumber` for that) It is a basic struct representing `Bool`, `Int` or `Double` or any combination of these. Usage:

```Swift
let int = SupportedNumber(int: 1)
int.bool // nil
int.int // 1
int.double // nil

let intOrDouble = SupportedNumber(int: 1, double: 1)
intOrDouble.bool // nil
intOrDouble.int // 1
intOrDouble.double // 1
```

Normally you will directly use it only if the number is ambiguous (in Serializers) in other cases use extensions for SupportedType to create and access it. For example:

```Swift
let int: SupportedType = .int(1)
int.bool // nil
int.int // 1
int.double // nil

let intOrDouble: SupportedType = .number(SupportedNumber(int: 1, double: 1))
intOrDouble.bool // nil
intOrDouble.int // 1
intOrDouble.double // 1
```

### ObjectMapper

Class which maps object to `SupportedType`. It has two types of methods: `serialize` which takes Swift objects and transforms them to `SupportedType` and `deserialize` which do it the other way.

Supported Swift types:

* `T?`
* `[T]?`
* `[String: T]?`
* `[T?]?`
* `[String: T?]?`

where `T` conforms to Map protocol (depends on method). If `T` does not conform to this protocol, you need to pass instance of `Transformation` as second parameter named `using`.

As you can see `deserialize` always returns optional type. `nil` is returned if `SupportedType` is `.null` or cannot be converted to `T`.

`serialize` accepts both optional and non optional types. If `nil` is passed then the result `SupportedType` is `.null`.

`[T]?` differs from `[T?]?` in deserialization in that if one of the elements from array is `nil` (`SupportedType` is `.null` or the object cannot be deserialized) then everything is discarded and `nil` is returned. In case of `[T?]?` `nil` value will be added to the array. The same applies to dictionary.

### Serializer

DataMapper specifies protocol named `Serializer` which maps `SupportedType` to `NSData`. You don't have to implement it in order to create custom one, but it is recommended because then it can be used in other libraries.

#### TypedSerializer

Extends `Serializer` with generic type and methods. Sometimes you may get data from another library not as `NSData` but for example as JSON (`Any` with specific structure) and transforming them back and forth is not good for performance.

#### Pre-implemented Serializers

**JsonSerializer**

As its name suggests it works with JSON. It conforms to `TypedSerializer` protocol and the `DataType` is `Any`. Requirements for the data format (`Any` or `NSData`) are the same as in `NSJSONSerialization`.

### Map protocol

#### Deserializable

Allows object conforming to this protocol to be deserialized from `SupportedType` using `ObjectMapper`. It is specified as:

```Swift
protocol Deserializable {

    init(_ data: DeserializableData) throws
}
```

In this `init` you need to initialize the object using `DeserializableData` (see DeserializableData chapter). If for some reason the object cannot be created (wrong data), then throw `DeserializationError`.

#### Serializable

Allows object conforming to this protocol to be serialized to `SupportedType` using `ObjectMapper`. It is specified as:

```Swift
protocol Serializable {

    func serialize(to data: inout SerializableData)
}
```

In `serialize` set data you want to serialize (it does not have to be everything) to `SerializableData` (see SerializableData chapter).

Warning: This method can easily break thread safety if serialized data are mutable (immutability and structs are your friend here).

#### Mappable

`Mappable` protocol combines both `Deserializable` and `Serializable`. It is specified as:

```Swift
protocol Mappable: Serializable, Deserializable {

    mutating func mapping(_ data: inout MappableData) throws
}
```

It provides default implementation for `serialize` but `init` needs to be implemented by hand, usually like this:

```Swift
struct SomeObject: Mappable {

	init(_ data: DeserializableData) throws {
		try mapping(data)
	}

	...
```

This also means that the object has to be initialized before calling the `mapping` method.

If you change the default implementation of `init` or `serialize` do not forget to call `try mapping(data)` (in `init`) or `mapping(&data)` (in `serialize`).

In `mapping` you have access to `MappableData` (see MappableData chapter) which allows you to specify how to map object at one place. For this the fields must be mutable. Immutable fields needs to be defined separately in `init` and `serialize` like so:

```Swift
struct SomeObject: Mappable {

	let constant: Int?
	var variable: Int?

	init(_ data: DeserializableData) throws {
		constant = data["constant"].get()

		try mapping(data)
	}

	func serialize(to data: inout SerializableData) {
		data["constant"].set(constant)

		mapping(&data)
	}

	mutating func mapping(_ data: inout MappableData) throws {
		data["variable"].map(&variable)
	}
}
```

Throws works the same as in `Deserializable`.

Warning: Same as for `Serializable`.

### DeserializableData/SerializableData/MappableData

They are used in corresponding methods in Map protocols. They provide many overloads of one specific method and a subscript. The subscript is used as key in a dictionary and it can be nested like so:

```Swift
data["a"]["b"]
data[["a", "b"]]
data["a", "b"]
```

These all means that data corresponds to dictionary with key "a" which is another dictionary with key "b".

The specific method has overloads for the same types as `ObjectMapper` with the same behavior (see ObjectMapper) and for each of them there are three choices:

* same as in `ObjectMapper` - works with optional type, nil represents .null
* `try` - works with non optional type and throws exception if .null is found
* `or` - works with non optional type and replaces .null with value from or.

#### DeserializableData

`DeserializableData` is used in `init` in `Deserializable`. The method is named `get` and it retrieves values from data. Usage:

```Swift
	let value: Int? = data["value"].get()
	let value: Int = try data["value"].get()
	let value: Int = data["value"].get(or: 0)

	let value: X? = data["value"].get(using: XTransformation())
	let value: X = try data["value"].get(using: XTransformation())
	let value: X = data["value"].get(using: XTransformation(), or: X())
```

#### SerializableData

`SerializableData` is used in `serialize` in `Serializable`. The method is named `set` and it sets values to data. Usage:

```Swift
	data["value"].set(value)

	data["value"].set(value, using: XTransformation())
```

Note: `set` does not have overloads for `try` and `or` (there is no need to because it accepts both optionals and non optionals).  

#### MappableData

`MappableData` is used in `mapping` in `Mappable`. The method is named `map` and it either behaves like `get` or `set` depending on the context. Usage:

```Swift
	data["value"].map(&value) // var value: Int?
	try data["value"].map(&value) // var value: Int
	data["value"].map(&value, or: 0) // var value: Int

	data["value"].map(&value, using: XTransformation()) // var value: X?
	try data["value"].map(&value, using: XTransformation()) // var value: X
	data["value"].map(&value, using: XTransformation(), or: X()) // var value: X
```

Note: `try` and `or` affects result of `map` only in deserialization.

### Transformations

Transformations provide another way of specifying how object should be mapped. They are used to either override behavior of methods in Map protocol or to allow mapping of type which does not conform to Map protocol.

There are three types of them: `DeserializableTransformation` (only for deserialization), `SerializableTransformation` (only for serialization) and `Transformation` (both). Also all of the specialized implementations (`AnyTransformation`, `SupportedTypeConvertible`, ...) have three versions with corresponding name.

Best way to learn how to create a new one is to look at [existing code](Source/Core/Transformation/Transformations).

#### Pre-implemented Transformations

* `EnumTransformation` - uses `RawRepresentable`
* `URLTransformation` - `String` to `NSURL` (using of relative or absolute path can be specified in `init`)

**Date types**

* `CustomDateFormatTransformation` - `init` with formatString used as `NSDateFormatter.dateFormat`
* `DateFormatterTransformation` - `init` with `NSDateFormatter`
* `DateTransformation` - `Double` as timeIntervalSince1970
* `ISO8601DateTransformation` - `String` in ISO8601 format

**Value types**

* `BoolTransformation`
* `DoubleTransformation`
* `IntTranformation`
* `StringTransformation`

#### AnyTransformation

`AnyTransformation` represents Swift pattern for using protocols with associated types as variable types. To convert any instance of `Transformation` to it, simply call `transformation.typeErased()`. This is often needed in specialized implementations of `Transformation` mentioned below.

Note: `AnyTransformation` has variants for only deserialization or serialization, which also have method `typeErased()`. So sometimes it may be necessary to specify output type of this method explicitly. For example:

```Swift
let transformation = IntTransformation()

let anyTransformation: AnyTransformation = transformation.typeErased()
let anyDeserializableTransformation: AnyDeserializableTransformation = transformation.typeErased()
let anySerializableTransformation: AnySerializableTransformation = transformation.typeErased()
```

#### SupportedTypeConvertible

Extending type with `SupportedTypeConvertible` provides default implementation of Map protocol if there already is `Transformation` for that type. All value types with transformations and `NSURL` conforms to this protocol.

Here is example implementation for `Int`:

```Swift
extension Int: SupportedTypeConvertible {

    static var defaultTransformation = IntTransformation().typeErased()
}
```

Note: This allows types like `Int` to be used directly in `ObjectMapper` without need to pass the transformation.

#### CompositeTransformation

`CompositeTransformation` allows you to reuse already existing `Transformation` to transform value of type `TransitiveObject` to/from `SupportedType`. Then you only need to write code for converting that `TransitiveObject` to/from `Object`.

#### DelegatedTransformation

`DelegatedTransformation` is similar to `CompositeTransformation` in that it uses another `Transformation`, but there is no other conversion after that. Typically this is used to specialize more generic `Transformation`. For example this is implementation of `ISO8601DateTransformation`:

```Swift
struct ISO8601DateTransformation: DelegatedTransformation {

    typealias Object = Date

    let transformationDelegate = CustomDateFormatTransformation(formatString: "yyyy-MM-dd'T'HH:mm:ssZZZZZ").typeErased()
}
```

Because there is already `CustomDateFormatTransformation` which handles transformation to/from `.string`, it is not necessary to implement that again here. It is sufficient to specify the format used.

### Polymorph

`Polymorph` represents object that can decide (at runtime) to which object should be the data deserialized and what metadata should be kept about the object concrete type when being serialized to `SupportedType`.

To use `Polymorph` initialize `ObjectMapper` with it. For example: 

```Swift
let objectMapper = ObjectMapper(polymorph: StaticPolymorph())
```

The protocol is defined like this:

```Swift
protocol Polymorph {

    /// Returns type to which should be the supportedType deserialized.
    func polymorphType<T>(for type: T.Type, in supportedType: SupportedType) -> T.Type

    /// Write info about type to supportedType if necessary.
    func writeTypeInfo<T>(to supportedType: inout SupportedType, of type: T.Type)
}
```

There is at the moment only one implementation (`StaticPolymorph`) but once Swift adds reflexion we will implement new one (dynamic). Also feel free to implement your own polymorphism if ours is not universal enough for you. In extreme cases you may even want to "hardcode" which types should be used.

Example of what can polymorph do: 

```Swift
class A: Mappable {

	let value: Int?
	...
}

class B: A {

	let text: String?
	...
}

struct MyPolymorph: Polymorph {
    
    // If B is castable to T and supportedType contains dictionary with key "type" and value "B", then the type to use is B, otherwise does nothing.
    func polymorphType<T>(for type: T.Type, in supportedType: SupportedType) -> T.Type {
        if let bType = B.self as? T.Type, supportedType.dictionary?["type"]?.string == "B" {
            return bType
        }
        return type
    }
    
    // If T is B, write info about it into supportedType.
    func writeTypeInfo<T>(to supportedType: inout SupportedType, of type: T.Type) {
        if type == B.self {
            supportedType.addToDictionary(key: "type", value: .string("B"))
        }
    }
}

let objectMapper = ObjectMapper()
let objectMapperWithPolymorh = ObjectMapper(polymorph: MyPolymorph())

let aType: SupportedType = .dictionary(["value": .int(1)])
let bType: SupportedType = .dictionary(["value": .int(2), "text": .string("text"), "type": .string("B")])

// Deserialization
let aObject: A? = objectMapper.deserialize(aType) // A(value: 1) - no surprise here
let bObject: A? = objectMapper.deserialize(bType) // A(value: 2) - rest of the dictionary is ignored

let aPolymorphic: A? = objectMapperWithPolymorh.deserialize(aType) // A(value: 1) - again the same result
let bPolymorphic: A? = objectMapperWithPolymorh.deserialize(bType) // B(value: 2, text: "text") - this time the polymorph comes into play

// Serialization
objectMapper.serialize(aObject) // .dictionary(["value": .int(1)])
objectMapper.serialize(bObject) // .dictionary(["value": .int(2)])
objectMapperWithPolymorh.serialize(aPolymorphic) // .dictionary(["value": .int(1)]) - so far no difference

objectMapper.serialize(bPolymorphic) // .dictionary(["value": .int(2), "text": .string("text")])
objectMapperWithPolymorh.serialize(bPolymorphic) // .dictionary(["value": .int(2), "text": .string("text"), "type": .string("B")]) - type is added
```

#### StaticPolymorp

`StaticPolymorph` resolve types by looking into `SupportedType` for dictionary entries with specific key (which key is used is determined by object type at input). Then the value for that key is compared to names of known types. If match is found than correct type is return otherwise it returns the input type. When serializing the `StaticPolymorh` adds into `SupportedType` the key value pair that corresponds to the serialized type.

`StaticPolymorp` affects only objects which implement `Polymorphic` protocol. For other types `polymorphType` returns the input type and `writeTypeInfo` does nothing.

Note: Implementing `Polymoprhic` is not enough for object to be used in `ObjectMapper`. To solve this there are type aliases that combines `Polymorhic` with Map protocol: `PolymorphicDeserializable`, `PolymorphicSerializable` and `PolymorphicMappable`.

Note: Limitation of `StaticPolymorph` is necessity to use classes. It is not possible to use protocol and structs.

**Polymorphic**

`Polymorphic` is defined like this:

```Swift
protocol Polymorphic: AnyObject {

    static var polymorphicKey: String { get }

    static var polymorphicInfo: PolymorphicInfo { get }
}
```

`polymorphicKey` represents the key mentioned above. (Where to look for a name of the type.) `polymorphicKey` can be overriden. That allows each type to be identified with key and name combination. It is not defined what happens if more than one key is present in `SupportedType` with valid names! There can be multiple subtypes with the same key or name as long as the combination is unique.

`polymorphicInfo` defines type name and its subtypes (they don't have to be direct subtypes). It cannot be checked if these types are really subtypes but this won't be a problem if you use `GenericPolymorphicInfo` which does that check. If registered subtype is not a real subtype then `StaticPolymorph` will ignore it (but don't rely on this behavior). When `StaticPolymorp` resolves subtypes it relies only on information provided by `polymorphicInfo`, so subtypes which are not registered in input type (or in registered subtype) don't exist for it. To prevent potential misuse it is prohibited to use `Polymorphic` as input type if it does not override `polymorphicInfo` (as seen in example below).

`Polymorphic` provides method `createPolymorphicInfo()` which returns `GenericPolymorphicInfo`. This method has optional parameter `name` which represents the polymorphic name of the type (default value is real name of the type). `GenericPolymorphicInfo` allows you to register subtypes with overloads of `register()` and `with()` (`with()` returns `self` to allow chaining).

**Example**

```Swift
class A: Polymorphic {

    class var polymorphicKey: String {
        return "K"
    }

    class var polymorphicInfo: PolymorphicInfo {
        return createPolymorphicInfo(name: "Base").with(subtypes: B.self, D.self)
    }
}

class B: A {

    override class var polymorphicInfo: PolymorphicInfo {
        return createPolymorphicInfo().with(subtype: C.self)
    }
}

class C: B {

	override class var polymorphicKey: String {
        return "C"
    }
}

class D: C {

    override class var polymorphicInfo: PolymorphicInfo {
        return createPolymorphicInfo()
    }
}
```

Note: This example omits implementation of Map protocol.

There are few things to notice.

1. `C` overrides `polymorphicKey` that means: `A` and `B` have key "K" and `C` and `D` have key "C". So `SupportedType.dictionary(["C": .string("C")]` represents `C` but `SupportedType.dictionary(["K": .string("C")]` means nothing in this context.
1. `A` has explicit name "Base". So `SupportedType.dictionary(["K": .string("Base")]` represents `A`.
1. `C` does not override `polymorphicInfo`. This means that `C` cannot be used as the input type (exception will be raised) but `D` can be, even though it won't ever resolve to another type.
1. `D` is registered in `A` not `B`. Because of that `B` does not know about `D`. So if `B` is the input type you can never get `D` as subtype.
1. `A` knows about `C` because it is register in `B` which is registered in `A`.

### Thread safety

DataMapper is designed to be used on background thread (default implementation is thread safe). If you want to use it that way you need to make sure that implementations of all methods from Map protocols are thread safe as well (or that the objects you are using cannot be used at two threads simultaneously). Your custom implementations of protocols like `Serializer`, `Polymorph`, `Transformation` etc. must be thread safe too.

## Versioning

This library uses semantic versioning. Until version 1.0 API breaking changes may occur even in minor versions. We consider version 0.1 to be prerelease, which means that API should be stable but is not tested yet in real project. After that testing we make needed adjustments and bump the version to 1.0 (first release).

## Author

* Tadeas Kriz, [tadeas@brightify.org](mailto:tadeas@brightify.org)
* Filip Dolník, [filip@brightify.org](mailto:filip@brightify.org)

## Used libraries in tests

* [Quick](https://github.com/Quick/Quick)
* [Nimble](https://github.com/Quick/Nimble)

## License

DataMapper is available under the [MIT License](LICENSE).
