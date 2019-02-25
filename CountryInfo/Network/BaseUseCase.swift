import Foundation
import RxSwift
import Moya

protocol BaseUseCase {
    
    /// Десериализует ошибку сервера. В случае успеха возвращает ошибку `.serverError(message)`,
    /// иначе возврощает response
    func handleServiceError(response: Response) -> Single<Response>
    /// Преобразовывает пойманную ошибку в ошибку типа `Domain.Error`.
    func handleError<T>(error: Swift.Error) -> Single<T>
}


extension BaseUseCase {
    
    func handleServiceError(response: Response) -> Single<Response> {
        let statusCode = response.statusCode
        
        switch statusCode {
        case 200, 201:
            return Single.just(response)
        case 400:
            let decoder = JSONDecoder()
            if let commonError = try? decoder.decode(ServerError.self, from: response.data) {
                return Single.error(commonError.currentError())
            }
            return Single.error(Errors.ServerError.unknown)
        default:
            return Single.error(Errors.ServerError.unknown)
        }
    }
    
    func handleError<T>(error: Swift.Error) -> Single<T> {
        switch error {
        case MoyaError.encodableMapping, MoyaError.objectMapping, MoyaError.jsonMapping, MoyaError.stringMapping:
            return Single.error(Errors.Serialization.badResponse)
        case MoyaError.underlying(let error, _):
            if (error as NSError).domain == NSURLErrorDomain {
                return Single.error(Errors.Network.noInternet)
            }
            return Single.error(Errors.SystemError.error(error))
        default:
            return Single.error(error)
        }
    }
}

/// Common error
struct ServerError: Codable {
    let code: Int
    let error: String
}

extension ServerError {
    /// Преобразуем серверную ошибку в Domain ошибку
    func currentError() -> Error {
        return Errors.ServerError.error(code: code, message: error)
    }
}
