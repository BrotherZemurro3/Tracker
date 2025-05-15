import UIKit

final class CategorySelectionCell: UITableViewCell {
    static let reuseIdentifier = "CategorySelectionCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        textLabel?.font = .systemFont(ofSize: 17)
        backgroundColor = .ypBackground
        selectionStyle = .default
    }
    
    func configure(with title: String) {
        backgroundColor = .ypBackground
        textLabel?.text = title
        textLabel?.font = .systemFont(ofSize: 17)
    }
}
