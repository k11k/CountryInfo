import UIKit
import RxSwift
import RxCocoa

class CountriesListViewController: BaseViewController {
    @IBOutlet weak var countriesTableView: UITableView!
    
    private let viewModel = CountriesListViewModel()
    private var tableItems: [AnyCellItemModel] = []
    private let selectedIndexPath = PublishSubject<IndexPath>()
    private var refreshHandler: RefreshHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        refreshHandler = RefreshHandler(view: countriesTableView)
        transform()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    private func transform() {
        
        let obtainCountriesTrigger = BehaviorSubject<Void>(value: ())
        let refreshTrigger = refreshHandler!.refresh
        
        let output = viewModel.transform(input: .init(obtainCountriesTrigger: Observable.merge(obtainCountriesTrigger,
                                                                                    refreshTrigger),
                                                      selectedCell: selectedIndexPath))
        
        output.items
            .drive(onNext: { [weak self] items in
                self?.tableItems = items
                self?.countriesTableView.reloadData()
            })
        .disposed(by: disposeBag)
        
        output.items
            .withLatestFrom(output.topSelectedRow) { $1 }
            .drive(onNext: { [weak self] index in
                self?.countriesTableView.scrollToRow(at: IndexPath(item: index, section: 0),
                                                at: .top,
                                                animated: true)
            })
        .disposed(by: disposeBag)
        
        output.selectedCoutryModel
            .subscribe(onNext: { [weak self] country in
                self?.presentCountryDetail(country: country)
            })
        .disposed(by: disposeBag)
        
        output
            .errors
            .drive(onNext: { [weak self] error in
                self?.handleError(error: error)
            })
            .disposed(by: disposeBag)
        
        output
            .activityTracker
            .drive(rx.isUILocked)
            .disposed(by: disposeBag)
        
        output
            .activityTracker
            .drive(
                onNext: { [weak self] _ in
                    self?.refreshHandler?.end()
                },
                onCompleted: { [weak self]  in
                    self?.refreshHandler?.end()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setupTableView() {
        countriesTableView.tableFooterView = UIView()
        countriesTableView.rowHeight = 100.0
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
    }
    
    private func setupUI() {
        title = "Список стран"
    }
}

extension CountriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       return tableView.dequeueReusableCell(withModel: tableItems[indexPath.row],
                                            for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableItems[indexPath.row].height
    }
}

extension CountriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.onNext(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Router
extension CountriesListViewController {
    func presentCountryDetail(country: CountryListCellModel) {
        let view = CountryDetailViewModule().view
        view.viewModel.setup(withCountry: country.countryModel)
        self.navigationController?.pushViewController(view, animated: true)
        title = ""
    }
}
