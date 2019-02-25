import Foundation
import RxSwift
import RxCocoa

class CountryDetailViewModel: BaseViewModel {
    
    let country = BehaviorSubject<CountryResponse?>(value: nil)
    
    func setup(withCountry country: CountryResponse) {
        self.country.onNext(country)
    }
    
    func transform() -> Output {
        return Output(countryModel: country)
    }
}

extension CountryDetailViewModel {
    
    struct Input {
    }
    
    struct Output {
        let countryModel: Observable<CountryResponse?>
    }
}
