import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "trackerCell"
    
    // UI элементы
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    // Константы
    private let padding: CGFloat = 12
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        contentView.backgroundColor = tracker.color
        
        daysCountLabel.text = "\(completedDays) дней"
        
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        [titleLabel, emojiLabel, actionButton, daysCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
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
    
    @objc private func actionButtonTapped() {
        // Обработка нажатия будет в контроллере через замыкание
    }
}
