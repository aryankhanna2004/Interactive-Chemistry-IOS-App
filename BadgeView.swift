import SwiftUI

struct PossibleBadge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct BadgeView: View {
    let badges: [String]  // List of *unlocked* badge titles
    
    // List of all possible badges
    private let possibleBadges: [PossibleBadge] = [
        PossibleBadge(title: "Salt Master", description: "Unlock by discovering 3 salt reactions."),
        PossibleBadge(title: "Water Wizard", description: "Unlock by forming H₂O at least 3 times."),
        PossibleBadge(title: "Oxidation Expert", description: "Unlock by forming O₂ at least 2 times."),
        PossibleBadge(title: "Hydrogen Hero", description: "Unlock by forming H₂ at least 2 times."),
        PossibleBadge(title: "Compound Collector", description: "Unlock by discovering at least 5 compounds.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Header
                Text("🏆 Your Achievements")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                    .padding(.top, 32)
                
                // Partition badges into unlocked vs locked
                let unlockedBadges = possibleBadges.filter { badges.contains($0.title) }
                let lockedBadges = possibleBadges.filter { !badges.contains($0.title) }
                
                // Unlocked Badges Section
                if !unlockedBadges.isEmpty {
                    UnlockedBadgesSection(unlockedBadges: unlockedBadges)
                } else {
                    // If user has no unlocked badges yet
                    Text("You haven't unlocked any badges yet.\nKeep experimenting to earn some!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Locked Badges Section
                if !lockedBadges.isEmpty {
                    LockedBadgesSection(lockedBadges: lockedBadges)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal)
        }
        // Light background behind the scroll view
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Unlocked Badges Section

struct UnlockedBadgesSection: View {
    let unlockedBadges: [PossibleBadge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Unlocked Badges")
            
            // Display each unlocked badge in a card
            ForEach(unlockedBadges) { badge in
                HStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(badge.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(badge.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2)) // Subtle background for the entire section
        )
    }
}

// MARK: - Locked Badges Section

struct LockedBadgesSection: View {
    let lockedBadges: [PossibleBadge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Locked Badges")
            
            // Display each locked badge in a lighter gray card
            ForEach(lockedBadges) { badge in
                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(badge.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(badge.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }
}

// MARK: - Section Header

/// A reusable header with an orange gradient background.
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.8, green: 0.5, blue: 0.1),
                        Color(red: 0.9, green: 0.6, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
    }
}
