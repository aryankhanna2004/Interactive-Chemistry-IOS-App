import SwiftUI
import AudioToolbox
import UIKit

struct GuidedLesson {
    let title: String
    let hint: String
}

struct Element: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    
    // We default all built-in elements to blue; newly discovered become purple.
    var color: Color = .blue
}

/// An element placed in the workspace, with a position on the canvas.
struct PlacedElement: Identifiable {
    let id = UUID()
    let element: Element
    var position: CGPoint
}

/// A compound placed in the workspace, storing the constituent elements.
struct PlacedCompound: Identifiable {
    let id = UUID()
    let compound: Compound
    var position: CGPoint
    let constituentElements: [PlacedElement]
}

/// The main view model controlling the workspace.
@MainActor
class WorkspaceViewModel: ObservableObject {
    @Published var placedElements: [PlacedElement] = []
    @Published var placedCompounds: [PlacedCompound] = []
    
    // New dynamic list for the side panel.
    @Published var availableElements: [Element] = [
        Element(symbol: "H",  name: "Hydrogen", color: .blue),
        Element(symbol: "O",  name: "Oxygen",   color: .blue),
        Element(symbol: "Na", name: "Sodium",   color: .blue),
        Element(symbol: "Cl", name: "Chlorine", color: .blue)
    ]

    
    // Gamification & Discovery
    @Published var discoveredCompounds: Set<String> = []
    @Published var newlyDiscoveredCompound: Compound? = nil
    
    // Info Panel
    @Published var showInfoPanel: Bool = false
    @Published var infoPanelCompound: Compound? = nil
    
    // Reaction History
    @Published var reactionHistory: [Compound] = []
    
    // Badges
    @Published var unlockedBadges: [String] = []
    
    // Guided Learning
    @Published var guidedLearningMode: Bool = false
    @Published var currentGuidedLesson: GuidedLesson? = nil
    
    // Canvas constants
    let elementSize: CGFloat = 70
    let clusterThreshold: CGFloat = 50
    
    // MARK: - Add Element & Check Reactions
    func addElement(_ element: Element, at position: CGPoint) {
        placedElements.append(PlacedElement(element: element, position: position))
        checkForReactions()
    }
    
