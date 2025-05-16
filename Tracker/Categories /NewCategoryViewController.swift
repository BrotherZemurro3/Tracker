import UIKit

class NewCategoryViewController: UIViewController {
    private let viewModel: CategorySelectionViewModelProtocol
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(named: "lightGray")
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategorySelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextField()
    }
    
    private func setupUI() {
        title = "Новая категория"
        view.backgroundColor = .white
        
        view.addSubview(textField)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = createButton.isEnabled ? .black : .gray
    }
    
    @objc private func createButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        viewModel.createCategory(with: categoryName)
        navigationController?.popViewController(animated: true)
    }
}
