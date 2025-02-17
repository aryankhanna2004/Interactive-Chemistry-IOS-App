import SwiftUI

/// A stoichiometric reaction maps a dictionary of elementSymbol -> requiredCount
/// to one or more Compound products. (We can store multiple products if you like.)
struct StoichiometricReaction {
    let reactants: [String: Int]
    
    // For simplicity, we store only ONE product. If you want multiple, you can store [Compound].
    // Or store a dictionary of product -> count.
    let product: Compound
    
    /// A string for the balanced reaction. Example: "2H + O → H₂O"
    let equationString: String
}

/// A chemical compound with extra fields for the Info Panel.
struct Compound: Identifiable {
    let id = UUID()
    let formula: String
    let iupacName: String
    let commonName: String
    
    // For the Info Panel
    let reactionEquation: String?
    let commonUses: String?
    let funFact: String?
}

/// A central repository for known stoichiometric reactions.
@MainActor
final class ReactionRepository: ObservableObject {
    static let shared = ReactionRepository()
    
    private(set) var reactions: [StoichiometricReaction] = []
    
    private init() {
        // 1) 2H -> H2
        reactions.append(
            StoichiometricReaction(
                reactants: ["H": 2],
                product: Compound(
                    formula: "H₂",
                    iupacName: "Dihydrogen",
                    commonName: "Hydrogen Gas",
                    reactionEquation: "2H → H₂",
                    commonUses: "Used in fuel cells and rocket propulsion.",
                    funFact: "Hydrogen is the most abundant element in the universe."
                ),
                equationString: "2H → H₂"
            )
        )
        
        // 2) 2O -> O2
        reactions.append(
            StoichiometricReaction(
                reactants: ["O": 2],
                product: Compound(
                    formula: "O₂",
                    iupacName: "Dioxygen",
                    commonName: "Oxygen Gas",
                    reactionEquation: "2O → O₂",
                    commonUses: "Essential for respiration, steel-making, etc.",
                    funFact: "Earth’s atmosphere is about 21% oxygen."
                ),
                equationString: "2O → O₂"
            )
        )
        
        // 3) 2H + O -> H2O
        reactions.append(
            StoichiometricReaction(
                reactants: ["H": 2, "O": 1],
                product: Compound(
                    formula: "H₂O",
                    iupacName: "Dihydrogen monoxide",
                    commonName: "Water",
                    reactionEquation: "2H + O → H₂O",
                    commonUses: "Universal solvent, essential for life.",
                    funFact: "About 60% of the human body is water."
                ),
                equationString: "2H + O → H₂O"
            )
        )
        
        // 4) Na + Cl -> NaCl
        reactions.append(
            StoichiometricReaction(
                reactants: ["Na": 1, "Cl": 1],
                product: Compound(
                    formula: "NaCl",
                    iupacName: "Sodium chloride",
                    commonName: "Salt",
                    reactionEquation: "Na + Cl → NaCl",
                    commonUses: "Food seasoning, preservation.",
                    funFact: "Salt was once so valuable it was used as currency!"
                ),
                equationString: "Na + Cl → NaCl"
            )
        )
        
        // 5) H + O -> OH (Hydroxyl radical)
        reactions.append(
            StoichiometricReaction(
                reactants: ["H": 1, "O": 1],
                product: Compound(
                    formula: "OH",
                    iupacName: "Hydroxyl",
                    commonName: "Hydroxyl Radical",
                    reactionEquation: "H + O → OH",
                    commonUses: "Extremely reactive intermediate in many chemical reactions.",
                    funFact: "Hydroxyl radicals are crucial in atmospheric chemistry to remove pollutants."
                ),
                equationString: "H + O → OH"
            )
        )
        
        // 6) NaCl + OH -> NaOH + Cl (Simplified example)
        // Because we only store a single product, we’ll do a “fictional partial product”:
        reactions.append(
            StoichiometricReaction(
                reactants: ["NaCl": 1, "OH": 1],
                product: Compound(
                    formula: "NaOH + Cl",
                    iupacName: "Sodium Hydroxide + Chlorine",
                    commonName: "Simplified Reaction Mix",
                    reactionEquation: "NaCl + OH → NaOH + Cl",
                    commonUses: "Hypothetical mixture, demonstration only.",
                    funFact: "Not a perfectly balanced real-world reaction. For demonstration."
                ),
                equationString: "NaCl + OH → NaOH + Cl"
            )
        )
    }
    
    /// Returns (count, product) if a reaction is found as a *factor* of the input symbols.
    ///
    /// Example: If we have a reaction (2H + O -> H₂O), but the user placed 4H + 2O,
    /// we can produce 2 units of H₂O.
    ///
    /// This returns nil if no reaction is found at all.
    func findReactionFactor(in symbols: [String: Int]) -> (StoichiometricReaction, Int)? {
        for reaction in reactions {
            // We see how many times `reaction.reactants` can fit into `symbols`.
            // If all needed elements are in `symbols` with at least the required count, we have at least 1 factor.
            var possibleFactor = Int.max
            for (element, neededCount) in reaction.reactants {
                guard let availableCount = symbols[element] else {
                    possibleFactor = 0
                    break
                }
                let factorForThisElement = availableCount / neededCount
                if factorForThisElement < possibleFactor {
                    possibleFactor = factorForThisElement
                }
            }
            if possibleFactor > 0 && possibleFactor != Int.max {
                // means we can produce that reaction at least once
                return (reaction, possibleFactor)
            }
        }
        return nil
    }
}
