import UIKit

class CategorySelectionViewController: UIViewController {
    private let viewModel: CategorySelectionViewModelProtocol
    private let onCreateNewCategory: () -> Void
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategorySelectionCell.self, forCellReuseIdentifier: CategorySelectionCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        tableView.separatorStyle = .singleLine
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func addCategoryTapped() {
        onCreateNewCategory()
        print("Кнопка нажата")
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
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
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
            // Для последней ячейки скрываем разделитель
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            // Для всех остальных ячеек (включая первую) устанавливаем стандартные отступы
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
}
