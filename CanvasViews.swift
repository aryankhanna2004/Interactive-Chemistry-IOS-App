// CanvasView
import SwiftUI

/// A draggable bubble representing a single placed element on the canvas.
/// It updates the model’s position as the user drags it.
struct PlacedElementView: View {
    @Binding var placedElement: PlacedElement
    let dragEnded: () -> Void
    
    var body: some View {
        Text(placedElement.element.symbol)
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Color.blue)
            .cornerRadius(25)
            .shadow(radius: 2)
            .position(placedElement.position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update position in the data model
                        placedElement.position = value.location
                    }
                    .onEnded { _ in
                        // Once dragging finishes, check for reactions or do other logic
                        dragEnded()
                    }
            )
    }
}



/// A draggable bubble representing a compound.
/// Single tap shows info; double tap breaks the compound.

/// A draggable bubble representing a placed compound (the product of a reaction).
/// - Single tap => show info
/// - Double tap => break the compound back into elements
struct PlacedCompoundView: View {
    @Binding var placedCompound: PlacedCompound
    let breakAction: () -> Void
    let infoAction: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            Text(placedCompound.compound.formula)
                .font(.headline)
                .foregroundColor(.white)
            Text(placedCompound.compound.commonName)
                .font(.caption2)
                .foregroundColor(.white)
        }
        .frame(width: 60, height: 60)
        .background(Color.purple)
        .cornerRadius(30)
        .shadow(radius: 2)
        .position(placedCompound.position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Update position in the data model
                    placedCompound.position = value.location
                }
        )
        .onTapGesture {
            // Single tap => show info
            infoAction()
        }
        .onTapGesture(count: 2) {
            // Double tap => break
            breakAction()
        }
    }
}



/// The main workspace canvas where elements and compounds are displayed.


struct CanvasView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    var body: some View {
        ZStack {
            // Elements
            // We use $viewModel.placedElements so that each element is a Binding<PlacedElement>.
            ForEach($viewModel.placedElements) { $placedElement in
                PlacedElementView(placedElement: $placedElement) {
                    // When the user finishes dragging an element, check for new reactions
                    viewModel.checkForReactions()
                }
            }
            
            // Compounds
            // Similarly, we pass each placedCompound as a binding to PlacedCompoundView.
            ForEach($viewModel.placedCompounds) { $placedCompound in
                PlacedCompoundView(
                    placedCompound: $placedCompound,
                    breakAction: {
                        // Double-tap breaks the compound
                        viewModel.breakCompound(placedCompound)
                    },
                    infoAction: {
                        // Single-tap shows info
                        viewModel.selectCompound(placedCompound.compound)
                    }
                )
            }
        }
        .coordinateSpace(name: "CanvasSpace")
    }
}
