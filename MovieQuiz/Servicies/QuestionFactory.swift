//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Иван Доронин on 28.08.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

final class QuestionFactory {
    private let moviesLoader: MoviesLoader
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var questions: [QuizQuestionModel] = []
    
    init(moviesLoader: MoviesLoader, delegate: QuestionFactoryDelegate? = nil) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    private func setQuestions() {
        questions = [
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
}


extension QuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
        if questions.isEmpty {
            setQuestions()
        }
        
        guard let index = (0..<questions.count).randomElement() else {
            return
        }
        let question = questions[safe: index]
        questions.remove(at: index)
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
