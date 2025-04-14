import UIKit

class CreateIrregularTrackerViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    private let contentView = UIView()
    private let tableView = UITableView()
    private let textField = UITextField()
    private let errorLabel = UILabel()
    private let categoryButton = UIButton(type: .system)
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let emojiCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦","🏓","🥇","🎸","🏝️","😪"]
    private let colors: [UIColor] = [
        .red, .orange, .blue, .darkViolet, .darkerGreen,
        .fuchsia, .lightPink, .cyan, .lightGreen, .darkBlue,
        .corralOne, .pink, .beige, .lilac, .darkViolet, .darkFuchsia, .lightViolet, .green
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupHideKeyboardOnTap()
        navigationItem.hidesBackButton = true
    }
    // Установка навигационного бара
    private func setupNavigationBar() {
        title = "Новое нерегулярное событие"
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 16)]
    }
    // Установка UI
    private func setupUI() {
        view.backgroundColor = .white
        
        [contentView, tableView, textField, errorLabel, emojiLabel, colorLabel, emojiCollectionView, colorCollectionView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(contentView)
        
        setupTextField()
        setupTableView()
        setupEmojiSection()
        setupColorSection()
        setupButtons()
        setupConstraints()
    }
    
    // Строка ввода названия
    private func setupTextField() {
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = .systemFont(ofSize: 17)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        
        contentView.addSubview(errorLabel)
        contentView.addSubview(textField)
    }
    // Таблица категории
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        contentView.addSubview(tableView)
    }
    // Лейбл Емоджи и таблица с ними
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
    // Лейбл Цвет и таблица цветов
    private func setupColorSection() {
        colorLabel.text = "Цвет"
        colorLabel.font = .boldSystemFont(ofSize: 19)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        
        colorCollectionView.collectionViewLayout = createColorLayout()
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.isScrollEnabled = false
        contentView.addSubview(colorCollectionView)
    }
    // Кнопки отменить и создать
    private func setupButtons() {
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .white
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)
        
        
        createButton.setTitle("Создать", for: .normal)
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
    // Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
                   errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 16),
                   errorLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
                   errorLabel.heightAnchor.constraint(equalToConstant: 16),
            
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 18),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -42),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: -16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 15),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
        ])
    }
    // Организация ячейки с эмоджи
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
    // Организация ячейки с цветом
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
    // Состояние выбранной ячейки (Эмоджи и Цвет)
    // Кнопка создать не активна, пока не выбрано всё
    private func updateCreateButtonState() {
        guard let text = textField.text, !text.isEmpty,
              selectedEmoji != nil,
              selectedColor != nil,
              selectedCategory != nil else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
            return
        }
        createButton.isEnabled = true
        createButton.backgroundColor = .blackDay
    }
    // Поле создания названия трекера, вызывается после изменения текста в UITextField
    @objc private func textFieldDidChange() {
        // Скрываем сообщение об ошибке, если текст в пределах лимита
        if let text = textField.text, text.count <= 38 {
            errorLabel.isHidden = true
        }
        updateCreateButtonState()
    }
    // Выбор категории
    @objc private func selectCategory() {
        let alert = UIAlertController(title: "Выберите категорию", message: nil, preferredStyle: .actionSheet)
        let categories = ["Важное", "Работа", "Личное", "Спорт"]
        
        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.selectedCategory = category
                self?.tableView.reloadData()
                self?.updateCreateButtonState()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    // Отмена создания трекера
    @objc private func cancelCreation() {
        dismiss(animated: true)
    }
    // Создание трекера
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
            schedule: nil,
            isCompleted: false,
            isRegular: false,
            shouldRemoveAfterCompletion: true
        )
        
        delegate?.didCreateTracker(newTracker, in: selectedCategory)
        dismiss(animated: true)
    }
}

extension CreateIrregularTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    // Кол-во ячеек (Категории)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // Создание и настройка ячейки (Категории)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        // Ячейка
        cell.backgroundColor = .systemGray6
        cell.accessoryType = .disclosureIndicator
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        // Основной текст
        cell.textLabel?.text = "Категории"
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .systemFont(ofSize: 17)
        
        // Подзаголовок (выбранная категория)
        cell.detailTextLabel?.text = selectedCategory
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .gray
    
        
        // Если категория не выбрана - центровочка основного текста
        if selectedCategory == nil {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.frame = cell.contentView.bounds
        } else {
            cell.textLabel?.textAlignment = .natural // или .left
            cell.textLabel?.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: 20) 
        }
        
        return cell
    }
    // Высота ячейки (Категории)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // Обработка нажатия на ячейку (Категории)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
              selectCategory()
    }
}

extension CreateIrregularTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Количество ячеек (эмоджи + цвета)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    // Создание и настройка ячейки (эмоджи и цвет)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            cell.emojiLabel.text = emojis[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.colorView.backgroundColor = colors[indexPath.row]
            return cell
        }
    }
    // Выбор ячейки (эмоджи и цвет)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)
                cell.contentView.layer.cornerRadius = 16
            }
        } else {
            selectedColor = colors[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = colors[indexPath.row].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 16
                cell.contentView.layoutMargins = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            }
        }
        updateCreateButtonState()
    }
    // Снятие выбора ячейки (эмоджи и цвет)
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
    
extension CreateIrregularTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        errorLabel.isHidden = updatedText.count <= 38
        
        return updatedText.count <= 38
    }
}

/*
 // Превью для отслеживания
#if DEBUG
import SwiftUI

struct CreateIrregularTrackerViewController_Preview: PreviewProvider {
    static var previews: some View {
        let viewController = CreateIrregularTrackerViewController()
        return UINavigationController(rootViewController: viewController)
            .toPreview()
            .edgesIgnoringSafeArea(.all)
    }
}
extension UIViewController {
    func toPreview() -> some View {
        Preview(viewController: self)
    }
    
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // Nothing to update
        }
    }
}
#endif

*/
