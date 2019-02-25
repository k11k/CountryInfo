import UIKit

struct CharacterCellModel: ItemModel {
    static func == (left: CharacterCellModel, right: CharacterCellModel) -> Bool {
        return left.character == right.character
    }
    
    var height: CGFloat {
        return 50
    }
    
    typealias CellType = CharacterCell
    
    let character: String
    
    init(character: String) {
        self.character = character
    }
    
    func setupCell(cell: CharacterCell) {
        cell.character.text = character
    }
}
