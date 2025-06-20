import UIKit

final class CreateRegularTrackerViewController: BaseTrackerViewController {
    override var isRegular: Bool { return true }
        override var isEditingMode: Bool { return false } // Только создание
    }
