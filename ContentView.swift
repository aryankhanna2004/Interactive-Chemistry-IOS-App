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
                // Removed the viewModel parameter; use environment injection instead.
                CanvasView()
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0)) // Light pastel blue
                    .cornerRadius(12)
                
                // Element selection panel with a pastel color.
                ElementSelectionPanel(
                    draggingElement: $draggingElement,
                    dragPosition: $dragPosition
                )
                .environmentObject(viewModel)
                .frame(width: 120)
                .background(Color(red: 0.9, green: 0.95, blue: 0.85)) // Light pastel green
            }
            .coordinateSpace(name: "CanvasSpace")
            
            // Ghost bubble while dragging an element.
            if let element = draggingElement {
                Text(element.symbol)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(radius: 2)
                    .position(dragPosition)
                    .allowsHitTesting(false)
            }
            
            // "New Discovery" overlay.
            if let newlyFound = viewModel.newlyDiscoveredCompound {
                NewDiscoveryOverlay(compound: newlyFound) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.newlyDiscoveredCompound = nil
                    }
                }
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
            }
            
            // "Snackbar"-style hint at bottom-left.
            if showLessonHint, let lesson = viewModel.currentGuidedLesson {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hint")
                                .font(.headline)
                            Text(lesson.hint)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Left side: Custom Back + "Guided Lesson"
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    // Rounded, colorful back button.
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
                                .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                        )
                    }
                    
                    // Guided Lesson Title.
                    if guidedLearningMode, let lesson = viewModel.currentGuidedLesson {
                        Text("Guided Lesson: \(lesson.title)")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                }
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
                }
            }
        }
        .onAppear {
            // Set the guided learning mode in the view model.
            viewModel.guidedLearningMode = guidedLearningMode
        }
    }
}
