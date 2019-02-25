import UIKit
import RxSwift

class BaseViewModel {
    let disposeBag = DisposeBag()
    let activityTracker = ActivityTracker()
    let errorTracker = ErrorTracker<CountryAppErrors>()
}
