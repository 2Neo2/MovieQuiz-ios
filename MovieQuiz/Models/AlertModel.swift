//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Иван Доронин on 29.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void
}
