// BadgeView
import SwiftUI

/// A full-screen scroller displaying unlocked badges.
struct BadgeView: View {
    let badges: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🏆 Your Achievements")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                if badges.isEmpty {
                    Text("No badges yet! Start discovering reactions to earn some.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(badges, id: \.self) { badge in
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text(badge)
                                .font(.title2)
                                .bold()
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
}
