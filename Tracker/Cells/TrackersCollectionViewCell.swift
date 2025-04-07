import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    var onActionButtonTapped: ((UUID, Bool) -> Void)?
    private let coloredBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let emojiBackgroundView = UIView()
    private let actionButton = UIButton(type: .system)
    private let daysCountLabel = UILabel()
    private let padding: CGFloat = 12
    private var trackerId: UUID?
    private var isCompletedToday: Bool = false
    private var completedDays: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Настройка цветного фона для верхней части
        coloredBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coloredBackgroundView)
        coloredBackgroundView.layer.cornerRadius = 10
        coloredBackgroundView.layer.masksToBounds = true
        
        // Настройка белого фона для нижней части (дни + кнопка)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Отключение автоматики
        [titleLabel, actionButton, daysCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Настройка фона для emoji
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.layer.masksToBounds = true
        coloredBackgroundView.addSubview(emojiBackgroundView)
        
        // Настройка emoji
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        coloredBackgroundView.addSubview(emojiLabel)
        
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        
        daysCountLabel.font = .systemFont(ofSize: 14)
        daysCountLabel.textColor = .black
        
        actionButton.layer.cornerRadius = 17
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Цветной овал
            coloredBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredBackgroundView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            // Прозрачный круг для emoji
            emojiBackgroundView.topAnchor.constraint(equalTo: coloredBackgroundView.topAnchor, constant: padding),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: coloredBackgroundView.leadingAnchor, constant: padding),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            // Смайлик (центрирован в круге)
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Название трекера
            titleLabel.leadingAnchor.constraint(equalTo: coloredBackgroundView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: coloredBackgroundView.trailingAnchor, constant: -padding),
            titleLabel.bottomAnchor.constraint(equalTo: coloredBackgroundView.bottomAnchor, constant: -padding),
            
            // Кнопка выполнения
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Лейбл Дни
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            daysCountLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool, currentDate: Date) {
        trackerId = tracker.id
        self.completedDays = completedDays
        self.isCompletedToday = isCompletedToday
        
        // Проверка, является ли выбранная дата сегодняшним днём
        let today = Calendar.current.startOfDay(for: Date())
        let isToday = Calendar.current.isDate(currentDate, inSameDayAs: today)
        
        // Устанавливаю цвет только для верхней части
        coloredBackgroundView.backgroundColor = tracker.color
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        
        updateDaysCountText()
        updateButtonAppearance()
        
        // Блокирую кнопку, если выбран не сегодняшний день
        actionButton.isEnabled = isToday && !isCompletedToday
    }
    private func updateDaysCountText() {
        let dayString = formatDaysCount(completedDays)
        daysCountLabel.text = "\(completedDays) \(dayString)"
    }
    
    private func formatDaysCount(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    private func updateButtonAppearance(animated: Bool = true) {
        guard let trackerColor = coloredBackgroundView.backgroundColor else { return }
        
        let duration = animated ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration) {
            if self.isCompletedToday {
                // Состояние "выполнено"
                self.actionButton.backgroundColor = trackerColor.withAlphaComponent(0.3)
                self.actionButton.setTitleColor(.white, for: .normal)
                self.actionButton.setTitle("✓", for: .normal)
            } else {
                // Состояние "не выполнено"
                self.actionButton.backgroundColor = trackerColor
                self.actionButton.setTitleColor(.white, for: .normal)
                self.actionButton.setTitle("+", for: .normal)
            }
            self.actionButton.transform = .identity
        }
        
        actionButton.isEnabled = !isCompletedToday
    }
    
    @objc private func actionButtonTapped() {
        guard let trackerId = trackerId else { return }
        
        // Анимация нажатия
        UIView.animate(withDuration: 0.2, animations: {
            self.actionButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.actionButton.transform = .identity
                
                if self.isCompletedToday {
                    // Если уже выполнено - отменяю
                    self.completedDays = max(0, self.completedDays - 1)
                    self.isCompletedToday = false
                    self.onActionButtonTapped?(trackerId, false)
                } else {
                    // Если не выполнено - отмечаю
                    self.completedDays += 1
                    self.isCompletedToday = true
                    self.onActionButtonTapped?(trackerId, true)
                }
                
                self.updateDaysCountText()
                self.updateButtonAppearance()
            }
        }
    }
}
