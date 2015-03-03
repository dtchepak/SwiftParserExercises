// Parser exercises, based on those written by Tony Morris et al., published under NICTA repo
// https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/src/Course/Parser.hs

import UIKit
import XCTest


public typealias Input = String

public enum ParseError : Printable, Equatable {
    case UnexpectedEof
    case ExpectedEof(Input)
    case UnexpectedChar(Character)
    case Failed(String)
    public var description : String {
        switch self {
        case .UnexpectedChar(let c): return "Unexpected character: \(c)"
        case .UnexpectedEof : return "Unexpected end of stream"
        case .ExpectedEof(let c): return "Expected end of stream, but got >\(c)<"
        case .Failed(let s): return s
        }
    }
}

public func ==(lhs: ParseError, rhs: ParseError) -> Bool {
    let p = (lhs, rhs)
    switch p {
    case (.UnexpectedEof, .UnexpectedEof): return true
    case (.ExpectedEof(let i1), .ExpectedEof(let i2)): return i1 == i2
    case (.UnexpectedChar(let c1), .UnexpectedChar(let c2)): return c1 == c2
    case (.Failed(let s1), .Failed(let s2)): return s1 == s2
    default: return false
    }
}

public enum ParseResult<A> : Printable {
    case ErrorResult(ParseError)
    case Result(Input,Box<A>)
    public var description : String {
        switch self {
        case .ErrorResult(let p) : return p.description
        case .Result(let i, let a): return "Result >\(i)<, \(a.value)"
        }
    }
    public func isError() -> Bool {
        switch self {
        case ErrorResult(_) : return true
        case Result(_): return false
        }
    }
}

public func ==<A: Equatable>(lhs: ParseResult<A>, rhs: ParseResult<A>) -> Bool {
    switch (lhs, rhs) {
    case (.ErrorResult(let e1), .ErrorResult(let e2)): return e1 == e2
    case (.Result(let i1, let a1), .Result(let i2, let a2)): return i1 == i2 && a1.value == a2.value
    default: return false
    }
}

// Convenience functions for creating ParseResult<A> values.
public func succeed<A>(remainingInput : Input, value : A) -> ParseResult<A> { return .Result(remainingInput, Box(value)) }
public func failWithUnexpectedEof<A>() -> ParseResult<A> { return .ErrorResult(.UnexpectedEof) }
public func failWithExpectedEof<A>(i : Input) -> ParseResult<A> { return .ErrorResult(.ExpectedEof(i)) }
public func failWithUnexpectedChar<A>(c : Character) -> ParseResult<A> { return .ErrorResult(.UnexpectedChar(c)) }
public func failParse<A>() -> ParseResult<A>{ return .ErrorResult(.Failed("Parse failed")) }
public func failWithParseError<A>(e : ParseError) -> ParseResult<A> { return .ErrorResult(e) }


// A Parser<A> wraps a function that takes some input and returns either:
// * a value of type A, and the remaining input left to parse
// * a parse error
public struct Parser<A> {
    let p : Input -> ParseResult<A>
    init(p : Input -> ParseResult<A>) { self.p = p }
    
    public func parse(i : Input) -> ParseResult<A> { return self.p(i) }
}
public func TODO<A>() -> Parser<A> { return Parser({ i in .ErrorResult(.Failed("*** TODO ***"))}) }

// Produces a parser that always fails with UnexpectedChar given the specified character
public func unexpectedCharParser<A>(c : Character) -> Parser<A> {
    return Parser({ i in failWithUnexpectedChar(c) })
}

// Return a parser that always succeeds with the given value and consumes no input
public func valueParser<A>(a : A) -> Parser<A> {
    //return TODO()
    return Parser({ s in succeed(s, a) })
}

class ValueParserTests : XCTestCase {
    func testValueParser() {
        let result = valueParser(2).parse("hello")
        assertEqual(result, succeed("hello", 2))
    }
}

// Return a parser that always fails with ParseError.failed.
public func failed<A>() -> Parser<A> {
    //return TODO()
    return Parser({ _ in failParse() })
}

class FailedParserTests : XCTestCase {
    func testFailedParser() {
        let result : ParseResult<Int> = failed().parse("abc")
        assertEqual(result, failParse())
    }
}


// Return a parser that succeeds with a character off the input or fails with an error if the input is empty.
// String manipulation examples: 
//      http://sketchytech.blogspot.com.au/2014/08/swift-pure-swift-method-for-returning.html
public func character() -> Parser<Character> {
    //return TODO()
    return Parser({ s in
        if let c = first(s) {
            let rest = dropFirst(s)
            return succeed(rest, c)
        } else {
            return failWithUnexpectedEof()
        }
    })
}

