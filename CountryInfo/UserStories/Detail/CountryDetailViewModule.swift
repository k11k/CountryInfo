import UIKit

class CountryDetailViewModule: NSObject {
    private var viewController: CountryDetailViewController?
    var view: CountryDetailViewController {
        guard let view = viewController else {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            guard
                let viewController = storyBoard.instantiateViewController(withIdentifier: "CountryDetailViewController") as? CountryDetailViewController
                else {
                    return CountryDetailViewController()
            }
            
            self.viewController = viewController
            return viewController
        }
        return view
    }
}
