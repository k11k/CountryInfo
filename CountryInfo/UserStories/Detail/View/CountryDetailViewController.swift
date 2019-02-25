import UIKit

class CountryDetailViewController: BaseViewController {
    
    @IBOutlet weak var capitalNameLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var borderCountriesLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    let viewModel = CountryDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transform()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    func transform() {
        let output = viewModel.transform()
        output.countryModel
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [weak self] country in
                self?.updateUI(withCountry: country)
            })
        .disposed(by: disposeBag)
    }
    
    private func updateUI(withCountry country: CountryResponse) {
        title = country.name
        capitalNameLabel.text = country.capital
        populationLabel.text = String(country.population)
        let borderedContries = country.bordersCountries?.joined(separator: ", ")
        borderCountriesLabel.text = borderedContries != "" && borderedContries != nil ? borderedContries : "-"
        currencyLabel.text = country.currencies?.compactMap { $0.name }.joined(separator: ", ")
    }
}
