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
}


extension QuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = movies[safe: index] else {
                return
            }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print(error)
            }
            
            let rating = Float(movie.rating) ?? 0
            let correctAnswer = rating > 6
            
            let question = QuizQuestionModel(image: imageData, correctAnswer: correctAnswer)
            
            self.movies.remove(at: index)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
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
