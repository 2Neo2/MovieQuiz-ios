//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Иван Доронин on 18.09.2023.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testIndexInRange() {
        let numbers = [1, 2, 3, 4, 5]
        
        let number = numbers[safe: 3]
        
        XCTAssertNotNil(number)
        XCTAssertEqual(number, 4)
    }
    
    func testIndexOutOfRange() {
        let numbers = [1, 2, 3, 4, 5]
        
        let number = numbers[safe: 5]
        
        XCTAssertNil(number)
        XCTAssertEqual(number, nil)
    }
}
