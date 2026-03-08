import Foundation

enum FilterType: String, CaseIterable, Identifiable {
    case none
    case sunglasses
    case devil
    case crown
    case mask
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .sunglasses: return "Shades"
        case .devil: return "Devil"
        case .crown: return "Crown"
        case .mask: return "Mask"
        }
    }
}

struct FilterModel: Identifiable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let filterType: FilterType
    
    static let allFilters: [FilterModel] = [
        FilterModel(id: "none", name: "None", iconName: "face.dashed", filterType: .none),
        FilterModel(id: "sunglasses", name: "Shades", iconName: "sunglasses.fill", filterType: .sunglasses),
        FilterModel(id: "devil", name: "Devil", iconName: "flame.fill", filterType: .devil),
        FilterModel(id: "crown", name: "Crown", iconName: "crown.fill", filterType: .crown),
        FilterModel(id: "mask", name: "Mask", iconName: "theatermasks.fill", filterType: .mask)
    ]
}
