// ElementSelectionPanel
import SwiftUI

/// A list of available elements to drag onto the canvas.
let availableElements: [Element] = [
    Element(symbol: "H", name: "Hydrogen"),
    Element(symbol: "O", name: "Oxygen"),
    Element(symbol: "Na", name: "Sodium"),
    Element(symbol: "Cl", name: "Chlorine")
]

struct ElementSelectionPanel: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    /// Which element is currently being dragged from the panel (if any).
    @Binding var draggingElement: Element?
    
    /// Current drag position in the "CanvasSpace" coordinate system.
    @Binding var dragPosition: CGPoint
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(availableElements) { element in
                elementBubble(element)
            }
            Spacer()
        }
        .padding()
    }
    
    private func elementBubble(_ element: Element) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
            Text(element.symbol)
                .font(.headline)
                .foregroundColor(.white)
        }
        .shadow(radius: 2)
        .gesture(  // ✅ Corrected: Using `.gesture(...)` instead of `.dragGesture(...)`
            DragGesture(coordinateSpace: .named("CanvasSpace"))
                .onChanged { value in
                    if draggingElement == nil {
                        draggingElement = element
                        
                        // If guided learning is on, show possible reactions
                        if viewModel.guidedLearningMode {
                            let possibleProducts: [Compound] = viewModel.possibleReactionsStartingWith(element)
                            print("Hints for \(element.symbol): \(possibleProducts.map { $0.formula })")
                        }
                    }
                    dragPosition = value.location
                }
                .onEnded { value in
                    if let dragged = draggingElement {
                        viewModel.addElement(dragged, at: value.location)
                        draggingElement = nil
                    }
                }
        )
    }
}
