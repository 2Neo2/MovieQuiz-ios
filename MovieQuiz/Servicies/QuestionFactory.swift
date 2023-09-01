//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Иван Доронин on 28.08.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
}

final class QuestionFactory {
    weak var delegate: QuestionFactoryDelegate?
    
    init(delegate: QuestionFactoryDelegate? = nil) {
        self.delegate = delegate
    }
    
    // MARK: Set array of question with mock-data.
    private let questions: [QuizQuestionModel] = [
        QuizQuestionModel(image: "The Godfather", correctAnswer: true),
        QuizQuestionModel(image: "The Dark Knight", correctAnswer: true),
        QuizQuestionModel(image: "Kill Bill", correctAnswer: true),
        QuizQuestionModel(image: "The Avengers", correctAnswer: true),
        QuizQuestionModel(image: "Deadpool", correctAnswer: true),
        QuizQuestionModel(image: "The Green Knight", correctAnswer: true),
        QuizQuestionModel(image: "Old", correctAnswer: false),
        QuizQuestionModel(image: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestionModel(image: "Tesla", correctAnswer: false),
        QuizQuestionModel(image: "Vivarium", correctAnswer: false)
    ]
}


extension QuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
        guard let question = questions.randomElement() else {
            return
        }
        delegate?.didReceiveNextQuestion(question: question)
    }
}