    /// Group elements into clusters and attempt to apply any matching balanced reaction.
    func checkForReactions() {
        // Build clusters from both placed elements and compounds
        let clusters = buildClusters(fromElements: placedElements,
                                     andCompounds: placedCompounds,
                                     threshold: clusterThreshold)
        
        for cluster in clusters {
            // Only attempt reactions if there are at least two items.
            if cluster.count < 2 { continue }
            
            // Build a stoichiometry dictionary for the cluster, e.g. ["H": 4, "O": 2]
            var stoich = cluster.reduce(into: [String: Int]()) { dict, item in
                dict[item.symbol, default: 0] += 1
            }
            
            // Set to record exactly which items (by ID) are consumed by reactions.
            var clusterConsumedIDs = Set<UUID>()
            
            // Repeatedly check for any reaction that fits the current stoichiometry.
            while let (reaction, factor) = ReactionRepository.shared.findReactionFactor(in: stoich), factor > 0 {
                // Calculate the cluster’s average position.
                let (avgX, avgY) = cluster.reduce((0.0, 0.0)) { (running, item) in
                    (running.0 + item.position.x, running.1 + item.position.y)
                }
                let centerX = avgX / CGFloat(cluster.count)
                let centerY = avgY / CGFloat(cluster.count)
                
                // Process each instance of the reaction.
                for _ in 0..<factor {
                    // For this reaction instance, determine which items will be consumed.
                    var instanceConsumedIDs = Set<UUID>()
                    
                    for (symbol, neededCount) in reaction.reactants {
                        // Find available items in the cluster matching this reactant
                        let availableItems = cluster.filter {
                            $0.symbol == symbol &&
                            !clusterConsumedIDs.contains($0.id) &&
                            !instanceConsumedIDs.contains($0.id)
                        }
                        // Only if we have enough items, mark them as consumed.
                        if availableItems.count >= neededCount {
                            for i in 0..<neededCount {
                                instanceConsumedIDs.insert(availableItems[i].id)
                            }
                        }
                    }
                    // Add these consumed IDs to the overall set for the cluster.
                    clusterConsumedIDs.formUnion(instanceConsumedIDs)
                    
                    // Create products with a slight offset so they don't overlap.
                    for (productFormula, productCount) in reaction.products {
                        guard let productCompound = ReactionRepository.shared.compoundsByFormula[productFormula] else { continue }
                        
                        let angleIncrement = 360.0 / CGFloat(productCount)
                        for i in 0..<productCount {
                            let angle = angleIncrement * CGFloat(i)
                            let offsetRadius: CGFloat = 20
                            let dx = offsetRadius * cos(angle * .pi / 180)
                            let dy = offsetRadius * sin(angle * .pi / 180)
                            
                            let newCompound = PlacedCompound(
                                compound: productCompound,
                                position: CGPoint(x: centerX + dx, y: centerY + dy),
                                constituentElements: []  // Optionally store consumed items if needed
                            )
                            // Add the new compound.
                            withAnimation {
                                placedCompounds.append(newCompound)
                            }
                            
                            // Handle discovery and other side effects.
                            registerDiscovery(of: productCompound)
                            reactionHistory.append(productCompound)
                            displayInfoPanel(for: productCompound)
                            checkBadges(for: productCompound)
                            playReactionSoundAndHaptics()
                        }
                    }
                }
                
                // Update the stoichiometry dictionary by subtracting the counts used.
                for (symbol, neededCount) in reaction.reactants {
                    stoich[symbol]! -= (neededCount * factor)
                    if stoich[symbol]! <= 0 {
                        stoich[symbol] = nil
                    }
                }
            }
            
            // Remove only the consumed items from placedElements and placedCompounds.
            placedElements.removeAll { clusterConsumedIDs.contains($0.id) }
            placedCompounds.removeAll { clusterConsumedIDs.contains($0.id) }
        }
    }


    
    /// Returns all product compounds from any reaction whose reactants include the given element.
    func possibleReactionsStartingWith(_ element: Element) -> [Compound] {
        var results = [Compound]()
        for reaction in ReactionRepository.shared.balancedReactions {
            if reaction.reactants.keys.contains(element.symbol) {
                // Add all products from this reaction.
                for productFormula in reaction.products.keys {
                    if let productCompound = ReactionRepository.shared.compoundsByFormula[productFormula] {
                        results.append(productCompound)
                    }
                }
            }
        }
        return results
    }
    
    // MARK: - Display Compound Info
    private func displayInfoPanel(for compound: Compound) {
        infoPanelCompound = compound
        showInfoPanel = true
    }
    
    // MARK: - Break Compound
    func breakCompound(_ compound: PlacedCompound) {
        withAnimation {
            // Break the compound back into its constituent elements, nudging their positions.
            for oldElement in compound.constituentElements {
                var newEl = oldElement
                newEl.position = CGPoint(
                    x: compound.position.x + CGFloat.random(in: -20...20),
                    y: compound.position.y + CGFloat.random(in: -20...20)
                )
                placedElements.append(newEl)
            }
            placedCompounds.removeAll { $0.id == compound.id }
        }
    }
    
    // MARK: - Tap on Compound to Show Info
    func selectCompound(_ compound: Compound) {
        withAnimation {
            infoPanelCompound = compound
            showInfoPanel = true
        }
    }
    
    // MARK: - Close Info Panel
    func closeInfoPanel() {
        withAnimation {
            showInfoPanel = false
            infoPanelCompound = nil
        }
    }
    
    // MARK: - Helper: Discovery & Badges
    private func registerDiscovery(of compound: Compound) {
        if !discoveredCompounds.contains(compound.formula) {
            discoveredCompounds.insert(compound.formula)
            newlyDiscoveredCompound = compound
            
            // Add the newly discovered compound to the side panel as an available element if not present.
            if !availableElements.contains(where: { $0.symbol == compound.formula }) {
                let newElement = Element(symbol: compound.formula,
                                         name: compound.commonName,
                                         color: .purple)  // <-- Purple for discovered
                availableElements.append(newElement)
                playReactionSoundAndHaptics()
            }
        }
    }

