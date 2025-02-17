// CanvasView
import SwiftUI

struct PlacedElementView: View {
    @Binding var placedElement: PlacedElement
    let dragEnded: (CGPoint) -> Void
    
    var body: some View {
        Text(placedElement.element.symbol)
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(placedElement.element.color) // Use the element’s color
            .cornerRadius(35)
            .shadow(radius: 2)
            .position(placedElement.position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        placedElement.position = value.location
                    }
                    .onEnded { value in
                        if value.location.x < 120 {
                            placedElement.position.x = 130
                        }
                        
                        // 2) Then check trash or reactions
                        dragEnded(placedElement.position)
                    }
            )

        
    }
}

struct PlacedCompoundView: View {
    @Binding var placedCompound: PlacedCompound
    let breakAction: () -> Void
    let infoAction: () -> Void
    let dragEnded: (CGPoint) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Text(placedCompound.compound.formula)
                .font(.headline)
                .foregroundColor(.white)
            Text(placedCompound.compound.commonName)
                .font(.caption2)
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .background(Color.purple)
        .cornerRadius(35)
        .shadow(radius: 2)
        .position(placedCompound.position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    placedCompound.position = value.location
                }
                .onEnded { value in
                    dragEnded(value.location)
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
        GeometryReader { geometry in
            ZStack {
                // Elements
                ForEach($viewModel.placedElements) { $placedElement in
                    PlacedElementView(placedElement: $placedElement,
                                      dragEnded: { finalPos in
                        // Check if dropped on trash
                        let trashRect = CGRect(x: geometry.size.width - 70,
                                               y: geometry.size.height - 70,
                                               width: 50,
                                               height: 50)
                        if trashRect.contains(finalPos) {
                            // Remove this element from the workspace
                            viewModel.placedElements.removeAll { $0.id == placedElement.id }
                        } else {
                            // Otherwise, do your normal reaction check
                            viewModel.checkForReactions()
                        }
                    })
                }
                
                // Compounds
                ForEach($viewModel.placedCompounds) { $placedCompound in
                    PlacedCompoundView(placedCompound: $placedCompound,
                                       breakAction: {
                        viewModel.breakCompound(placedCompound)
                    },
                                       infoAction: {
                        viewModel.selectCompound(placedCompound.compound)
                    },
                                       dragEnded: { finalPos in
                        let trashRect = CGRect(x: geometry.size.width - 70,
                                               y: geometry.size.height - 70,
                                               width: 50,
                                               height: 50)
                        if trashRect.contains(finalPos) {
                            // Remove this compound
                            viewModel.placedCompounds.removeAll { $0.id == placedCompound.id }
                        } else {
                            // Normal reaction check
                            viewModel.checkForReactions()
                        }
                    })
                }
                
                // Place trash icon
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.red)
                    .position(x: geometry.size.width - 40,
                              y: geometry.size.height - 40)
            }
            .coordinateSpace(name: "CanvasSpace")
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        }
    }
}
