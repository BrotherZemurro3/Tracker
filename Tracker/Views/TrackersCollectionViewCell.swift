import UIKit

// Ячейка
// Оформление каждой привычке в списке
// Реагирует на нажатия (например, отметка о выполнении
class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerСell"
    
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let actionButton = UIButton()
    private let daysCountLabel = UILabel()
    private let padding: CGFloat = 12
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emojiLabel)
        titleLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            //Эмоджи сверху слева
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
             emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
             emojiLabel.widthAnchor.constraint(equalToConstant: 24),
             emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Заголовок
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding * 2),
            // Кнопка (в правом нижнем углу)
              actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
              actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
              actionButton.widthAnchor.constraint(equalToConstant: 34),
              actionButton.heightAnchor.constraint(equalToConstant: 34),

              // Количество дней (рядом с кнопкой)
              daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
              daysCountLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor)
          ])
    }
    
    func configure(with tracker: Tracker) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        daysCountLabel.text = "\(tracker.schedule?.count ?? 0) days"
        
        // Настройка кнопки в зависимости от того, выполнена ли привычка
        if tracker.isCompleted {
            actionButton.backgroundColor = .green
            actionButton.setTitle("✓", for: .normal)
        } else {
            actionButton.backgroundColor = .red
            actionButton.setTitle("✗", for: .normal)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