    private func checkBadges(for compound: Compound) {
        // Existing badge: Salt Master
        
        if compound.commonName.lowercased().contains("salt") {
            let saltCount = reactionHistory.filter { $0.commonName.lowercased().contains("salt") }.count
            if saltCount >= 3, !unlockedBadges.contains("Salt Master") {
                unlockedBadges.append("Salt Master")
            }
        }
        
        // New badge: Water Wizard (for H₂O)
        if compound.formula == "H₂O" {
            let waterCount = reactionHistory.filter { $0.formula == "H₂O" }.count
            if waterCount >= 3, !unlockedBadges.contains("Water Wizard") {
                unlockedBadges.append("Water Wizard")
            }
        }
        
        // New badge: Oxidation Expert (for O₂)
        if compound.formula == "O₂" {
            let oxygenCount = reactionHistory.filter { $0.formula == "O₂" }.count
            if oxygenCount >= 2, !unlockedBadges.contains("Oxidation Expert") {
                unlockedBadges.append("Oxidation Expert")
            }
        }
        
        // New badge: Hydrogen Hero (for H₂)
        if compound.formula == "H₂" {
            let hydrogenCount = reactionHistory.filter { $0.formula == "H₂" }.count
            if hydrogenCount >= 2, !unlockedBadges.contains("Hydrogen Hero") {
                unlockedBadges.append("Hydrogen Hero")
            }
        }
        
        // New badge: Compound Collector (discovered compounds count reaches 5)
        if discoveredCompounds.count >= 5, !unlockedBadges.contains("Compound Collector") {
            unlockedBadges.append("Compound Collector")
        }
    }

    
    private func playReactionSoundAndHaptics() {
        // Play a system sound (1104 is a common "Tink" sound)
        AudioServicesPlaySystemSound(1104)
        
        // Trigger a success haptic notification
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}


/// A BFS-based clustering approach to group nearby placed elements.
/// A unified "reactive item" that BFS can cluster.
struct ReactiveItem: Identifiable {
    let id: UUID
    let symbol: String
    var position: CGPoint
}

/// Build clusters from both placed elements and placed compounds.
func buildClusters(
    fromElements elements: [PlacedElement],
    andCompounds compounds: [PlacedCompound],
    threshold: CGFloat
) -> [[ReactiveItem]] {
    
    // 1) Convert PlacedElement -> ReactiveItem
    let elementItems = elements.map { placed -> ReactiveItem in
        ReactiveItem(id: placed.id,
                     symbol: placed.element.symbol,  // e.g. "H" or "Na"
                     position: placed.position)
    }
    // 2) Convert PlacedCompound -> ReactiveItem
    let compoundItems = compounds.map { placed -> ReactiveItem in
        ReactiveItem(id: placed.id,
                     symbol: placed.compound.formula, // e.g. "H₂O"
                     position: placed.position)
    }
    
    // Combine them
    let allItems = elementItems + compoundItems
    
    // BFS over allItems
    var visited = Set<UUID>()
    var clusters: [[ReactiveItem]] = []
    
    func bfs(start: ReactiveItem, all: [ReactiveItem]) -> [ReactiveItem] {
        var queue = [start]
        var group: [ReactiveItem] = []
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if visited.contains(current.id) { continue }
            visited.insert(current.id)
            group.append(current)
            
            for candidate in all where !visited.contains(candidate.id) {
                let distance = hypot(candidate.position.x - current.position.x,
                                     candidate.position.y - current.position.y)
                if distance <= threshold {
                    queue.append(candidate)
                }
            }
        }
        return group
    }
    
    for item in allItems {
        if !visited.contains(item.id) {
            let group = bfs(start: item, all: allItems)
            clusters.append(group)
        }
    }
    
    return clusters
}
