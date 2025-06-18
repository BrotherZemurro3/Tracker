import UIKit

protocol TrackerFilterDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

final class TrackerFilterViewController: UIViewController {
    private let tableView = UITableView()
    private let filters: [TrackerFilter] = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter
    weak var delegate: TrackerFilterDelegate?
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColors.shared.viewBackgroundColor
        title = "Фильтры".localized
        navigationItem.largeTitleDisplayMode = .never
        
        setupTableView()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.register(TrackerFilterCell.self, forCellReuseIdentifier: TrackerFilterCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
    }
}

// MARK: - UITableViewDataSource
extension TrackerFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerFilterCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerFilterCell else {
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        cell.configure(with: filter, isSelected: filter == selectedFilter)
        cell.configureCorners(for: indexPath, totalCount: filters.count)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFilter = filters[indexPath.row]
        tableView.reloadData()
        delegate?.didSelectFilter(selectedFilter)
    }
}
