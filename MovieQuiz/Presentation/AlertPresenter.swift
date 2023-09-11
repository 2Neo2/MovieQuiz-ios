//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Иван Доронин on 29.08.2023.
//

import UIKit

protocol AlertPresenter {
    func showAlertResult(alertModel: AlertModel)
}

class AlertPresenterImplementation {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

extension AlertPresenterImplementation: AlertPresenter {
    func showAlertResult(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in
            alertModel.completion()
        }
        
        alert.addAction(alertAction)
        viewController?.present(alert, animated: true)
    }
}
