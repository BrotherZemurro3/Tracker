import UIKit

class SelectionStateOfTrackerViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    private let habitButton = UIButton()
    private let irregularHabitButton = UIButton()
    private  let createTrackerLabel = UILabel()
    private let colors = UIColors.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        setupUI()
    }
    
    private func setupUI() {
        // Создание трекеров
        createTrackerLabel.text = "createTracker.title".localized
        createTrackerLabel.tintColor = .black
        createTrackerLabel.font = UIFont(name: "YS Display-Medium", size: 16)
        createTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createTrackerLabel)
        
        
        // Кнопка привычки
        habitButton.setTitle("habit.title".localized, for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.backgroundColor = UIColors.shared.adaptiveButtonBackground
        habitButton.setTitleColor(UIColors.shared.adaptiveButtonText, for: .normal)
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(chooseHabit), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        // Кнопка нерегулярного события
        irregularHabitButton.setTitle("irregularEvent.title".localized, for: .normal)
        irregularHabitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularHabitButton.backgroundColor = UIColors.shared.adaptiveButtonBackground
        irregularHabitButton.setTitleColor(UIColors.shared.adaptiveButtonText, for: .normal)
        irregularHabitButton.layer.cornerRadius = 16
        irregularHabitButton.addTarget(self, action: #selector(chooseIrregular), for: .touchUpInside)
        irregularHabitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularHabitButton)
        
        NSLayoutConstraint.activate([
            // Верхний лейбл
            createTrackerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createTrackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -28),
            
            // Привычка
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Нерегулярное событие
            irregularHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularHabitButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularHabitButton.widthAnchor.constraint(equalToConstant: 335),
            irregularHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    @objc private func chooseHabit() {
        let regularTrackerVC = CreateRegularTrackerViewController()
        regularTrackerVC.delegate = delegate // Передаем делегата дальше
        navigationController?.pushViewController(regularTrackerVC, animated: true)
    }
    
    @objc private func chooseIrregular() {
        let irregularTrackerVC = CreateIrregularTrackerViewController()
        irregularTrackerVC.delegate = delegate // Передаем делегата дальше
        navigationController?.pushViewController(irregularTrackerVC, animated: true)
    }
    
    
}

