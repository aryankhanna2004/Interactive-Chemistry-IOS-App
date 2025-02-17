// WorkspaceViewModel
import SwiftUI

struct GuidedLesson {
    let title: String
    let hint: String
}
/// Basic Element model for the side panel
struct Element: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
}

/// An element placed in the workspace, with a position on the canvas
struct PlacedElement: Identifiable {
    let id = UUID()
    let element: Element
    var position: CGPoint
}

/// A compound placed in the workspace, storing the constituent elements
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
    let elementSize: CGFloat = 50
    let clusterThreshold: CGFloat = 50

    // MARK: - Add Element & Check Reactions
    func addElement(_ element: Element, at position: CGPoint) {
        placedElements.append(PlacedElement(element: element, position: position))
        checkForReactions()
    }

    func checkForReactions() {
            guard !placedElements.isEmpty else { return }

            let clusters = buildClusters(from: placedElements, threshold: clusterThreshold)

            for cluster in clusters {
                if cluster.count < 2 { continue }
                
                // Build stoich dictionary for the cluster.
                var stoich = cluster.reduce(into: [String: Int]()) { dict, placed in
                    dict[placed.element.symbol, default: 0] += 1
                }
                
                // We'll collect all used PlacedElement IDs in any reaction we form
                var usedElementIDs = Set<UUID>()
                cluster.forEach { usedElementIDs.insert($0.id) }
                
                var newlyFormedCompounds: [PlacedCompound] = []
                
                // Repeatedly find reactions until none match or stoich is empty
                while let (reaction, factor) = ReactionRepository.shared.findReactionFactor(in: stoich), factor > 0 {
                    // For each factor, we produce that many product compounds
                    for _ in 0..<factor {
                        // We approximate the average position of the cluster
                        let (avgX, avgY) = cluster.reduce((0.0, 0.0)) {
                            ($0.0 + $1.position.x, $0.1 + $1.position.y)
                        }
                        let centerX = avgX / CGFloat(cluster.count)
                        let centerY = avgY / CGFloat(cluster.count)
                        
                        // We treat the entire cluster as “consumed” in a naive sense,
                        // or you can gather the exact elements that contributed.
                        
                        let newCompound = PlacedCompound(
                            compound: reaction.product,
                            position: CGPoint(x: centerX, y: centerY),
                            constituentElements: cluster
                        )
                        newlyFormedCompounds.append(newCompound)
                        
                        // Register discovery & etc.
                        registerDiscovery(of: reaction.product)
                        reactionHistory.append(reaction.product)
                        displayInfoPanel(for: reaction.product)
                        checkBadges(for: reaction.product)
                        playReactionSoundAndHaptics()
                    }
                    
                    // Subtract the used stoich from cluster stoich
                    for (element, neededCount) in reaction.reactants {
                        stoich[element]! -= (neededCount * factor)
                        if stoich[element]! <= 0 {
                            stoich[element] = nil
                        }
                    }
                }
                
                // If we formed any new compounds, remove those elements from placedElements
                if !newlyFormedCompounds.isEmpty {
                    placedElements.removeAll { usedElementIDs.contains($0.id) }
                    // Place new compounds
                    withAnimation {
                        placedCompounds.append(contentsOf: newlyFormedCompounds)
                    }
                }
            }
        }
    
    func possibleReactionsStartingWith(_ element: Element) -> [Compound] {
        return ReactionRepository.shared.reactions
            .filter { $0.reactants.keys.contains(element.symbol) }
            .map { $0.product }
    }


    // MARK: - Display Compound Info
    private func displayInfoPanel(for compound: Compound) {
        infoPanelCompound = compound
        showInfoPanel = true
    }

    // MARK: - Break Compound
    func breakCompound(_ compound: PlacedCompound) {
            withAnimation {
                // Re-insert the original elements
                for oldElement in compound.constituentElements {
                    var newEl = oldElement
                    // Nudging position randomly so they’re not directly on top
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
        }
    }

    private func checkBadges(for compound: Compound) {
        if compound.commonName.lowercased().contains("salt") {
            let saltCount = reactionHistory.filter { $0.commonName.lowercased().contains("salt") }.count
            if saltCount >= 3, !unlockedBadges.contains("Salt Master") {
                unlockedBadges.append("Salt Master")
            }
        }
    }
    

    private func playReactionSoundAndHaptics() {
        // Stub: Implement real haptics/audio if needed
    }
}

/// A BFS-based clustering approach to group nearby placed elements.
func buildClusters(from elements: [PlacedElement], threshold: CGFloat) -> [[PlacedElement]] {
    var visited = Set<UUID>()
    var clusters: [[PlacedElement]] = []

    func bfs(start: PlacedElement, all: [PlacedElement]) -> [PlacedElement] {
        var queue: [PlacedElement] = [start]
        var group: [PlacedElement] = []

        while !queue.isEmpty {
            let current = queue.removeFirst()
            if visited.contains(current.id) { continue }

            visited.insert(current.id)
            group.append(current)

            for candidate in all where !visited.contains(candidate.id) {
                let distance = hypot(
                    candidate.position.x - current.position.x,
                    candidate.position.y - current.position.y
                )
                if distance <= threshold {
                    queue.append(candidate)
                }
            }
        }

        return group
    }

    for element in elements {
        if !visited.contains(element.id) {
            let group = bfs(start: element, all: elements)
            clusters.append(group)
        }
    }

    return clusters
}
