
import UIKit

final class Colors {
    
    static let shared = Colors()
    
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
