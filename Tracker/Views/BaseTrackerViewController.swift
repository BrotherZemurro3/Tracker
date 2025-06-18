import UIKit

class BaseTrackerViewController: UIViewController, TrackerCreationDelegate {
    weak var delegate: TrackerCreationDelegate?
    private let categoryViewModel = CategorySelectionViewModel()
     let scrollView = UIScrollView()
     let contentView = UIView()
     let tableView = UITableView()
     let textField = UITextField()
     let errorLabel = UILabel()
     let emojiLabel = UILabel()
     let colorLabel = UILabel()
     let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
     let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
     let cancelButton = UIButton(type: .system)
     let createButton = UIButton(type: .system)
     let colors = UIColors.shared

    let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    let colorOptions: [UIColor] = [
        .red, .orange, .blue, .darkViolet, .darkerGreen,
        .fuchsia, .lightPink, .cyan1, .lightGreen, .darkBlue,
        .corralOne, .pink1, .beige, .lilac, .violet2, .darkFuchsia, .lightViolet, .green1
    ]

    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedCategory: String?
    var selectedDays: [Weekday] = []
    var isRegular: Bool { return true } // Subclasses override this

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupHideKeyboardOnTap()
        navigationItem.hidesBackButton = true
    }

    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = isRegular ? "newHabit.title".localized : "newIrregularEvent.title".localized
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16)]
    }

    private func setupUI() {
        view.backgroundColor = colors.viewBackgroundColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        [tableView, textField, errorLabel, emojiLabel, colorLabel, emojiCollectionView, colorCollectionView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupTextField()
        setupTableView()
        setupEmojiSection()
        setupColorSection()
        setupButtons()
        setupConstraints()
    }

    private func setupTextField() {
        textField.placeholder = "textField.placeholder".localized
        textField.backgroundColor = UIColor(named: "Background ")
        textField.layer.cornerRadius = 16
        textField.textAlignment = .natural
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            textField.semanticContentAttribute = .forceRightToLeft
            textField.textAlignment = .right
        } else {
            textField.textAlignment = .natural
        }

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        errorLabel.text = "errorLabel.title".localized
        errorLabel.font = .systemFont(ofSize: 17)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center

        contentView.addSubview(errorLabel)
        contentView.addSubview(textField)
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        contentView.addSubview(tableView)
    }

    private func setupEmojiSection() {
        emojiLabel.text = "Emoji"
        emojiLabel.font = .boldSystemFont(ofSize: 19)
        contentView.addSubview(emojiLabel)

        emojiCollectionView.collectionViewLayout = createEmojiLayout()
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.isScrollEnabled = false
        contentView.addSubview(emojiCollectionView)
    }

    private func setupColorSection() {
        colorLabel.text = "colorLabel.title".localized
        colorLabel.font = .boldSystemFont(ofSize: 19)
        contentView.addSubview(colorLabel)

        colorCollectionView.collectionViewLayout = createColorLayout()
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.isScrollEnabled = false
        contentView.addSubview(colorCollectionView)
    }

    private func setupButtons() {
        cancelButton.setTitle("cancel.title".localized, for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = colors.viewBackgroundColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)

        createButton.setTitle("create.title".localized, for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.backgroundColor = .gray
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        createButton.isEnabled = false

        let buttonsContainer = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonsContainer.axis = .horizontal
        buttonsContainer.distribution = .fillEqually
        buttonsContainer.spacing = 8
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonsContainer)

        NSLayoutConstraint.activate([
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 4),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupConstraints() {
        let tableViewHeight: CGFloat = isRegular ? 150 : 75 // Adjust for schedule row
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
            errorLabel.heightAnchor.constraint(equalToConstant: 16),

            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),

            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func createEmojiLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(52), heightDimension: .absolute(52))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 6)
        group.interItemSpacing = .fixed(5)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func createColorLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(52), heightDimension: .absolute(52))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 6)
        group.interItemSpacing = .fixed(5)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Actions
    @objc private func textFieldDidChange() {
        if let text = textField.text, text.count <= 38 {
            errorLabel.isHidden = true
        }
        updateCreateButtonState()
    }

    @objc private func selectCategory() {
        let categorySelectionVC = CategorySelectionViewController(viewModel: categoryViewModel) { [weak self] in
            self?.showNewCategoryScreen()
        }
        categoryViewModel.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
            self?.tableView.reloadData()
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(categorySelectionVC, animated: true)
    }

    private func showNewCategoryScreen() {
        let newCategoryVC = NewCategoryViewController(viewModel: categoryViewModel)
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }

    @objc private func cancelCreation() {
        dismiss(animated: true)
    }

    @objc private func createTracker() {
        guard let title = textField.text, !title.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor,
              let selectedCategory = selectedCategory else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: isRegular ? selectedDays : nil,
            isCompleted: false,
            isRegular: isRegular,
            creationDate: Date(),
            isPinned: false
        )

        delegate?.didCreateTracker(newTracker, in: selectedCategory)
        dismiss(animated: true)
    }

    // MARK: - Subclass Hooks
    func updateCreateButtonState() {
        guard let text = textField.text, !text.isEmpty,
              selectedEmoji != nil,
              selectedColor != nil,
              selectedCategory != nil else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
            return
        }
        if isRegular && selectedDays.isEmpty {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
            return
        }
        createButton.isEnabled = true
        createButton.titleLabel?.textColor = colors.adaptiveButtonText
        createButton.backgroundColor = colors.adaptiveButtonBackground
    }

    // MARK: - TrackerCreationDelegate
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        delegate?.didCreateTracker(tracker, in: categoryTitle)
    }
    func didUpdateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?) {
           delegate?.didUpdateTracker(tracker, in: categoryTitle, oldCategoryTitle: oldCategoryTitle)
       }
}

extension BaseTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isRegular ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(named: "Background ")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = UIColor(named: "black[day]")
        cell.detailTextLabel?.textColor = .gray

        if indexPath.row == 0 {
            cell.textLabel?.text = "categories.title".localized
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.detailTextLabel?.text = selectedCategory ?? "notSelected.title".localized
            cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        } else {
            if selectedDays.isEmpty {
                cell.textLabel?.text = "schedule.title".localized
                cell.textLabel?.textAlignment = .center
                cell.detailTextLabel?.text = nil
            } else {
                cell.textLabel?.text = "Расписание"
                cell.textLabel?.textAlignment = .natural
                cell.detailTextLabel?.text = selectedDays.map { $0.shortName }.joined(separator: ", ")
                cell.detailTextLabel?.font = .systemFont(ofSize: 17)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            selectCategory()
        } else if isRegular {
            selectSchedule()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && !isRegular || indexPath.row == 1 && isRegular {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    @objc private func selectSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = selectedDays
        scheduleVC.onDaysSelected = { [weak self] days in
            self?.selectedDays = days
            self?.tableView.reloadData()
            self?.updateCreateButtonState()
        }
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
    }
}

extension BaseTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colorOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            cell.emojiLabel.text = emojis[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.colorView.backgroundColor = colorOptions[indexPath.row]
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)
                cell.contentView.layer.cornerRadius = 8
            }
        } else {
            selectedColor = colorOptions[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.contentView.layer.borderWidth = 4
                cell.contentView.layer.borderColor = colorOptions[indexPath.row].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
            }
        }
        updateCreateButtonState()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = .clear
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.contentView.layer.borderWidth = 0
                cell.contentView.layer.borderColor = nil
            }
        }
    }
}

extension BaseTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        errorLabel.isHidden = updatedText.count <= 38
        return updatedText.count <= 38
    }
}
