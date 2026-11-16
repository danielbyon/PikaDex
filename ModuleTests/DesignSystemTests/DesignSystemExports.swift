import DesignSystem

// This file deliberately imports only DesignSystem to check its public exports.
func exportedDomainValues() -> (Date, Game) { (Date(timeIntervalSince1970: 0), .national) }
