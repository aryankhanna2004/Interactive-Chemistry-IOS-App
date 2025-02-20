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


/// A fully balanced reaction that can consume multiple reactants and produce multiple products.
struct BalancedReaction {
    /// e.g. ["H₂": 2, "O₂": 1] for 2H₂ + O₂
    let reactants: [String: Int]
    
    /// e.g. ["H₂O": 2] for 2H₂O
    /// or multiple keys if the reaction yields more than one product, e.g. ["NaOH":1, "HCl":1].
    let products: [String: Int]
    
    /// A string for the balanced reaction, e.g. "2H₂ + O₂ → 2H₂O"
    let equationString: String
}


/// A chemical compound with extra fields for the Info Panel.
struct Compound: Identifiable, Equatable {
    let id = UUID()
    let formula: String
    let iupacName: String
    let commonName: String
    
    // Info Panel
    let reactionEquation: String?
    let commonUses: String?
    let funFact: String?
}


/// A central repository for known stoichiometric reactions.
@MainActor
final class ReactionRepository: ObservableObject {
    static let shared = ReactionRepository()
    
    /// Holds all known compounds by their formula string.
    /// Use this to look up the Compound object whenever you form a product.
    let compoundsByFormula: [String: Compound]
    
    /// A list of fully balanced, multi-product reactions.
    let balancedReactions: [BalancedReaction]
    
    private init() {
        
        // 1) Define all known compounds in a dictionary for easy lookup.
        var compoundDict: [String: Compound] = [:]
        
        // Basic H₂
        compoundDict["H₂"] = Compound(
            formula: "H₂",
            iupacName: "Dihydrogen",
            commonName: "Hydrogen Gas",
            reactionEquation: "2H → H₂",
            commonUses: "Used in fuel cells and rocket propulsion.",
            funFact: "Hydrogen is the most abundant element in the universe."
        )
        
        // Basic O₂
        compoundDict["O₂"] = Compound(
            formula: "O₂",
            iupacName: "Dioxygen",
            commonName: "Oxygen Gas",
            reactionEquation: "2O → O₂",
            commonUses: "Essential for respiration, steel-making, etc.",
            funFact: "Earth’s atmosphere is about 21% oxygen."
        )
        
        // Water H₂O
        compoundDict["H₂O"] = Compound(
            formula: "H₂O",
            iupacName: "Dihydrogen monoxide",
            commonName: "Water",
            reactionEquation: "2H + O → H₂O",
            commonUses: "Universal solvent, essential for life.",
            funFact: "About 60% of the human body is water."
        )
        
        // NaCl
        compoundDict["NaCl"] = Compound(
            formula: "NaCl",
            iupacName: "Sodium chloride",
            commonName: "Salt",
            reactionEquation: "Na + Cl → NaCl",
            commonUses: "Food seasoning, preservation.",
            funFact: "Salt was once so valuable it was used as currency!"
        )
        
        // Hydroxyl radical OH
        compoundDict["OH"] = Compound(
            formula: "OH",
            iupacName: "Hydroxyl",
            commonName: "Hydroxyl Radical",
            reactionEquation: "H + O → OH",
            commonUses: "Extremely reactive intermediate.",
            funFact: "Crucial for removing pollutants in the atmosphere."
        )
        
        // Sodium Hydroxide
        compoundDict["NaOH"] = Compound(
            formula: "NaOH",
            iupacName: "Sodium Hydroxide",
            commonName: "Caustic Soda (Lye)",
            reactionEquation: "NaCl + H₂O → ???",
            commonUses: "Paper production, soap making, etc.",
            funFact: "NaOH is a strong base that can saponify fats."
        )
        
        // Hydrogen Chloride
        compoundDict["HCl"] = Compound(
            formula: "HCl",
            iupacName: "Hydrogen Chloride",
            commonName: "Hydrochloric Acid (aqueous form)",
            reactionEquation: "NaCl + H₂O → ???",
            commonUses: "Digestive acid in stomach, many industrial uses.",
            funFact: "The stomach secretes HCl to help break down food."
        )
        compoundDict["Cl"] = Compound(
            formula: "Cl",
            iupacName: "Chlorine",
            commonName: "Chlorine Atom",
            reactionEquation: nil,
            commonUses: "Used in disinfectants and various chemical processes.",
            funFact: "Chlorine is a yellow-green gas at room temperature."
        )

        // Assign to our property
        compoundsByFormula = compoundDict
        
        
        // 2) Define fully balanced reactions.
        var reactions: [BalancedReaction] = []
        
        // (A) 2H -> H₂
        reactions.append(
            BalancedReaction(
                reactants: ["H": 2],
                products: ["H₂": 1],
                equationString: "2H → H₂"
            )
        )
        
        // (B) 2O -> O₂
        reactions.append(
            BalancedReaction(
                reactants: ["O": 2],
                products: ["O₂": 1],
                equationString: "2O → O₂"
            )
        )
        
        // (C) 2H + O -> H₂O
        reactions.append(
            BalancedReaction(
                reactants: ["H": 2, "O": 1],
                products: ["H₂O": 1],
                equationString: "2H + O → H₂O"
            )
        )
        
        // (D) Na + Cl -> NaCl
        reactions.append(
            BalancedReaction(
                reactants: ["Na": 1, "Cl": 1],
                products: ["NaCl": 1],
                equationString: "Na + Cl → NaCl"
            )
        )
        
        // (E) H + O -> OH
        reactions.append(
            BalancedReaction(
                reactants: ["H": 1, "O": 1],
                products: ["OH": 1],
                equationString: "H + O → OH"
            )
        )
        
        // (F) [UPDATED] NaCl + OH → NaOH + Cl
        // Previously was stored as a single product "NaOH + Cl", now it’s two separate products.
        reactions.append(
            BalancedReaction(
                reactants: ["NaCl": 1, "OH": 1],
                products: ["NaOH": 1, "Cl": 1],
                equationString: "NaCl + OH → NaOH + Cl"
            )
        )
        
        // (G) Multi-product example: NaCl + H₂O → NaOH + HCl
        // Not strictly correct in reality, but for demonstration
        reactions.append(
            BalancedReaction(
                reactants: ["NaCl": 1, "H₂O": 1],
                products: ["NaOH": 1, "HCl": 1],
                equationString: "NaCl + H₂O → NaOH + HCl"
            )
        )
        
        // (H) 2H₂ + O₂ → 2H₂O (molecular hydrogen + oxygen => water)
        reactions.append(
            BalancedReaction(
                reactants: ["H₂": 2, "O₂": 1],
                products: ["H₂O": 2],
                equationString: "2H₂ + O₂ → 2H₂O"
            )
        )
        
        // (I) OH + H → H₂O (radical recombination)
        reactions.append(
            BalancedReaction(
                reactants: ["OH": 1, "H": 1],
                products: ["H₂O": 1],
                equationString: "OH + H → H₂O"
            )
        )
        
        // (J) H + Cl → HCl
        reactions.append(
            BalancedReaction(
                reactants: ["H": 1, "Cl": 1],
                products: ["HCl": 1],
                equationString: "H + Cl → HCl"
            )
        )
        
        // (K) Neutralization: HCl + NaOH → NaCl + H₂O
        reactions.append(
            BalancedReaction(
                reactants: ["HCl": 1, "NaOH": 1],
                products: ["NaCl": 1, "H₂O": 1],
                equationString: "HCl + NaOH → NaCl + H₂O"
            )
        )
        
        // (L) Sodium + Water → Sodium Hydroxide + Hydrogen Gas
        // 2Na + 2H₂O → 2NaOH + H₂
        reactions.append(
            BalancedReaction(
                reactants: ["Na": 2, "H₂O": 2],
                products: ["NaOH": 2, "H₂": 1],
                equationString: "2Na + 2H₂O → 2NaOH + H₂"
            )
        )
        
        
        balancedReactions = reactions
    }
    
