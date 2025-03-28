import SwiftUI
import AudioToolbox
import UIKit

struct GuidedLesson {
    let title: String
    let hint: String
}

struct Element: Identifiable,Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    var color: Color = .blue
}

struct PlacedElement: Identifiable, Equatable {
    let id = UUID()
    let element: Element
    var position: CGPoint
}

struct PlacedCompound: Identifiable,Equatable {
    let id = UUID()
    let compound: Compound
    var position: CGPoint
    let constituentElements: [PlacedElement]
}


@MainActor
class WorkspaceViewModel: ObservableObject {
    @Published var placedElements: [PlacedElement] = []
    @Published var placedCompounds: [PlacedCompound] = []
    
    // For guided lesson outcome tracking.
    @Published var currentGuidedLessonModule: LessonModule? = nil
    @Published var guidedOutcomeProducts: Set<String> = []
    @Published var guidedPlaygroundCompleted: Bool = false
    
    // NEW: Track quiz completion (only trigger overlay once).
    @Published var quizCompleted: Bool = false

    // Side panel elements.
    @Published var availableElements: [Element] = [
        Element(symbol: "H", name: "Hydrogen", color: .blue),
        Element(symbol: "O", name: "Oxygen", color: .blue),
        Element(symbol: "Na", name: "Sodium", color: .blue),
        Element(symbol: "Cl", name: "Chlorine", color: .blue)
    ]
    
    // Discovery, Info Panel, Reaction History, Badges, and Guided Lesson.
    @Published var discoveredCompounds: Set<String> = []
    @Published var newlyDiscoveredCompound: Compound? = nil
    @Published var showInfoPanel: Bool = false
    @Published var infoPanelCompound: Compound? = nil
    @Published var reactionHistory: [Compound] = []
    @Published var unlockedBadges: [String] = []
    @Published var guidedLearningMode: Bool = false
    @Published var currentGuidedLesson: GuidedLesson? = nil
    @Published var completedLessons: Set<UUID> = []
    @Published var lessonProgress: [UUID: Double] = [:]
    
    // NEW: A recommendation hint to help the user.
    @Published var reactionHint: String? = nil
    
    // Canvas constants.
    let elementSize: CGFloat = 70
    let clusterThreshold: CGFloat = 70
    
    // MARK: - Add Element & Check Reactions
    
    func addElement(_ element: Element, at position: CGPoint) {
        placedElements.append(PlacedElement(element: element, position: position))
        checkForReactions()
    }
    
