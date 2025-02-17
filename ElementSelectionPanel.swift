import SwiftUI

// ElementSelectionPanel
struct ElementSelectionPanel: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    /// Which element is currently being dragged from the panel (if any).
    @Binding var draggingElement: Element?
    
    /// Current drag position in the "CanvasSpace" coordinate system.
    @Binding var dragPosition: CGPoint
    
    var body: some View {
        VStack(spacing: 16) {
            // Use the dynamic list from the view model.
            ForEach(viewModel.availableElements) { element in
                elementBubble(element)
            }
            Spacer()
        }
        .padding()
        // Light orange background for the panel.
        .background(Color(red: 1.0, green: 0.9, blue: 0.8))
    }
    
    private func elementBubble(_ element: Element) -> some View {
        ZStack {
            Circle()
                .fill(element.color)
                .frame(width: 70, height: 70) // Increased bubble size
            Text(element.symbol)
                .font(.headline)
                .foregroundColor(.white)
        }
        .shadow(radius: 2)
        .gesture(
            DragGesture(coordinateSpace: .named("CanvasSpace"))
                .onChanged { value in
                    if draggingElement == nil {
                        draggingElement = element
                        
                        // If guided learning is on, show possible reactions.
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
