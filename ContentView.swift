import SwiftUI
import AudioToolbox
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let guidedLearningMode: Bool
    
    @State private var draggingElement: Element? = nil
    @State private var dragPosition: CGPoint = .zero
    @State private var showLessonHint = false
    @State private var showCompletionOverlay = false
    @State private var overlayProgress: Double = 0
    @State private var overlayNextStep: String? = nil
    @State private var hasShownCompletionOverlay = false

    var body: some View {
        ZStack {
            // Main lab layout: Canvas + ElementSelectionPanel.
            HStack(spacing: 0) {
                CanvasView()
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Canvas for placing elements")
                ElementSelectionPanel(draggingElement: $draggingElement, dragPosition: $dragPosition)
                    .environmentObject(viewModel)
                    .frame(width: 100)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Element selection panel. Drag an element to the canvas")
            }
            .coordinateSpace(name: "CanvasSpace")
            
            // Ghost bubble while dragging.
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
            
            // Discovery overlay.
            if let newlyFound = viewModel.newlyDiscoveredCompound {
                NewDiscoveryOverlay(compound: newlyFound) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.newlyDiscoveredCompound = nil
                        if guidedLearningMode && viewModel.guidedPlaygroundCompleted {
                            overlayProgress = 100
                            overlayNextStep = nil
                            showCompletionOverlay = true
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("New compound discovered: \(newlyFound.commonName)")
            }
            
            // Info panel.
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
            
            // Hint overlay.
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
                        .background(Color.orange.opacity(0.5))
                        .foregroundColor(.black)
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
            
            // Final guided completion overlay.
            if guidedLearningMode && showCompletionOverlay && !hasShownCompletionOverlay {
                LessonProgressOverlay(
                    lessonName: viewModel.currentGuidedLessonModule?.title ?? "Lesson",
                    currentProgress: overlayProgress,
                    nextStep: overlayNextStep
                ) {
                    withAnimation {
                        showCompletionOverlay = false
                        hasShownCompletionOverlay = true
                    }
                }
            }

            
            // Optional: Reaction hint overlay.
            if let hint = viewModel.reactionHint {
                VStack {
                    Spacer()
                    Text(hint)
                        .font(.headline)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding()
                        .accessibilityLabel("Reaction Hint: \(hint)")
                }
                .transition(.opacity)
            }
            
            // Tutorial Overlay (only in PLAYGROUND mode)
            if !guidedLearningMode && TutorialControllerHolder.shared.controller.currentStep != .finished {
                TutorialOverlayView()
                    .environmentObject(TutorialControllerHolder.shared.controller)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Centered title.
            ToolbarItem(placement: .principal) {
                Text(guidedLearningMode ? (viewModel.currentGuidedLesson?.title ?? "Guided Lesson") : "PLAYGROUND")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            // "Show Hint" button.
            ToolbarItem(placement: .navigationBarTrailing) {
                if guidedLearningMode, viewModel.currentGuidedLesson != nil {
                    Button(action: { showLessonHint.toggle() }) {
                        Text(showLessonHint ? "Hide Hint" : "Show Hint")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.white.opacity(0.9)))
                            .foregroundColor(.black)
                    }
                    .accessibilityLabel(showLessonHint ? "Hide hint" : "Show hint")
                    .accessibilityHint("Toggles the display of a helpful hint")
                    .padding(.trailing, 8)
                }
            }
        }
        .toolbarBackground(Color.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Clear the canvas when the playground or guided lesson is opened.
            viewModel.placedElements.removeAll()
            viewModel.placedCompounds.removeAll()
            viewModel.closeInfoPanel()
            viewModel.guidedLearningMode = guidedLearningMode
            if guidedLearningMode {
                viewModel.currentGuidedLessonModule = nil
                viewModel.guidedOutcomeProducts = []
                viewModel.guidedPlaygroundCompleted = false
            } else {
                // In PLAYGROUND mode, auto-start the tutorial if not already dismissed.
                if !UserDefaults.standard.bool(forKey: "hasSeenTutorial122") {
                    TutorialControllerHolder.shared.controller.startTutorial()
                } else {
                    TutorialControllerHolder.shared.controller.dismissTutorial()
                }
            }
        }
        .onChange(of: viewModel.guidedPlaygroundCompleted) { completed in
            if completed && viewModel.newlyDiscoveredCompound == nil {
                overlayProgress = 100
                overlayNextStep = nil
                if let lessonModule = viewModel.currentGuidedLessonModule {
                    DispatchQueue.main.async {
                        // Set lesson progress to 100% when lab is completed
                        self.viewModel.lessonProgress[lessonModule.id] = 1.0
                    }
                }
                showCompletionOverlay = true
            }
        }
    }
}