    func checkForReactions() {
        // Run the clustering & reaction detection algorithm.
        let clusters = buildClusters(fromElements: placedElements, andCompounds: placedCompounds, threshold: clusterThreshold)
        
        for cluster in clusters {
            if cluster.count < 2 { continue }
            
            var stoich = cluster.reduce(into: [String: Int]()) { dict, item in
                dict[item.symbol, default: 0] += 1
            }
            
            var clusterConsumedIDs = Set<UUID>()
            
            while let (reaction, factor) = ReactionRepository.shared.findReactionFactor(in: stoich), factor > 0 {
                let (avgX, avgY) = cluster.reduce((0.0, 0.0)) { (running, item) in
                    (running.0 + item.position.x, running.1 + item.position.y)
                }
                let centerX = avgX / CGFloat(cluster.count)
                let centerY = avgY / CGFloat(cluster.count)
                
                for _ in 0..<factor {
                    var instanceConsumedIDs = Set<UUID>()
                    
                    for (symbol, neededCount) in reaction.reactants {
                        let availableItems = cluster.filter {
                            $0.symbol == symbol &&
                            !clusterConsumedIDs.contains($0.id) &&
                            !instanceConsumedIDs.contains($0.id)
                        }
                        if availableItems.count >= neededCount {
                            for i in 0..<neededCount {
                                instanceConsumedIDs.insert(availableItems[i].id)
                            }
                        }
                    }
                    clusterConsumedIDs.formUnion(instanceConsumedIDs)
                    
                    // Calculate the total number of product instances
                    let totalProducts = reaction.products.reduce(0) { $0 + $1.value }
                    var globalIndex = 0

                    for (productFormula, productCount) in reaction.products {
                        guard let productCompound = ReactionRepository.shared.compoundsByFormula[productFormula] else { continue }
                        
                        // Process each instance of the product
                        for _ in 0..<productCount {
                            // Use the global index and total count to calculate spacing
                            let angleIncrement = 360.0 / CGFloat(totalProducts)
                            let baseRadius: CGFloat = 20
                            // Using globalIndex to add incremental spacing for each product instance
                            let extraSpacing: CGFloat = 5 * CGFloat(globalIndex)
                            let offsetRadius = baseRadius + extraSpacing
                            
                            let angle = angleIncrement * CGFloat(globalIndex)
                            let dx = offsetRadius * cos(angle * .pi / 180)
                            let dy = offsetRadius * sin(angle * .pi / 180)
                            
                            let newCompound = PlacedCompound(
                                compound: productCompound,
                                position: CGPoint(x: centerX + dx, y: centerY + dy),
                                constituentElements: []
                            )
                            
                            withAnimation {
                                placedCompounds.append(newCompound)
                            }
                            
                            // Register discovery and side effects.
                            registerDiscovery(of: productCompound)
                            reactionHistory.append(productCompound)
                            playReactionSoundAndHaptics()
                            
                            // Guided learning outcome check (only if lesson is not yet 100% complete)
                            if guidedLearningMode,
                               let lessonModule = currentGuidedLessonModule,
                               let outcomeGoals = lessonModule.guidedOutcomeGoals,
                               guidedPlaygroundCompleted == false {
                                if outcomeGoals.contains(productCompound.formula) {
                                    guidedOutcomeProducts.insert(productCompound.formula)
                                    if guidedOutcomeProducts.count >= outcomeGoals.count {
                                        guidedPlaygroundCompleted = true
                                    }
                                }
                            } else {
                                checkBadges(for: productCompound)
                            }
                            
                            globalIndex += 1
                        }
                    }



                }
                
                for (symbol, neededCount) in reaction.reactants {
                    stoich[symbol]! -= (neededCount * factor)
                    if stoich[symbol]! <= 0 {
                        stoich[symbol] = nil
                    }
                }
            }
            
            placedElements.removeAll { clusterConsumedIDs.contains($0.id) }
            placedCompounds.removeAll { clusterConsumedIDs.contains($0.id) }
        }
        
        // After processing reactions, run our recommendation algorithm.
        recommendReactionHint()
    }
    
    /// Check free elements on the canvas and set a hint if a reaction is nearly possible.
    func recommendReactionHint() {
        // Reset previous hint.
        reactionHint = nil
        
        // Count free elements (those not in compounds).
        var counts: [String: Int] = [:]
        for placed in placedElements {
            counts[placed.element.symbol, default: 0] += 1
        }
        
        // Example: Recommend water (H₂O) formation.
        // Reaction: 2 H + O -> H₂O
        if let hCount = counts["H"], let oCount = counts["O"] {
            if hCount >= 2 && oCount >= 1 && !reactionHistory.contains(where: { $0.formula == "H₂O" }) {
                reactionHint = "Try combining two hydrogen atoms and one oxygen atom to form water (H₂O)."
                return
            }
        }
        
        // --- Alternative ideas (not implemented) ---
        // 1. If there are H₂ molecules and O₂ molecules nearby, recommend combining 2 H₂ + O₂ -> 2 H₂O.
        // 2. If an OH radical is almost formed, recommend combining an H atom with an OH radical to form water.
        // 3. If a cluster has one O atom but only one H atom, recommend: "Add one more hydrogen atom."
        // 4. If a cluster has excess H atoms, recommend adding an oxygen atom to balance the reaction.
        // 5. Provide a panel listing balanced reactions (e.g., 2 H₂ + O₂ -> 2 H₂O) as a guideline.
        // ------------------------------------------------
    }
    
    func possibleReactionsStartingWith(_ element: Element) -> [Compound] {
        var results = [Compound]()
        for reaction in ReactionRepository.shared.balancedReactions {
            if reaction.reactants.keys.contains(element.symbol) {
                for productFormula in reaction.products.keys {
                    if let productCompound = ReactionRepository.shared.compoundsByFormula[productFormula] {
                        results.append(productCompound)
                    }
                }
            }
        }
        return results
    }
    
