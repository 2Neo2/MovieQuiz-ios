import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func highlightImageBorder(_ isCorrect: Bool)
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    private var noButton = UIButton()
    private var yesButton = UIButton()
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MoviewQuizPresenter!
    private var notificationGenerator = UINotificationFeedbackGenerator()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true
        return activity
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = Constants.Fonts.ysDisplayFont(named: "Bold", size: 23.0)
        label.textColor = Constants.Colors.white
        return label
    }()
    
    private let quizFilmImage: UIImageView = {
        let image = UIImageView()
        image.accessibilityIdentifier = "Poster"
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.backgroundColor = Constants.Colors.white
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 20
        return image
    }()
    
    private let questionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Вопрос:"
        label.font = Constants.Fonts.ysDisplayFont(named: "Medium", size: 20.0)
        label.textColor = Constants.Colors.white
        return label
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "Index"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0/10"
        label.setContentHuggingPriority(.init(rawValue: 252), for: .horizontal)
        label.font = Constants.Fonts.ysDisplayFont(named: "Medium", size: 20.0)
        label.textColor = Constants.Colors.white
        return label
    }()
    
    // MARK: Setup horizontal stack which containts two buttons (yes, no).
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.axis = .horizontal
        return stackView
    }()
    
    // MARK: Setup horizontal stack which containts question title and index title.
    private let questionTitlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: Setup vertical stack view which containts all views on the screen.
    private let generalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    // MARK: Setup view which containts question label for create special constraints for presenting on the screen.
    private let viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layoutConstraints()
        print(NSHomeDirectory())
        presenter = MoviewQuizPresenter(viewController: self)
        
        alertPresenter = AlertPresenterImplementation(viewController: self)
        showLoadingIndicator()
    }
    
    private func setupView() {
        // MARK: Setup background.
        view.backgroundColor = Constants.Colors.black
        
        // MARK: Setup buttons.
        setupButtons(with: noButton, "Нет")
        setupButtons(with: yesButton, "Да")
        
        // MARK: Adding subviews into container and stack views.
        viewContainer.addSubview(questionLabel)
        
        buttonsStackView.addArrangedSubview(noButton)
        buttonsStackView.addArrangedSubview(yesButton)
        
        questionTitlesStackView.addArrangedSubview(questionTitleLabel)
        questionTitlesStackView.addArrangedSubview(indexLabel)
        
        generalStackView.addArrangedSubview(questionTitlesStackView)
        generalStackView.addArrangedSubview(quizFilmImage)
        generalStackView.addArrangedSubview(viewContainer)
        generalStackView.addArrangedSubview(activityIndicator)
        generalStackView.addArrangedSubview(buttonsStackView)
        
        view.addSubview(generalStackView)
    }
    
    // MARK: Private func which setup two same buttons.
    private func setupButtons(with button: UIButton, _ title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.Colors.white
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Constants.Fonts.ysDisplayFont(named: "Medium", size: 20.0)
        button.setTitleColor(Constants.Colors.black, for: .normal)
        button.layer.cornerRadius = 15
        
        if (title == "Да") {
            button.accessibilityIdentifier = "Yes"
            button.addTarget(self, action: #selector(yesButtonTapHandler), for: .touchUpInside)
        } else {
            button.accessibilityIdentifier = "No"
            button.addTarget(self, action: #selector(noButtonTapHandler), for: .touchUpInside)
        }
    }
    
    // MARK: Private func which setup all constrains.
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            generalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            generalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            generalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            generalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            questionLabel.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 13),
            questionLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 42),
            questionLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -42),
            questionLabel.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: -13),
            quizFilmImage.heightAnchor.constraint(equalTo: generalStackView.heightAnchor, multiplier: 2.0 / 3.0),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noButton.widthAnchor.constraint(equalToConstant: 157),
            noButton.heightAnchor.constraint(equalToConstant: 60),
            yesButton.widthAnchor.constraint(equalToConstant: 157),
            yesButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func yesButtonTapHandler() {
        notificationGenerator.notificationOccurred(.success)
        setEnabledButtons(to: false)
        presenter.yesButtonClicked()
    }
    
    @objc private func noButtonTapHandler() {
        notificationGenerator.notificationOccurred(.error)
        setEnabledButtons(to: false)
        presenter.noButtonClicked()
    }
    
    // MARK: Private func which hide second touch on buttons.
    private func setEnabledButtons(to value: Bool) {
        noButton.isEnabled = value
        yesButton.isEnabled = value
    }
    
    func show(quiz step: QuizStepViewModel) {
        setEnabledButtons(to: true)
        quizFilmImage.image = step.image
        quizFilmImage.layer.borderWidth = 0
        quizFilmImage.layer.borderColor = Constants.Colors.black?.cgColor
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
    }
    
    // MARK: Override property which set style for StatusBar.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.restartGame()
            self.setEnabledButtons(to: true)
            self.showLoadingIndicator()
        }
        
        alertPresenter?.showAlertResult(alertModel: alert)
    }
    
    func show(quiz result: QuizResultViewModel) {
        let message = presenter.makeResultMessage()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else {return}
                self.presenter.restartGame()
                self.setEnabledButtons(to: true)
            }
        )
        
        alertPresenter?.showAlertResult(alertModel: alertModel)
    }
    
    func highlightImageBorder(_ isCorrect: Bool) {
        quizFilmImage.layer.masksToBounds = true
        quizFilmImage.layer.borderWidth = 8
        quizFilmImage.layer.borderColor = isCorrect ? Constants.Colors.green?.cgColor : Constants.Colors.red?.cgColor
    }
}



