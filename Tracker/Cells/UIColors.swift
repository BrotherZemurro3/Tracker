
import UIKit

final class UIColors {
    
    static let shared = UIColors()
    
    private init() {}
    
    
    // MARK: - Системный бек
    let viewBackgroundColor = UIColor.systemBackground
    let labelColor = UIColor.label
    let secondaryLabelColor = UIColor.secondaryLabel
    
    // MARK: - Button Colors
    
    var adaptiveButtonBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    var adaptiveButtonText: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }
    
    
}
