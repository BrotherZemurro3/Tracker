import Foundation

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String)
    func didUpdateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?)
}
