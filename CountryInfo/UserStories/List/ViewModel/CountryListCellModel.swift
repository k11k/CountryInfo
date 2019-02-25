import UIKit

class CountryListCellModel: ItemModel {
    static func == (left: CountryListCellModel, right: CountryListCellModel) -> Bool {
        return left.countryModel.name == right.countryModel.name
    }
    
    var height: CGFloat {
        return 100
    }
    typealias CellType = CountryCell
    
    var countryModel: CountryResponse
    
    init(countryModel: CountryResponse) {
        self.countryModel = countryModel
    }
    
    func setupCell(cell: CountryCell) {
        cell.nameLabel?.text = countryModel.name
        cell.populationLabel?.text = String(countryModel.population)
    }
}

extension UITableViewCell: Reusable { }
