import UIKit

class CategorySelectionViewController: UIViewController {
    private let viewModel: CategorySelectionViewModelProtocol
    private let onCreateNewCategory: () -> Void
    private let categoryLabel = UILabel()
    private let imageView = UIImageView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategorySelectionCell.self, forCellReuseIdentifier: CategorySelectionCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.isEnabled = true
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategorySelectionViewModelProtocol, onCreateNewCategory: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onCreateNewCategory = onCreateNewCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadCategories()
    }
    
    private func setupUI() {
        title = "Категория"
        view.backgroundColor = .white
        
        // Настройка изображения для пустого состояния
        imageView.image = UIImage(named: "EmptyStatistic")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Настройка лейбла для пустого состояния
        categoryLabel.text = "Привычки и события можно\n объединить по смыслу"
        categoryLabel.textColor = .black
        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textAlignment = .center
        categoryLabel.numberOfLines = 0
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryLabel)
        
        // Добавление таблицы и кнопки
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Таблица
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            // Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Изображение пустого состояния (центрировано)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Лейбл пустого состояния
            categoryLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Изначально скрываем таблицу и показываем пустое состояние
        updateCategoryEmptyStateVisibility()
    }
// MARK: - Скрытие заглушки
    private func updateCategoryEmptyStateVisibility() {
        let isEmpty = viewModel.categories.isEmpty
        imageView.isHidden = !isEmpty
        categoryLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
// MARK: - Байдинги
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.updateCategoryEmptyStateVisibility()
        }
    }
    
    @objc private func addCategoryTapped() {
        onCreateNewCategory()
     
    }
}

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    // Количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    // Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // Создание и настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategorySelectionCell.reuseIdentifier,
            for: indexPath
        ) as? CategorySelectionCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.categories[indexPath.row].title)
        return cell
    }
    // Выбор ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell {
            cell.configure(with: viewModel.categories[indexPath.row].title, isSelected: true)
        }
        
        
        for visibleIndexPath in tableView.indexPathsForVisibleRows ?? [] {
            if visibleIndexPath != indexPath,
               let otherCell = tableView.cellForRow(at: visibleIndexPath) as? CategorySelectionCell {
                otherCell.configure(with: viewModel.categories[visibleIndexPath.row].title, isSelected: false)
            }
        }
        
        viewModel.selectCategory(at: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
    // Отображение ячейки 
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        let isLastCell = indexPath.row == viewModel.categories.count - 1
        
        // Настройка закругления
        if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = cornerRadius
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
        
        // Настройка разделителей
        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
