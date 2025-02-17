import SwiftUI
import AudioToolbox
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let guidedLearningMode: Bool

    @State private var draggingElement: Element? = nil
    @State private var dragPosition: CGPoint = .zero
    @State private var showLessonHint = false

    // Only the final 100% overlay will be handled here.
    @State private var showCompletionOverlay = false
    @State private var overlayProgress: Double = 0
    @State private var overlayNextStep: String? = nil

    var body: some View {
        ZStack {
            // Main lab layout: Canvas and ElementSelectionPanel.
            HStack(spacing: 0) {
                CanvasView()
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                    .cornerRadius(12)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Canvas for placing elements")
                ElementSelectionPanel(draggingElement: $draggingElement, dragPosition: $dragPosition)
                    .environmentObject(viewModel)
                    .frame(width: 120)
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
                        // After closing discovery overlay, if guided mode and quiz completed, trigger final overlay.
                        if guidedLearningMode && viewModel.guidedPlaygroundCompleted {
                            print("ContentView: Discovery dismissed -> guidedPlaygroundCompleted already true")
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
                        .background(.orange.opacity(0.5))
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
            
            // Final guided completion overlay (100%).
            if guidedLearningMode && showCompletionOverlay {
                LessonProgressOverlay(
                    lessonName: viewModel.currentGuidedLessonModule?.title ?? "Lesson",
                    currentProgress: overlayProgress,
                    nextStep: overlayNextStep
                ) {
                    withAnimation {
                        showCompletionOverlay = false
                    }
                }
            }
        }
        .toolbar {
            // Only a trailing toolbar item; no back button.
            ToolbarItem(placement: .navigationBarTrailing) {
                if guidedLearningMode, viewModel.currentGuidedLesson != nil {
                    Button(action: {
                        showLessonHint.toggle()
                    }) {
                        Text(showLessonHint ? "Hide Hint" : "Show Hint")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(.orange.opacity(0.9)))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 110)
                    .accessibilityLabel(showLessonHint ? "Hide hint" : "Show hint")
                    .accessibilityHint("Toggles the display of a helpful hint")
                }
            }
        }
        .onAppear {
            print("ContentView onAppear: quizCompleted = \(viewModel.quizCompleted), guidedPlaygroundCompleted = \(viewModel.guidedPlaygroundCompleted)")
            viewModel.guidedLearningMode = guidedLearningMode
            // In ContentView we now do not trigger 50% overlay for quiz.
            if guidedLearningMode {
                // Do not reset quizCompleted so that once set, it stays.
                viewModel.currentGuidedLessonModule = nil
                viewModel.guidedOutcomeProducts = []
                viewModel.guidedPlaygroundCompleted = false
            }
        }
        // Listen only for final guided playground completion.
        .onChange(of: viewModel.guidedPlaygroundCompleted) { completed in
            print("ContentView onChange: guidedPlaygroundCompleted = \(completed)")
            // Only trigger final overlay if the discovery overlay is dismissed.
            if completed && viewModel.newlyDiscoveredCompound == nil {
                overlayProgress = 100
                overlayNextStep = nil
                if let lessonModule = viewModel.currentGuidedLessonModule,
                   !viewModel.completedLessons.contains(lessonModule.id) {
                    viewModel.completedLessons.insert(lessonModule.id)
                }
                print("ContentView: Final overlay triggered: \(overlayProgress)%")
                showCompletionOverlay = true
            }
        }

    }
}
