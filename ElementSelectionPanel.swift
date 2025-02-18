import SwiftUI
struct ElementSelectionPanel: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    @Binding var draggingElement: Element?
    @Binding var dragPosition: CGPoint
    
    var body: some View {
        // Vertical ScrollView for many elements
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // Dynamic list from the view model
                ForEach(viewModel.availableElements) { element in
                    elementBubble(element)
                }
                Spacer(minLength: 20)
            }
            .padding()
        }
        // Light orange background for the panel
        .background(Color(red: 1.0, green: 0.9, blue: 0.8))
    }
    
    private func elementBubble(_ element: Element) -> some View {
        ZStack {
            Circle()
                .fill(element.color)
                .frame(width: 70, height: 70)
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
                        
                        if viewModel.guidedLearningMode {
                            let possibleProducts = viewModel.possibleReactionsStartingWith(element)
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
