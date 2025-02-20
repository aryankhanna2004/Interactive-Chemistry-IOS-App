import SwiftUI

/// A floating panel that shows details for a newly formed compound.
struct CompoundInfoPanel: View {
    let compound: Compound
    let dismissAction: () -> Void
    
    // Track vertical drag offset.
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Compound Info")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                // Larger tap area for dismiss button.
                Button(action: dismissAction) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Dismiss")
                }
            }
            
            Text("**Formula**: \(compound.formula)")
                .foregroundColor(.black)

            Text("**IUPAC Name**: \(compound.iupacName)")
                .foregroundColor(.black)

            Text("**Common Name**: \(compound.commonName)")
                .foregroundColor(.black)

            
            if let eq = compound.reactionEquation {
                Text("**Reaction**: \(eq)")
                    .foregroundColor(.black)

            }
            
            if let uses = compound.commonUses {
                Text("**Common Uses**: \(uses)")
                    .foregroundColor(.black)

            }
            
            if let fact = compound.funFact {
                Text("**Fun Fact**: \(fact)")
                    .foregroundColor(.black)

            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.95))
        )
        .shadow(radius: 4)
        // Offset the panel based on drag gesture.
        .offset(y: dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Allow only downward drag.
                    if value.translation.height > 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { _ in
                    // If dragged down far enough, dismiss the panel.
                    if dragOffset.height > 100 {
                        dismissAction()
                    } else {
                        // Otherwise, animate back to original position.
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .accessibilityElement(children: .contain)
    }
}
