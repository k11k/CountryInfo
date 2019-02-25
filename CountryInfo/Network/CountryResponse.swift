import Foundation

struct CountryResponse: Codable {
    let name: String
    let alpha3Code: String?
    let capital: String?
    let population: Int
    let borders: [String]?
    let currencies: [Currency]?
    var bordersCountries: [String]?
}

struct Currency: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}
