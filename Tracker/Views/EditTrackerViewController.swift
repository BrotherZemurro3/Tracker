import UIKit

final class EditTrackerViewController: BaseTrackerViewController {
    private let tracker: Tracker
    private let oldCategoryTitle: String
    private let completedDays: Int
    private let headerLabel = UILabel()
    private let daysLabel = UILabel()

    init(tracker: Tracker, categoryTitle: String, completedDays: Int) {
        self.tracker = tracker
        self.oldCategoryTitle = categoryTitle
        self.completedDays = completedDays
        super.init(nibName: nil, bundle: nil)
        // Pre-fill data
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedCategory = categoryTitle
        selectedDays = tracker.schedule ?? []
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        textField.text = tracker.title
        updateCreateButtonState()
        selectInitialEmojiAndColor()
    }

    override var isRegular: Bool {
        return tracker.isRegular
    }

     func setupNavigationBar() {
        title = "editTracker.title".localized
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16)]
    }

    private func setupHeader() {
        headerLabel.text = "editTracker.title".localized
        headerLabel.font = .boldSystemFont(ofSize: 16)
        headerLabel.textColor = colors.labelColor
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)

        let dayString = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "Number of days"),
            completedDays
        )
        daysLabel.text = "\(completedDays) \(dayString)"
        daysLabel.font = .systemFont(ofSize: 12)
        daysLabel.textColor = colors.labelColor
        daysLabel.textAlignment = .center
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysLabel)

        // Adjust textField top constraint to account for header
        NSLayoutConstraint.deactivate(contentView.constraints.filter { $0.firstItem === textField && $0.firstAttribute == .top })
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            daysLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            textField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    private func selectInitialEmojiAndColor() {
        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            let indexPath = IndexPath(item: emojiIndex, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            if let cell = emojiCollectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)
                cell.contentView.layer.cornerRadius = 8
            }
        }

        if let colorIndex = colorOptions.firstIndex(where: { $0 == tracker.color }) {
            let indexPath = IndexPath(item: colorIndex, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            if let cell = colorCollectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.contentView.layer.borderWidth = 4
                cell.contentView.layer.borderColor = tracker.color.withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
            }
        }
    }

     func createTracker() {
        guard let title = textField.text, !title.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor,
              let selectedCategory = selectedCategory else {
            return
        }

        let updatedTracker = Tracker(
            id: tracker.id,
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: isRegular ? selectedDays : nil,
            isCompleted: tracker.isCompleted,
            isRegular: tracker.isRegular,
            creationDate: tracker.creationDate,
            isPinned: tracker.isPinned
        )

        delegate?.didUpdateTracker(updatedTracker, in: selectedCategory, oldCategoryTitle: oldCategoryTitle)
        dismiss(animated: true)
    }
}
