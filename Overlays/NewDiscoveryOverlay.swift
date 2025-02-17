import SwiftUI

/// A pop-up that appears briefly when a new compound is discovered.
struct NewDiscoveryOverlay: View {
    let compound: Compound
    let dismissAction: () -> Void

    @State private var animateScale = 0.1

    var body: some View {
        VStack(spacing: 8) {
            Text("New Discovery!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(compound.commonName)
                .font(.headline)
                .foregroundColor(.white)

            Text("“\(compound.funFact ?? "No fun fact available.")”")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Button("Got it") {
                dismissAction()
            }
            .padding(.top, 10)
            .buttonStyle(.borderedProminent)
            .tint(.green) 

        }
        .padding()
        .background(.orange)
        .cornerRadius(16)
        .shadow(radius: 5)
        .scaleEffect(animateScale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                animateScale = 1.0
            }
        }
    }
}
