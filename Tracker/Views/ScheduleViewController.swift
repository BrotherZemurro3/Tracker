import UIKit

class ScheduleViewController: UIViewController {
    private let tableView = UITableView()
    private let daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var switchStates: [Bool] {
        get {
            return UserDefaults.standard.array(forKey: "switchStates") as? [Bool] ?? Array(repeating: false, count: 7)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "switchStates")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        
        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = switchStates[indexPath.row]
        toggleSwitch.tag = indexPath.row
        toggleSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = toggleSwitch
        return cell
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        var states = switchStates
        states[sender.tag] = sender.isOn
        switchStates = states
    }
}
