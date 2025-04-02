import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    var onActionButtonTapped: ((UUID, Bool) -> Void)?
    
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        [titleLabel, emojiLabel, actionButton, daysCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        emojiLabel.font = .systemFont(ofSize: 24)
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        
        daysCountLabel.font = .systemFont(ofSize: 14)
        daysCountLabel.textColor = .darkGray
        
        actionButton.layer.cornerRadius = 17
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding * 2),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            daysCountLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        trackerId = tracker.id
        self.completedDays = completedDays
        self.isCompletedToday = isCompletedToday
        
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        updateDaysCountText()
        updateButtonAppearance()
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
    
    private func updateButtonAppearance() {
        actionButton.backgroundColor = isCompletedToday ?
            UIColor.systemGreen.withAlphaComponent(0.3) :
            UIColor.systemRed.withAlphaComponent(0.3)
        
        actionButton.setTitle(isCompletedToday ? "✓" : "+", for: .normal)
        actionButton.isEnabled = !isCompletedToday
    }
    
    @objc private func actionButtonTapped() {
        guard let trackerId = trackerId, !isCompletedToday else { return }
        
        // Обновляем счетчик
        completedDays += 1
        updateDaysCountText()
        
        // Меняем состояние кнопки
        isCompletedToday = true
        updateButtonAppearance()
        
        // Уведомляем о нажатии
        onActionButtonTapped?(trackerId, true)
    }
}
