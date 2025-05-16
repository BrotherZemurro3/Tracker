import UIKit

final class CategorySelectionCell: UITableViewCell {
    static let reuseIdentifier = "CategorySelectionCell"
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .ypBackground
        selectionStyle = .none
        
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with title: String, isSelected: Bool = false) {
        textLabel?.text = title
        textLabel?.font = .systemFont(ofSize: 17)
        checkmarkImageView.isHidden = !isSelected
    }
}
