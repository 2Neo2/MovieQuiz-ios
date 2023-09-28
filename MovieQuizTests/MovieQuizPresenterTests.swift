//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Иван Доронин on 28.09.2023.
//

import XCTest

@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultViewModel) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func highlightImageBorder(_ isCorrect: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        
        let sut = MoviewQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        
        let question = QuizQuestionModel(image: emptyData, correctAnswer: true)
        
        let viewModel = sut.convertQuestionToStepViewModel(to: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Рейтинг этого фильма больше чем 6?")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
