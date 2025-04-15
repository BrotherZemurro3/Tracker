import UIKit


final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleCell"
    
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()
    
    var onSwitchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .ypBackground
        
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with day: Weekday, isOn: Bool) {
        titleLabel.text = day.fullName
        switchControl.isOn = isOn
        switchControl.tag = day.rawValue
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        onSwitchChanged?(sender.isOn)
    }
}
