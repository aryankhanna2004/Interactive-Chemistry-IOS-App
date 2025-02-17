import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let guidedLearningMode: Bool

    @Environment(\.dismiss) var dismiss
    
    @State private var draggingElement: Element? = nil
    @State private var dragPosition: CGPoint = .zero
    
    /// Controls whether we show the hint "snackbar."
    @State private var showLessonHint = false

    var body: some View {
        ZStack {
            // Main layout: Canvas + Element side panel
            HStack(spacing: 0) {
                // Canvas View with a playful pastel background.
                CanvasView()
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0)) // Light pastel blue
                    .cornerRadius(12)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Canvas for placing elements")
                
                // Element selection panel with a light orange background.
                ElementSelectionPanel(
                    draggingElement: $draggingElement,
                    dragPosition: $dragPosition
                )
                .environmentObject(viewModel)
                .frame(width: 120)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Element selection panel. Drag an element to the canvas")
            }
            .coordinateSpace(name: "CanvasSpace")
            
            // Ghost bubble while dragging an element.
            if let element = draggingElement {
                Text(element.symbol)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.blue)
                    .cornerRadius(35)
                    .shadow(radius: 2)
                    .position(dragPosition)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            
            // "New Discovery" overlay.
            if let newlyFound = viewModel.newlyDiscoveredCompound {
                NewDiscoveryOverlay(compound: newlyFound) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.newlyDiscoveredCompound = nil
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("New compound discovered: \(newlyFound.commonName)")
            }
            
            // Floating Info Panel.
            if viewModel.showInfoPanel, let infoCompound = viewModel.infoPanelCompound {
                CompoundInfoPanel(compound: infoCompound) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.closeInfoPanel()
                    }
                }
                .id(infoCompound.id)
                .frame(width: 250)
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: infoCompound.id)
                .position(x: 220, y: 160)
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
            }
            
            // "Snackbar"-style hint at bottom-left.
            if showLessonHint, let lesson = viewModel.currentGuidedLesson {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hint")
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            Text(lesson.hint)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Hint: \(lesson.hint)")
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 16)
                }
                .accessibilityElement(children: .contain)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Left side: Custom Back + "Guided Lesson"
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    // Custom back button with light orange background.
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.8, green: 0.5, blue: 0.1))
                        )
                    }
                    .accessibilityLabel("Back")
                    .accessibilityHint("Returns to the previous screen")
                    
                    // Guided Lesson Title.
                    if guidedLearningMode, let lesson = viewModel.currentGuidedLesson {
                        Text("Guided Lesson: \(lesson.title)")
                            .font(.headline)
                            .padding(.leading, 8)
                            .accessibilityLabel("Guided Lesson: \(lesson.title)")
                    }
                }
                .accessibilityElement(children: .contain)
            }
            
            // Right side: Small "Show/Hide Hint" button.
            ToolbarItem(placement: .navigationBarTrailing) {
                if guidedLearningMode, viewModel.currentGuidedLesson != nil {
                    Button(action: {
                        showLessonHint.toggle()
                    }) {
                        Text(showLessonHint ? "Hide Hint" : "Show Hint")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.95, green: 0.4, blue: 0.4))
                            )
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 110)
                    .accessibilityLabel(showLessonHint ? "Hide hint" : "Show hint")
                    .accessibilityHint("Toggles the display of a helpful hint")
                }
            }
        }
        .onAppear {
            // Set the guided learning mode in the view model.
            viewModel.guidedLearningMode = guidedLearningMode
        }
    }
}
