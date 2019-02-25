import Foundation
import RxSwift

protocol ItemModel: AnyCellItemModel {
    
    
    /// Тип ячейки, которую умеет настраивать модель
    associatedtype CellType: UITableViewCell
    /// Метод вызывать в дата сорсе
    ///
    /// - Parameters:
    ///   - tableView: таблица, в которой зарегистрирован возвращаемый тип ячейки
    ///   - indexPath: адрес ячейки
    /// - Returns: возвращает настроенную готовую ячейку
    func getReusableCell(tableView: UITableView, indexPath: IndexPath) -> CellType
    
    /// Метод настраивает ячейку. Необходимо переопределить
    ///
    /// - Parameter cell: ячейка
    func setupCell(cell: CellType)
}

extension ItemModel where CellType: Reusable {
    
    static var cellAnyType: UIView.Type {
        return CellType.self
    }
    
    func getReusableCell(tableView: UITableView, indexPath: IndexPath) -> CellType {
        let cell =  tableView.dequeueReusableCell(ofType: CellType.self, at: indexPath)
        setupCell(cell: cell)
        return cell
    }
    
    func setupAnyCell(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        setupCell(cell: cell)
    }
}


protocol AnyCellItemModel {
    static var cellAnyType: UIView.Type { get }
    func setupAnyCell(cell: UIView)
    var height: CGFloat { get }
}

