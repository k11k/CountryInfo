import UIKit

extension UITableView {
    
    /// Регистрирует класс ячейки для использования в `UITableView`
    ///
    /// - Parameter cellType: Тип ячейки, которая реализует протокол `Reusable`
    func registerCellClass<T: Reusable>(_ cellType: T.Type) where T: UITableViewCell {
        register(cellType, forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// Регистрирует nib файл ячейки для использования в `UITableView`
    ///
    /// - Parameter cellType: Тип ячейки, которая реализует протокол `Reusable`
    func registerCellNib<T: Reusable>(_ cellType: T.Type) where T: UITableViewCell {
        let nib = UINib(nibName: cellType.reuseID, bundle: nil)
        register(nib, forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// Возвращает экземпляр переиспользуемой ячейки по ее типу.
    ///
    /// - Parameters:
    ///   - cellType: Тип ячейки (должна реализовывать протокол Reusable).
    ///   - indexPath: Index path.
    /// - Returns: Экземпляр ячейки.
    func dequeueReusableCell<T: Reusable>(ofType cellType: T.Type,
                                          at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID, for: indexPath) as? T else {
            fatalError("❌ Не удалось найти ячейку с идентификатором \(cellType.reuseID)!")
        }
        return cell
    }
    
}

extension UITableView {
    func dequeueReusableCell (withModel model: AnyCellItemModel, for indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: type(of: model).cellAnyType)
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        model.setupAnyCell(cell: cell)
        return cell
    }
    
    func reigister(nibModels: [AnyCellItemModel.Type]) {
        for model in nibModels {
            let identifier = String(describing: model.cellAnyType)
            let nib = UINib(nibName: identifier, bundle: nil)
            self.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
}