    // MARK: - Info Panel & Breaking Compounds
    
    private func displayInfoPanel(for compound: Compound) {
        print("Displaying info panel for: \(compound.formula)")
        infoPanelCompound = compound
        showInfoPanel = true
    }
    
    func breakCompound(_ compound: PlacedCompound) {
        withAnimation {
            var restoredElements: [PlacedElement] = []
            
            for oldElement in compound.constituentElements {
                let newEl = PlacedElement(
                    element: oldElement.element,
                    position: CGPoint(
                        x: compound.position.x + CGFloat.random(in: -30...30),
                        y: compound.position.y + CGFloat.random(in: -30...30)
                    )
                )
                restoredElements.append(newEl)
            }
            
            placedCompounds.removeAll { $0.id == compound.id }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.placedElements.append(contentsOf: restoredElements)
            }
        }
    }
    
    func selectCompound(_ compound: Compound) {
        withAnimation {
            infoPanelCompound = compound
            showInfoPanel = true
        }
    }
    
    func closeInfoPanel() {
        withAnimation {
            showInfoPanel = false
            infoPanelCompound = nil
        }
    }
    
    // MARK: - Discovery & Badges
    
    private func registerDiscovery(of compound: Compound) {
        if !discoveredCompounds.contains(compound.formula) {
            discoveredCompounds.insert(compound.formula)
            newlyDiscoveredCompound = compound
            if !availableElements.contains(where: { $0.symbol == compound.formula }) {
                let newElement = Element(
                    symbol: compound.formula,
                    name: compound.commonName,
                    color: .purple
                )
                availableElements.append(newElement)
                playReactionSoundAndHaptics()
            }
        }
    }
    
    private func checkBadges(for compound: Compound) {
        if compound.commonName.lowercased().contains("salt") {
            let saltCount = reactionHistory.filter { $0.commonName.lowercased().contains("salt") }.count
            if saltCount >= 3, !unlockedBadges.contains("Salt Master") {
                unlockedBadges.append("Salt Master")
            }
        }
        if compound.formula == "H₂O" {
            let waterCount = reactionHistory.filter { $0.formula == "H₂O" }.count
            if waterCount >= 3, !unlockedBadges.contains("Water Wizard") {
                unlockedBadges.append("Water Wizard")
            }
        }
        if compound.formula == "O₂" {
            let oxygenCount = reactionHistory.filter { $0.formula == "O₂" }.count
            if oxygenCount >= 2, !unlockedBadges.contains("Oxidation Expert") {
                unlockedBadges.append("Oxidation Expert")
            }
        }
        if compound.formula == "H₂" {
            let hydrogenCount = reactionHistory.filter { $0.formula == "H₂" }.count
            if hydrogenCount >= 2, !unlockedBadges.contains("Hydrogen Hero") {
                unlockedBadges.append("Hydrogen Hero")
            }
        }
        if discoveredCompounds.count >= 5, !unlockedBadges.contains("Compound Collector") {
            unlockedBadges.append("Compound Collector")
        }
    }
    
    private func playReactionSoundAndHaptics() {
        AudioServicesPlaySystemSound(1104)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Clustering Algorithm

struct ReactiveItem: Identifiable {
    let id: UUID
    let symbol: String
    var position: CGPoint
}

func buildClusters(fromElements elements: [PlacedElement], andCompounds compounds: [PlacedCompound], threshold: CGFloat) -> [[ReactiveItem]] {
    let elementItems = elements.map { placed -> ReactiveItem in
        ReactiveItem(id: placed.id, symbol: placed.element.symbol, position: placed.position)
    }
    let compoundItems = compounds.map { placed -> ReactiveItem in
        ReactiveItem(id: placed.id, symbol: placed.compound.formula, position: placed.position)
    }
    let allItems = elementItems + compoundItems
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
                let distance = hypot(candidate.position.x - current.position.x, candidate.position.y - current.position.y)
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
