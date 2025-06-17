// StatisticsCell.swift
import UIKit
final class StatisticsCell: UITableViewCell {
    static let reuseIdentifier = "StatisticsCell"
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let gradientBorderView = GradientView()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with statistic: StatisticsItem) {
        titleLabel.text = statistic.title
        valueLabel.text = "\(statistic.value)"
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Настройка градиентной рамки
        gradientBorderView.configureGradient(
            colors: [
                UIColor(hex: "#007BFA")!,
                UIColor(hex: "#46E69D")!,
                UIColor(hex: "#FD4C49")!
            ],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 1, y: 0.5)
        )
        gradientBorderView.layer.cornerRadius = 16
        gradientBorderView.layer.masksToBounds = true
        
        // Настройка контейнера
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        
        // Настройка меток
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        valueLabel.font = .boldSystemFont(ofSize: 34)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 1
        valueLabel.setContentHuggingPriority(.required, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        valueLabel.adjustsFontSizeToFitWidth = true // Автоматическое уменьшение шрифта
        valueLabel.minimumScaleFactor = 0.5 // Минимальный масштаб шрифта
        
        // Иерархия представлений
        addSubview(gradientBorderView)
        gradientBorderView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        // Констрейнты
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            gradientBorderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            gradientBorderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            gradientBorderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            
            containerView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor, constant: -1),
            containerView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor, constant: -1),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 1), // Уменьшил отступ
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
}
