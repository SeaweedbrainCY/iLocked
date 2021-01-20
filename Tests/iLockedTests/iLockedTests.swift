import XCTest
@testable import iLocked

final class iLockedTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(iLocked().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
