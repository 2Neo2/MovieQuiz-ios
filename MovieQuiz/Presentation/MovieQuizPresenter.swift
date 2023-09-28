//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Иван Доронин on 24.09.2023.
//

import UIKit

final class MoviewQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
    var currentQuestion: QuizQuestionModel?
    private weak var viewController: MovieQuizViewControllerProtocol?
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StaticsticService!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementatioin()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convertQuestionToStepViewModel(to quizQuestionModel: QuizQuestionModel) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: quizQuestionModel.image) ?? UIImage(),
            question: quizQuestionModel.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question = question else {
            assertionFailure("Error")
            return
        }
        
        currentQuestion = question
        let viewModel = convertQuestionToStepViewModel(to: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(answer: true)
    }
    
    func noButtonClicked() {
        didAnswer(answer: false)
    }
    
    private func didAnswer(answer: Bool) {
        guard let currentQuestion = self.currentQuestion else {
            assertionFailure("Error")
            return
        }
        
        self.proceedWithAnswer(answer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrect: Bool) {
        correctAnswers += isCorrect ? 1 : 0
    }
    
    func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        guard let service = statisticService, let bestGame = statisticService?.bestGame else {
            assertionFailure("Error")
            return ""
        }
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(String(describing: service.gamesCount))"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", service.totalAccuracy))%"
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    func proceedWithAnswer(_ isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let info = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultViewModel(
                title: "Этот раунд окончен!",
                currentAnswersLabel: info,
                buttonText: "Сыграть еще раз")
            self.restartGame()
            self.viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
