import SwiftUI

struct FilterSelectorView: View {
    @Binding var selectedFilter: FilterType
    var filters: [FilterModel] = FilterModel.allFilters
    var onFilterSelected: (FilterType) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(filters) { filter in
                    FilterItemView(
                        filter: filter,
                        isSelected: selectedFilter == filter.filterType
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            onFilterSelected(filter.filterType)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 12)
        )
    }
}

struct FilterItemView: View {
    let filter: FilterModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.theme.accent : Color.white.opacity(0.1))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.theme.accentLight : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                    
                    if let imageName = filter.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: filter.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(isSelected ? .white : Color.theme.textSecondary)
                    }
                }
                
                Text(filter.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Color.theme.textSecondary)
            }
        }
    }
}
