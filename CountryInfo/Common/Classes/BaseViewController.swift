import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    typealias KeyboardInfo = (isShow: Bool, height: CGFloat, duration: Double)
    
    var storedClousure: [String: ((UIViewController) -> Void)?] = [:]
    var disposeBag = DisposeBag()
    let keyboardChange: BehaviorRelay<KeyboardInfo> = BehaviorRelay(value: (false, 0.0, 0.0))
    
    lazy var loaderView: LoaderView = LoaderView.instantiateFromXib()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loaderView.frame = self.view.bounds
    }
    
    fileprivate func lockUI() {
        self.view.addSubview(loaderView)
        loaderView.startAnimating()
    }
    
    fileprivate func unlockUI() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {[weak self] in
            self?.loaderView.stopAnimating {
                self?.loaderView.removeFromSuperview()
            }
        }
    }
    
    /// Дает стандартное поведение для экранов при получении ошибки
    func handleError(error: CountryAppErrors, retryHandler: EmptyHandler? = nil) {
        
        if let networkError = error as? Errors.Network,
            networkError == .noInternet {
            showErrorAlert(withError: error,
                           retryHandler: retryHandler)
            return
        }
        
        showErrorAlert(withError: error, retryHandler: nil)
    }
}

extension Reactive where Base: BaseViewController {
    var isUILocked: Binder<Bool> {
        return Binder(base) { base, isVisible in
            isVisible ? base.lockUI() : base.unlockUI()
        }
    }
}


extension BaseViewController {
    /// Show alert with retry action
    ///
    /// - Parameters:
    ///   - error: clevr type error
    func showErrorAlert(withError error: CountryAppErrors, retryHandler: EmptyHandler?) {
        var actions = [UIAlertAction]()
        actions.append(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let retryHandler = retryHandler {
            let retryAction = UIAlertAction(title: "RETRY", style: .default) { _ in
                retryHandler()
            }
            actions.append(retryAction)
        }
        presentMessage(message: error.errorDescription,
                       title: "Error",
                       actions: actions)
    }
    
    func showMessageAlert(message: String?, title: String?) {
        var actions = [UIAlertAction]()
        actions.append(UIAlertAction(title: "Ok", style: .default, handler: nil))
        presentMessage(message: message,
                       title: title,
                       actions: actions)
    }
    
    private func presentMessage(message: String?, title: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
}
