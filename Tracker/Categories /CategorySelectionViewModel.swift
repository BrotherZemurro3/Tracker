import Foundation


protocol CategorySelectionViewModelProtocol: AnyObject {
    var categories: [TrackerCategory] {get}
    var onCategoriesUpdate: (() -> Void)? {get set}
    var onCategorySelected: ((String) -> Void)? {get set}
    
    func loadCategories()
    func selectCategory(at index: Int)
    func createCategory(with title: String)
    
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
    
    func createCategory(with title: String) {
        do {
            _ = try categoryStore.createCategory(title: title)
            loadCategories()
        } catch {
            print("Неудалось создать категориюЖ \(error)")
        }
    }
}
