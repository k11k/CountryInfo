import Foundation
import Moya

enum ObtainCountryApi {
    case obtainCountries()
}

extension ObtainCountryApi: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://restcountries.eu/rest/v2/")!
    }
    
    var path: String {
        switch self {
        case .obtainCountries():
            return "all"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return Task.requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
