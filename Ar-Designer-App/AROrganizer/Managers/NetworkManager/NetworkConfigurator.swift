//
//  NetworkConfigurator.swift
//

import Foundation

enum Environment: String {
    case prod
    case stage
    case develop
}

enum NetworkBaseURLs {
    static var environment: String {
        switch NetworkConfigurator.environmentType {
        case .develop:      return "https://www.tstpreview.containerstore.com"
        case .stage:        return "https://ar-designer-services.devpreview.containerstore.com"
        case .prod:         return "https://www.containerstore.com"
        }
    }
    
    static var subEnvironment: String {
        switch NetworkConfigurator.environmentType {
        case .develop:      return "https://www.tstpreview.containerstore.com"
        case .stage:        return "https://ar-designer-services.devpreview.containerstore.com"
        case .prod:         return "https://www.containerstore.com"
        }
    }
}

struct NetworkConfigurator {
    static let baseServerURL: String = NetworkBaseURLs.environment
    static var environmentType: Environment {
        guard
            let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let result = try? PropertyListDecoder().decode(EnvironmentModel.self, from: data).type
        else { return .develop }
        
        return result
    }
}

// MARK: - Info list
struct EnvironmentModel: Decodable {
    let type: Environment
    
    enum CodingKeys: String, CodingKey {
        case environment = "Environment"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let environment = try container.decodeIfPresent(String.self, forKey: .environment) ?? ""
        self.type = Environment(rawValue: environment) ?? .develop
    }
}
