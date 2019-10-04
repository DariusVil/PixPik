enum PixelizationLevel: Int {
    
    case small
    case medium
    case large
    
    var intensity: Int {
        switch self {
        case .small: return 10
        case .medium: return 20
        case .large: return 30
        }
    }
    
    var incrementedValue: PixelizationLevel {
        return PixelizationLevel(rawValue: self.rawValue + 1) ?? self
    }
    
    var decrementedValue: PixelizationLevel {
        return PixelizationLevel(rawValue: self.rawValue - 1) ?? self
    }
}