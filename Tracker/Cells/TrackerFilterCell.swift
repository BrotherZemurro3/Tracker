import UIKit

final class TrackerFilterCell: UITableViewCell {
    static let reuseIdentifier = "TrackerFilterCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with filter: TrackerFilter, isSelected: Bool) {
        textLabel?.text = filter.rawValue.localized
        textLabel?.font = .systemFont(ofSize: 17)
        backgroundColor = .ypBackground
        accessoryType = isSelected ? .checkmark : .none
    }
    
    func configureCorners(for indexPath: IndexPath, totalCount: Int) {
        let cornerRadius: CGFloat = 16
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == totalCount - 1
        
        if isFirstCell && isLastCell {
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                 .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstCell {
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }
        
        layer.masksToBounds = true
        
        // Настройка разделителей
        if isLastCell {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func setupCell() {
        selectionStyle = .none
    }
}
