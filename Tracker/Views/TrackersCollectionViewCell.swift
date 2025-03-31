import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let daysCountLabel = UILabel()
    private let padding: CGFloat = 12
    
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
    
    func configure(with tracker: Tracker) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        daysCountLabel.text = "\(tracker.schedule?.count ?? 0) days"
        
        let isCompleted = tracker.isCompleted
        actionButton.backgroundColor = isCompleted ? .green : .red
        actionButton.setTitle(isCompleted ? "✓" : "✗", for: .normal)
    }
    
    @objc private func actionButtonTapped() {
        print("Кнопка нажата!")
        // Здесь можно вызвать делегат или замыкание для обновления состояния трекера
    }
}
