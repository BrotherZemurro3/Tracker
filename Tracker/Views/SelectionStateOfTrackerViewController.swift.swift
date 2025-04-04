import UIKit

class SelectionStateOfTrackerViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    let habitButton = UIButton()
    let irregularHabitButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButtonsUI()
    }
    
    private func setupButtonsUI() {
           // Кнопка привычки
           habitButton.setTitle("Привычка", for: .normal)
           habitButton.backgroundColor = .black
           habitButton.setTitleColor(.white, for: .normal)
           habitButton.layer.cornerRadius = 16
           habitButton.addTarget(self, action: #selector(chooseHabit), for: .touchUpInside)
           habitButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(habitButton)
           
           // Кнопка нерегулярного события
           irregularHabitButton.setTitle("Нерегулярное событие", for: .normal)
           irregularHabitButton.backgroundColor = .black
           irregularHabitButton.setTitleColor(.white, for: .normal)
           irregularHabitButton.layer.cornerRadius = 16
           irregularHabitButton.addTarget(self, action: #selector(chooseIrregular), for: .touchUpInside)
           irregularHabitButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(irregularHabitButton)
           
           NSLayoutConstraint.activate([
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

