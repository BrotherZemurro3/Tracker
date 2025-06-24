import Foundation
import YandexMobileMetrica


final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "1cc9ed79-6d5b-4538-90bd-b13e0303dd78") else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }

        YMMYandexMetrica.reportEvent("AnalyticsEvent", parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        print("Analytics Event: \(params)")
    }
}
