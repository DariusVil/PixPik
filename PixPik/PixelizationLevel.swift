enum PixelizationLevel: Int {
    
    case small
    case medium
    case large
    case extraLarge
    
    var intensity: Int {
        switch self {
        case .small: return 10
        case .medium: return 25
        case .large: return 50
        case .extraLarge: return 70
        }
    }
    
    var incrementedValue: PixelizationLevel {
        return PixelizationLevel(rawValue: self.rawValue + 1) ?? self
    }
    
    var decrementedValue: PixelizationLevel {
        return PixelizationLevel(rawValue: self.rawValue - 1) ?? self
    }
}
