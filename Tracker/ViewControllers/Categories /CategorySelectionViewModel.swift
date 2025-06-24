import Foundation


protocol CategorySelectionViewModelProtocol: AnyObject {
    var categories: [TrackerCategory] {get}
    var onCategoriesUpdate: (() -> Void)? {get set}
    var onCategorySelected: ((String) -> Void)? {get set}
    
    func loadCategories()
    func selectCategory(at index: Int)
    func createCategory(with title: String)
    func editCategory(at index: Int, newTitle: String)
    func deleteCategory(at index: Int)
    
}

final class CategorySelectionViewModel: CategorySelectionViewModelProtocol {
    
    private let categoryStore: TrackerCategoryStorable
    private(set) var categories: [TrackerCategory] = []
    var onCategoriesUpdate: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    init(categoryStore: TrackerCategoryStorable = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
    }
    
    
    func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
            onCategoriesUpdate?()
        } catch {
            print("Не удалось загрузить категории: \(error)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else {return}
        let selectedCategory = categories[index].title
        onCategorySelected?(selectedCategory)
    }
    
    func editCategory(at index: Int, newTitle: String) {
            guard index >= 0 && index < categories.count else { return }
            let oldTitle = categories[index].title
            do {
                try categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
                loadCategories()
            } catch {
                print("Не удалось обновить категорию \(oldTitle): \(error)")
            }
        }
        
        func deleteCategory(at index: Int) {
            guard index >= 0 && index < categories.count else { return }
            let title = categories[index].title
            do {
                try categoryStore.deleteCategory(title: title)
                loadCategories()
            } catch {
                print("Не удалось удалить категорию \(title): \(error)")
            }
        }
    
    func createCategory(with title: String) {
        do {
            _ = try categoryStore.createCategory(title: title)
            loadCategories()
        } catch {
            print("Не удалось создать категорию: \(error)")
        }
    }
}
