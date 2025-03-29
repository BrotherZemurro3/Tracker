import UIKit


protocol CreateTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String)
}


class CreateTrackerViewController: UIViewController {
    weak var delegate: CreateTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        // Здесь реализуйте интерфейс для создания трекера:
        // - Поле для названия
        // - Выбор категории
        // - Выбор эмодзи
        // - Выбор цвета
        // - Кнопка "Создать"
        
        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        // Добавьте остальные UI элементы и констрейнты
    }
    
    @objc private func createTracker() {
        // Создаем тестовый трекер (замените на реальные данные из формы)
        let newTracker = Tracker(
            id: UUID(),
            title: "Новый трекер",
            color: .systemBlue,
            emoji: "😀",
            schedule: [.monday, .wednesday, .friday]
        )
        
        delegate?.didCreateTracker(newTracker, in: "Важная категория")
        dismiss(animated: true)
    }
}
