import UIKit

class ScheduleViewController: UIViewController {
    var selectedDays: [Weekday] = []
    var onDaysSelected: (([Weekday]) -> Void)?
    
    private let tableView = UITableView()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Расписание"
        setupUI()
    }
    
    private func setupUI() {
        setupTableView()
        setupSaveButton()
        setupConstraints()
    }
    // Настройка таблицы
    private func setupTableView() {
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
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
    // Настройка кнопки сохранения
    private func setupSaveButton() {
        saveButton.setTitle("Готово", for: .normal)
        saveButton.backgroundColor = .black
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func saveTapped() {
        onDaysSelected?(selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    // Количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.displayOrderedCases.count
    }
    // Создание и настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        
        let day = Weekday.displayOrderedCases[indexPath.row]
        cell.configure(with: day, isOn: selectedDays.contains(day))
        
        cell.onSwitchChanged = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedDays.contains(day) {
                    self.selectedDays.append(day)
                }
            } else {
                self.selectedDays.removeAll { $0 == day }
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    // Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // Разделитель
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let cornerRadius: CGFloat = 16
            let isLastCell = indexPath.row == Weekday.displayOrderedCases.count - 1
            
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
/*
// Превью
#if DEBUG
import SwiftUI

struct ScheduleViewController_Preview: PreviewProvider {
static var previews: some View {
let viewController = ScheduleViewController()
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