class CharacterParserTests : XCTestCase {
    func testCharacter() {
        let result = character().parse("abcd")
        assertEqual(result, succeed("bcd", "a"))
    }
    func testCharacterWithEmptyInput() {
        let result = character().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

extension Parser {
    // Return a parser that maps any succeeding result with the given function.
    // Hint: will require the construction of a `Parser<B>` and pattern matching on the result of `self.parse`.
    public func map<B>(f : A -> B) -> Parser<B> {
        //return TODO()
        return Parser<B>({ s in
            switch self.parse(s) {
            case .ErrorResult(let e): return failWithParseError(e)
            case .Result(let i, let v): return succeed(i, f(v.value))
            }
        })
    }
}

class MapParserTests : XCTestCase {
    func testMap() {
        let result = character().map(toUpper).parse("abc")
        assertEqual(result, succeed("bc", "A"))
    }
    func testMapAgain() {
        let result = valueParser(10).map({ $0+1 }).parse("abc")
        assertEqual(result, succeed("abc", 11))
    }
    func testMapWithErrorResult() {
        let result = failed().map({ $0 + 1 }).parse("abc")
        assertEqual(result, failParse())
    }
}

extension Parser {
    // Return a parser based on this parser (`self`). The new parser should run its input through
    // this parser, then:
    //
    //   * if this parser succeeds with a value (type A), put that value into the given function
    //     then put the remaining input into the resulting parser.
    //
    //   * if this parser fails with an error the returned parser fails with that error.
    //
    public func flatMap<B>(f : A -> Parser<B>) -> Parser<B> {
        //return TODO()
        return Parser<B>({ s in
            switch self.parse(s) {
            case .ErrorResult(let e): return failWithParseError(e)
            case .Result(let i, let v): return f(v.value).parse(i)
            }
        })
    }
}

public class FlatMapParserTests : XCTestCase {
    let skipOneX : Parser<Character> =
                character().flatMap({ c in
                    if c == "x" { return character() } // if c=="x", skip this character and parse the next one
                    else { return valueParser(c) }     // else return this character
                })
    func testFlatMap() {
        let result = skipOneX.parse("abcd")
        assertEqual(result, succeed("bcd", "a"))
    }
    func testFlatMapAgain() {
        let result = skipOneX.parse("xabc")
        assertEqual(result, succeed("bc", "a"))
    }
    func testFlatMapWithNoInput() {
        let result = skipOneX.parse("")
        assertEqual(result, failWithUnexpectedEof());
    }
    func testFlatMapRunningOutOfInput() {
        let result = skipOneX.parse("x")
        assertEqual(result, failWithUnexpectedEof());
    }
}

// Return a parser that puts its input into the first parser, then:
//
//   * if that parser succeeds with a value (a), ignore that value
//     but put the remaining input into the second given parser.
//
//   * if that parser fails with an error the returned parser fails with that error.
//
// Hint: Use Parser.flatMap
public func >>><A,B>(first : Parser<A>, second : Parser<B>) -> Parser<B> {
    //return TODO()
    return first.flatMap({ _ in second })
}

public class SkipParserTests : XCTestCase {
    func testSkipParser() {
        let result = (character() >>> valueParser("x")).parse("abc")
        assertEqual(result, succeed("bc", "x"))
    }
    func testSkipParserWhenFirstParserFails() {
        let result = (character() >>> valueParser("x")).parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that tries the first parser for a successful value.
//
//   * If the first parser succeeds then use this parser.
//
//   * If the first parser fails, try the second parser.
public func |||<A>(first: Parser<A>, second:Parser<A>) -> Parser<A> {
    //return TODO()
    return Parser({ s in
        switch first.parse(s) {
        case .ErrorResult(_): return second.parse(s)
        case .Result(let i, let v): return .Result(i, v)
        }
    })
}

public class OrParserTests : XCTestCase {
    func testOrWhenFirstSucceeds() {
        let result = (character() ||| valueParser("v")).parse("abc")
        assertEqual(result, succeed("bc", "a"))
    }
    func testOrWhenFirstFails() {
        let result = (failed() ||| valueParser("v")).parse("")
        assertEqual(result, succeed("", "v"))
    }
    func testOrWhenFirstFailsDueToLackOfInput() {
        let result = (character() ||| valueParser("v")).parse("")
        assertEqual(result, succeed("", "v"))
    }
}


// Return a parser that continues producing a list of values from the given parser.
// If there are no values that can be parsed from `p`, the returned parser should produce an empty list.
//
// Hint: - Use valueParser, |||, and atLeast1 parser (defined below).
//       - list and atLeast1 are mutually recursive calls!
public func list<A>(p : Parser<A>) -> Parser<[A]> {
    //return TODO()
    return atLeast1(p) ||| valueParser([])
    
}
// Return a parser that produces at least one value from the given parser then
// continues producing a list of values from the given parser (to ultimately produce a non-empty list).
// The returned parser fails if the input is empty.
//
// Hint: - Use flatMap, valueParser, and list (defined above)
//       - list and atLeast1 are mutually recursive calls!
public func atLeast1<A>(p : Parser<A>) -> Parser<[A]> {
    //return TODO()
    return p.flatMap({ a in
        list(p).flatMap( { aa in
            valueParser([a] + aa) } )
    })
}

// list and atLeast1 should both be completed before these tests should pass
class ListParserTests : XCTestCase {
    func testList() {
        let result = list(character()).parse("abc")
        assertEqual(result, succeed("", ["a", "b", "c"]))
    }
    func testListWithNoInput() {
        let result = list(character()).parse("")
        assertEqual(result, succeed("", []))
    }
    func testAtLeastOne() {
        let result = atLeast1(character()).parse("abc")
        assertEqual(result, succeed("", ["a", "b", "c"]))
    }
    func testAtLeast1WithNoInput() {
        let result = atLeast1(character()).parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that produces a character but fails if
//
//   * The input is empty.
//   * The character does not satisfy the given predicate.
//
// Hint: The flatMap, valueParser, unexpectedCharParser and character functions will be helpful here.
public func satisfy(p : Character -> Bool) -> Parser<Character> {
    //return TODO()
    return character().flatMap({ c in
        if p(c) {
            return valueParser(c)
        } else {
            return unexpectedCharParser(c)
        }
    })
}
class SatisfyParserTests : XCTestCase {
    func testParseUpper() {
        let result = satisfy(isUpperCase).parse("Abc")
        assertEqual(result, succeed("bc", "A"))
    }
    func testParseUpperWithLowercaseInput() {
        let result = satisfy(isUpperCase).parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Return a parser that produces the given character but fails if
//
//   * The input is empty.
//   * The produced character is not equal to the given character.
//
// Hint: Use the satisfy function.
public func charIs(c : Character) -> Parser<Character> {
    //return TODO()
    return satisfy({ cc in c == cc })
}

class CharIsParserTests : XCTestCase {
    func testCharIs() {
        let result = charIs("x").parse("xyz")
        assertEqual(result, succeed("yz", "x"))
    }
    func testCharIsWhenItIsnt() {
        let result = charIs("x").parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Return a parser that produces a character between "0" and "9" but fails if
//
//   * The input is empty.
//   * The produced character is not a digit.
//
// Hint: - Use the satisfy and isDigit functions.
//       - This returns a Parser<Character>, not a Parser<Int>
public func digit() -> Parser<Character> {
    //return TODO()
    return satisfy(isDigit)
}

class DigitParserTests : XCTestCase {
    func testDigit() {
        let result = digit().parse("123")
        assertEqual(result, succeed("23", "1"))
    }
    func testDigitWhenItIsnt() {
        let result = digit().parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}
// END EXERCISES


// Assertion helpers
func assertEqual<T : Equatable>(actual : ParseResult<T>, expected : ParseResult<T>, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected.description), Actual: \(actual.description)", file: file, line: line)
}
func assertEqual<T : Equatable>(actual : ParseResult<[T]>, expected : ParseResult<[T]>, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected.description), Actual: \(actual.description)", file: file, line: line)
}

public func ==<A: Equatable>(lhs: ParseResult<[A]>, rhs: ParseResult<[A]>) -> Bool {
    switch (lhs, rhs) {
    case (.ErrorResult(let e1), .ErrorResult(let e2)): return e1 == e2
    case (.Result(let i1, let a1), .Result(let i2, let a2)): return i1 == i2 && a1.value == a2.value
    default: return false
    }
}
// Character functions
func toUpper(c : Character) -> Character {
    return first(String(c).uppercaseString) ?? c
}
func isUpperCase(c : Character) -> Bool {
    let cset = NSCharacterSet.uppercaseLetterCharacterSet()
    let s = String(c).utf16
    // If unicode char has an uppercase component, let's say it is uppercase
    for codeUnit in s {
        if cset.characterIsMember(codeUnit) {
            return true
        }
    }
    return false
}
func isDigit(c : Character) -> Bool {
    return ("0"..."9") ~= c
}

// Operators
infix operator <^> {    // map
associativity left
precedence 138
}
infix operator <*> {    // apply
associativity left
precedence 138
}
infix operator >>- {    // flatMap
associativity left
precedence 90
}
infix operator >>> {    // skip
associativity left
precedence 90
}
infix operator ||| {    // or
associativity left
precedence 100
}

public func <^><A,B>(f : A->B, p: Parser<A>) -> Parser<B> {
    return p.map(f)
}
public func >>-<A,B>(p : Parser<A>, f : A -> Parser<B>) -> Parser<B> {
    return p.flatMap(f)
}


// From: https://github.com/typelift/Swiftx/blob/e0997a4b43fab5fb0f3d76506f7c2124b718920e/Swiftx/Box.swift
/// An immutable reference type holding a singular value.
///
/// Boxes are often used when the Swift compiler cannot infer the size of a struct or enum because
/// one of its generic types is being used as a member.
public final class Box<T> {
    private let val : @autoclosure () -> T
    public var value: T { return val() }
    public init(_ value : T) {
        self.val = value
    }
}