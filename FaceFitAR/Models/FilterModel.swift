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
    let iconName: String      // SF Symbol fallback
    let imageName: String?    // Custom asset image name
    let filterType: FilterType
    
    static let allFilters: [FilterModel] = [
        FilterModel(id: "none", name: "None", iconName: "face.dashed", imageName: nil, filterType: .none),
        FilterModel(id: "sunglasses", name: "Shades", iconName: "sunglasses.fill", imageName: "FilterSunglasses", filterType: .sunglasses),
        FilterModel(id: "devil", name: "Devil", iconName: "flame.fill", imageName: "FilterDevil", filterType: .devil),
        FilterModel(id: "crown", name: "Crown", iconName: "crown.fill", imageName: "FilterCrown", filterType: .crown),
        FilterModel(id: "mask", name: "Mask", iconName: "theatermasks.fill", imageName: "FilterMask", filterType: .mask)
    ]
}
