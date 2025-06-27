
import UIKit

final class CategorySelectionViewController: UIViewController {
    private let viewModel: CategorySelectionViewModelProtocol
    private let onCreateNewCategory: () -> Void
    private let categoryLabel = UILabel()
    private let imageView = UIImageView()
    private let colors = UIColors.shared
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
        button.setTitle("addCategoryButton.title".localized, for: .normal)
        button.setTitleColor(UIColors.shared.adaptiveButtonText, for: .normal)
        button.backgroundColor = UIColors.shared.adaptiveButtonBackground
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
        setupHideKeyboardOnTap()
        viewModel.loadCategories()
    }
    
    private func setupUI() {
        title = "category.title".localized
        view.backgroundColor = UIColors.shared.viewBackgroundColor
        
        // Настройка изображения для пустого состояния
        imageView.image = UIImage(named: "EmptyStatistic")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Настройка лейбла для пустого состояния
        categoryLabel.text = "categoryLable.title".localized
        categoryLabel.textColor = .label
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
    
    private func updateCategoryEmptyStateVisibility() {
        let isEmpty = viewModel.categories.isEmpty
        imageView.isHidden = !isEmpty
        categoryLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.updateCategoryEmptyStateVisibility()
        }
    }
    
    @objc private func addCategoryTapped() {
        onCreateNewCategory()
    }
    
    private func showEditCategoryScreen(forCategoryAt index: Int) {
        let categoryTitle = viewModel.categories[index].title
        let editCategoryVC = NewCategoryViewController(viewModel: viewModel, initialTitle: categoryTitle, isEditingCategory: true, editIndex: index)
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
}

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        let isLastCell = indexPath.row == viewModel.categories.count - 1
        
        if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = cornerRadius
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
        
        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "edit.title".localized) { [weak self] _ in
                self?.showEditCategoryScreen(forCategoryAt: indexPath.row)
            }
            let deleteAction = UIAction(title: "delete.title".localized, attributes: .destructive) { [weak self] _ in
                self?.confirmDeleteCategory(at: indexPath.row)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func confirmDeleteCategory(at index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "thisCategoryIsUnneeded.title".localized,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "cancel.title".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete.title".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        })
        present(alert, animated: true)
    }
}