    /// Attempt to find a reaction that can fit entirely within the given stoich dictionary,
    /// returning (reaction, factor) if found.
    /// If multiple reactions match, it returns the first.
    ///
    /// The BFS approach in your code calls this repeatedly until none match or stoich is empty.
    func findReactionFactor(in symbols: [String: Int]) -> (BalancedReaction, Int)? {
        var applicableReactions: [(reaction: BalancedReaction, factor: Int)] = []
        
        // Check each reaction to see if it can run with the available counts.
        for reaction in balancedReactions {
            var possibleFactor = Int.max
            var isApplicable = true
            for (formula, neededCount) in reaction.reactants {
                guard let availableCount = symbols[formula] else {
                    isApplicable = false
                    break
                }
                possibleFactor = min(possibleFactor, availableCount / neededCount)
            }
            if isApplicable && possibleFactor > 0 {
                applicableReactions.append((reaction, possibleFactor))
            }
        }
        
        // If none of the reactions are possible, return nil.
        guard !applicableReactions.isEmpty else { return nil }
        
        // Choose the reaction that uses the most reactants (sum of counts).
        // For instance, if reaction A uses 2 atoms total and reaction B uses 3, pick reaction B.
        let chosen = applicableReactions.max { lhs, rhs in
            let lhsTotal = lhs.reaction.reactants.values.reduce(0, +)
            let rhsTotal = rhs.reaction.reactants.values.reduce(0, +)
            return lhsTotal < rhsTotal
        }
        
        return chosen
    }
}
