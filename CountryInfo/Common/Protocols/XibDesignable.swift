import UIKit

protocol XibDesignable: class {}

extension XibDesignable where Self: UIView {
    
    static func instantiateFromXib() -> Self {
        
        let dynamicMetatype = Self.self
        let bundle = Bundle(for: dynamicMetatype)
        let nib = UINib(nibName: "\(dynamicMetatype)", bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: dynamicMetatype, options: nil).first as? Self else {
            fatalError("Could not instantiate view from nib file.")
        }
        return view
    }
    
    func loadViewFromXib() {
        guard let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last else { return }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Could not load view from nib file.")
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
}

extension UIView: XibDesignable { }

extension XibDesignable where Self: UIViewController {
    
    static func instantiateFromXib() -> Self {
        
        let dynamicMetatype = Self.self
        let bundle = Bundle(for: dynamicMetatype)
        let name = "\(dynamicMetatype)"
        
        return Self(nibName: name, bundle: bundle)
    }
}

extension UIViewController: XibDesignable {}
