import Foundation

public protocol CountryAppErrors: LocalizedError {
    var description: String? { get }
    var errorDescription: String? { get }
}

public enum Errors {
    
    /// Сетевые ошибки.
    public enum Network: CountryAppErrors {
        case noInternet
        case serverUnavailable
    }
    
    /// Сервер сообщил об ошибке в ответе запроса.
    public enum ServerError: CountryAppErrors {
        case error(code: Int, message: String)
        case requestLimitExceeded
        case unavailable
        case unknown
    }
    
    /// Прочие ошибки
    public enum SystemError: CountryAppErrors {
        case error(Error)
        case memoryLeak(methodName: String)
        case createUrlError(string: String)
        case unknown
    }
    
    /// Ошибки сериализации
    public enum Serialization: CountryAppErrors {
        case badResponse
        case unknown
    }
}

public extension CountryAppErrors {
    
    public var errorDescription: String? {
        return description
    }
}

extension Errors.Network {
    public var description: String? {
        switch self {
        case .noInternet:
            return "TTL_NO_INTERNET_CONNECTION"
        case .serverUnavailable:
            return "TTL_SERVER_UNAVAILABlE"
        }
    }
}

extension Errors.ServerError {
    public var description: String? {
        switch self {
        case .error( _, let message):
            return message
        case .unavailable:
            return "TTL_SERVER_ERROR_500"
        case .unknown:
            return "TTL_UNKNOWN_SERVER_ERROR"
        case .requestLimitExceeded:
            return "TTL_REQUEST_LIMIT_EXCEEDED"
        }
    }
}

/// Прочие ошибки
extension Errors.SystemError {
    public var description: String? {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .createUrlError(let string):
            return "\("TTL_ERROR_WHILE_CREATING_OBJECT_URL_FROM_ADDRESS") \(string)"
        case .unknown:
            return "TTL_UNKNOWN_SYSTEM_ERROR"
        case .memoryLeak(let methodName):
            return "TTL_MEMORY_LEAK_IN_METHOD" + " \(methodName)"
        }
    }
}

///  Ошибки серрилизации
extension Errors.Serialization {
    public var description: String? {
        switch self {
        case .badResponse:
            return "TTL_SERIALIZATION_ERROR"
        case .unknown:
            return "TTL_UNKNOWN_SERVER_ERROR"
        }
    }
}
