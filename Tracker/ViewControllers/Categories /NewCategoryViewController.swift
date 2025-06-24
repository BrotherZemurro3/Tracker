
import UIKit

final class NewCategoryViewController: UIViewController {
    private let viewModel: CategorySelectionViewModelProtocol
    private let initialTitle: String?
    private let isEditingCategory: Bool
    private let editIndex: Int?
    private let colors = UIColors.shared
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "newCategory.placeholder".localized
        textField.backgroundColor = UIColor(named: "Background ")
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            textField.semanticContentAttribute = .forceRightToLeft
            textField.textAlignment = .right
        } else {
            textField.textAlignment = .natural
        }
        return textField
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("doneButton.title".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategorySelectionViewModelProtocol, initialTitle: String? = nil, isEditingCategory: Bool = false, editIndex: Int? = nil) {
        self.viewModel = viewModel
        self.initialTitle = initialTitle
        self.isEditingCategory = isEditingCategory
        self.editIndex = editIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextField()
        if let initialTitle = initialTitle {
            textField.text = initialTitle
            createCategoryButton.isEnabled = !initialTitle.isEmpty
            createCategoryButton.backgroundColor = UIColors.shared.adaptiveButtonBackground
        }
        setupHideKeyboardOnTap()
    }
    
    private func setupUI() {
        title = isEditingCategory ? "editCategory.title".localized : "newCategory.title".localized
        view.backgroundColor = UIColors.shared.viewBackgroundColor
        
        view.addSubview(textField)
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextField() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        createCategoryButton.isEnabled = !text.isEmpty
        createCategoryButton.backgroundColor = createCategoryButton.isEnabled ? UIColors.shared.adaptiveButtonBackground : .gray
        createCategoryButton.titleLabel?.textColor = UIColors.shared.adaptiveButtonText
    }
    
    @objc private func doneButton() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        if isEditingCategory, let index = editIndex {
            viewModel.editCategory(at: index, newTitle: categoryName)
        } else {
            viewModel.createCategory(with: categoryName)
        }
        navigationController?.popViewController(animated: true)
    }
}

