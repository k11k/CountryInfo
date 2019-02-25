import Foundation
import RxSwift
import Moya


class CountriesUseCase: BaseUseCase {
    let provider =  MoyaProvider<ObtainCountryApi> ()
    
    func getCountries() -> Single<Array<CountryResponse>> {
        return provider.rx.request(.obtainCountries())
            .flatMap(handleServiceError)
            .map(Array<CountryResponse>.self)
            .catchError(handleError)
    }
}
