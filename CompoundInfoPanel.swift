//CompoundInfoPanel
import SwiftUI

/// A floating panel that shows details for a newly formed compound.
struct CompoundInfoPanel: View {
    let compound: Compound
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Compound Info")
                    .font(.headline)
                Spacer()
                Button(action: dismissAction) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text("**Formula**: \(compound.formula)")
            Text("**IUPAC Name**: \(compound.iupacName)")
            Text("**Common Name**: \(compound.commonName)")
            
            if let eq = compound.reactionEquation {
                Text("**Reaction**: \(eq)")
            }
            
            if let uses = compound.commonUses {
                Text("**Common Uses**: \(uses)")
            }
            
            if let fact = compound.funFact {
                Text("**Fun Fact**: \(fact)")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.95))
        )
        .shadow(radius: 4)
    }
}

