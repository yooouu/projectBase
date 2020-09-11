enum LocalizedKeySet: String {
    case confirm
    case cancel
    
    var localized: String {
        return String(describing: self).localized
    }
}
