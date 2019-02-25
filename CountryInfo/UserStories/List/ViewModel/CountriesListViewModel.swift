import Foundation
import RxSwift
import RxCocoa

class CountriesListViewModel: BaseViewModel {
    
    private let netService = CountriesUseCase()
    
    
    func transform(input: Input) -> Output {
        
        let errorTracker = self.errorTracker
        let activityTracker = self.activityTracker
        
        let countries = input.obtainCountriesTrigger
            .flatMapLatest { [weak self] _ -> Observable<Array<CountryResponse>> in
                guard let `self` = self else {
                    errorTracker.onError(Errors.SystemError.memoryLeak(methodName: "input.obtainCountriesTrigger"))
                    return Observable.of([])
                }
                return self.netService.getCountries()
                    .trackError(errorTracker)
                    .trackActivity(activityTracker)
                    .catchErrorJustReturn([])
            }
            .map { $0.map{ CountryListCellModel(countryModel: $0)} }
        
        let resultArray = PublishSubject<[AnyCellItemModel]>()
        countries
            .map { [weak self] countries -> [AnyCellItemModel] in
                guard let `self` = self else {
                    return []
                }
                return self.getUniqCharecters(countries: countries)
                    .map { CharacterCellModel(character: $0) }
        }
        .bind(to: resultArray)
        .disposed(by: disposeBag)
        
        let selectedCoutryModel = PublishSubject<CountryListCellModel>()
        let topRow = PublishSubject<Int>()
        input.selectedCell
            .withLatestFrom(countries) { ($0, $1) }
            .withLatestFrom(resultArray) { ($0, $1) }
            .map { [weak self] (arg0, resultArray) -> [AnyCellItemModel]? in
                guard let `self` = self else {
                    return []
                }
                let (indexPath, countries) = arg0
                
                // Открывать экран описания страны, если была нажата ячейка страны
                if let countrySelectedModel = resultArray[indexPath.row] as? CountryListCellModel  {
                    selectedCoutryModel.onNext(self.fillBordersCountries(country: countrySelectedModel,
                                                                         allCountries: countries))
                    return nil
                }
                
                // Вернуть массив с буквами и странами выбранной буквы
                if let letterSelectedModel = resultArray[indexPath.row] as? CharacterCellModel {
                    let result = self.getResultArray(selectedChar: letterSelectedModel.character,
                                                     coutries: countries)
                    topRow.onNext(self.getTopIndex(topModel: letterSelectedModel,
                                                   models: result))
                    return self.getResultArray(selectedChar: letterSelectedModel.character,
                                               coutries: countries)
                }
                
                return resultArray
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: resultArray)
            .disposed(by: disposeBag)
        
        return Output(items: resultArray.asDriver(onErrorJustReturn: []),
                      topSelectedRow: topRow.asDriver(onErrorJustReturn: 0),
                      selectedCoutryModel: selectedCoutryModel,
                      errors: errorTracker,
                      activityTracker: activityTracker)
    }
        
    private func getResultArray(selectedChar: String,
                        coutries: [CountryListCellModel]) -> [AnyCellItemModel] {
        let allChars = getUniqCharecters(countries: coutries)
        var result: [AnyCellItemModel] = allChars.map { CharacterCellModel(character: $0) }
        
        let indexSelectedChar = allChars.enumerated().filter { $0.element == selectedChar }.first?.offset
        let countries = getDictionaryOfCountries(countries: coutries)[selectedChar]
        
        guard let index = indexSelectedChar,
            let countriesOfCharacter = countries  else {
                return result
        }
        
        result.insert(contentsOf: countriesOfCharacter, at: index + 1)
        return result
    }
    
    private func getUniqCharecters(countries: [CountryListCellModel]) -> [String] {
        let charecters = countries
            .compactMap { $0.countryModel.name.first }
            .map { String($0) }
        return Array(Set(charecters))
            .sorted(by: < )
    }
    
    private func getDictionaryOfCountries(countries: [CountryListCellModel]) -> [String: [CountryListCellModel]] {
        var result = [String: [CountryListCellModel]] ()
        
        getUniqCharecters(countries: countries)
            .forEach { result[$0] = getArrayContriesForChar(countries: countries,
                                                            charecter: $0)
        }
        
        return result
    }
    
    private func getArrayContriesForChar(countries: [CountryListCellModel],
                                 charecter: String) -> [CountryListCellModel] {
        return  countries.filter { country -> Bool in
            guard let firstCharecter = country.countryModel.name.first else {
                return false
            }
            
            return String(firstCharecter) == charecter
        }
    }
    
    private func getTopIndex(topModel: AnyCellItemModel, models: [AnyCellItemModel]) -> Int {
        guard let topModel = topModel as? CharacterCellModel else { return 0 }
        let index = models.enumerated() .filter({ (arg0) -> Bool in
            let (_, model) = arg0
            return (model as? CharacterCellModel)?.character == topModel.character
        })
            .first
            .map({$0.offset})
        return index ?? 0
    }
    
    private func fillBordersCountries(country: CountryListCellModel,
                                      allCountries: [CountryListCellModel]) -> CountryListCellModel {
        guard let borders = country.countryModel.borders else { return country }
        let bordersCountriesNames = borders.compactMap { code -> String? in
            return allCountries.filter { $0.countryModel.alpha3Code == code }.first?.countryModel.name
        }
        country.countryModel.bordersCountries = bordersCountriesNames
        return country
    }
}


extension CountriesListViewModel {
    
    struct Input {
        let obtainCountriesTrigger: Observable<Void>
        let selectedCell: Observable<IndexPath>
    }
    
    struct Output {
        let items: Driver<[AnyCellItemModel]>
        let topSelectedRow: Driver<Int>
        let selectedCoutryModel: Observable<CountryListCellModel>
        let errors: ErrorTracker<CountryAppErrors>
        let activityTracker: ActivityTracker
    }
}
