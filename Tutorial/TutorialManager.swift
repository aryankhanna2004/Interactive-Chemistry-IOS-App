import SwiftUI

// MARK: - Tutorial Controller

@MainActor
final class TutorialController: ObservableObject {
    @Published var currentStep: TutorialStep = .welcome
    
    func startTutorial() {
        currentStep = .welcome
    }
    
    func nextStep() {
        // Move through steps in order.
        if let next = TutorialStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        } else {
            currentStep = .finished
        }
    }
    
    func dismissTutorial() {
        currentStep = .none
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial122")
    }
}

// MARK: - Tutorial Steps

enum TutorialStep: Int, CaseIterable {
    case none = 0
    case welcome = 1        // Centered welcome screen
    case dragNA = 2         // Spotlight on the 'Na' element in side panel
    case combineCL = 3      // Spotlight on the 'Cl' element in side panel
    case tapForInfo = 4     // No spotlight, instruct user to tap for info
    case highlightInfo = 5  // Spotlight on info panel (rectangle)
    case doubleTapToDismiss = 6
    case finished = 7       // Completion state
}

extension TutorialStep {
    var instructionText: String {
        switch self {
        case .none:
            return ""
        case .welcome:
            return "Welcome to Playground! Start the tutorial."
        case .dragNA:
            return "Drag 'Na' from the highlighted side panel onto the canvas on the left."
        case .combineCL:
            return "Now, drag 'Cl' and drop it onto 'Na' onto the canvas on the left to combine them."
        case .tapForInfo:
            return "Tap the newly formed compound to view its info."
        case .highlightInfo:
            return "Here's the compound info! You can learn what it's made of."
        case .doubleTapToDismiss:
            return "Double tap the new compound to dismiss it."
        case .finished:
            return "Try to form new compounds and check out lessons for guided help."
        }
    }
    
    var shouldShowSpotlight: Bool {
        switch self {
        case .dragNA, .combineCL, .highlightInfo:
            return true
        default:
            return false
        }
    }
    @MainActor
    var spotlightRect: CGRect? {
        switch self {
        case .dragNA, .combineCL:
            // Highlight the entire element panel.
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            return CGRect(x: screenWidth - 100, y: 0, width: 100, height: screenHeight)
        case .highlightInfo:
            // Updated coordinates for info panel.
            return CGRect(x: 90, y: 75, width: 260, height: 320)
        default:
            return nil
        }
    }
}

// MARK: - Spotlight View

enum SpotlightShape {
    case circle, rectangle
}

struct SpotlightView: View {
    var spotlightRect: CGRect
    var shape: SpotlightShape
    
    var body: some View {
        GeometryReader { _ in
            Color.black.opacity(0.5)
                .mask(
                    Rectangle()
                        .overlay(
                            Group {
                                if shape == .rectangle {
                                    Rectangle()
                                        .frame(width: spotlightRect.width, height: spotlightRect.height)
                                        .position(x: spotlightRect.midX, y: spotlightRect.midY)
                                        .blendMode(.destinationOut)
                                } else {
                                    Circle()
                                        .frame(width: spotlightRect.width, height: spotlightRect.height)
                                        .position(x: spotlightRect.midX, y: spotlightRect.midY)
                                        .blendMode(.destinationOut)
                                }
                            }
                        )
                )
                .compositingGroup()
                .allowsHitTesting(false)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Tutorial Overlay View

struct TutorialOverlayView: View {
    @EnvironmentObject var tutorialController: TutorialController
    @State private var doNotShowAgain = false
    
    private var isWelcome: Bool {
        tutorialController.currentStep == .welcome
    }
    
    private var isFinished: Bool {
        tutorialController.currentStep == .finished
    }
    
    var body: some View {
        // If tutorial is dismissed, show nothing.
        if tutorialController.currentStep == .none {
            EmptyView()
        } else {
            ZStack {
                // Display spotlight if needed.
                if tutorialController.currentStep.shouldShowSpotlight,
                   let rect = tutorialController.currentStep.spotlightRect {
                    let shape: SpotlightShape = (tutorialController.currentStep == .highlightInfo ||
                                                 tutorialController.currentStep == .dragNA ||
                                                 tutorialController.currentStep == .combineCL)
                        ? .rectangle
                        : .circle
                    SpotlightView(spotlightRect: rect, shape: shape)
                } else {
                    Color.clear
                }
                
                // Display the appropriate card.
                if isFinished {
                    ConfettiView()
                        .zIndex(0)
                    finishedCard
                        .zIndex(1)
                        .transition(.scale)
                } else if isWelcome {
                    welcomeCard
                        .transition(.scale)
                } else {
                    bottomCard
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut, value: tutorialController.currentStep)
            .transition(.opacity)
        }
    }
    
    // MARK: - Welcome Card (Centered)
    private var welcomeCard: some View {
        VStack(spacing: 20) {
            Text("Welcome to Playground!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Start the tutorial or skip if you wish.")
                .font(.body)
                .foregroundColor(.black)
            
            Toggle("Don't show again", isOn: $doNotShowAgain)
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                .padding(.horizontal, 40)
            
            HStack(spacing: 30) {
                Button("Skip") {
                    if doNotShowAgain {
                        UserDefaults.standard.set(true, forKey: "hasSeenTutorial122")
                    }
                    tutorialController.dismissTutorial()
                }
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Start") {
                    if doNotShowAgain {
                        UserDefaults.standard.set(true, forKey: "hasSeenTutorial122")
                    }
                    tutorialController.nextStep()
                }
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(30)
        .frame(maxWidth: 450)
        .background(Color.white.opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 6)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Bottom Card (For Steps After Welcome)
    private var bottomCard: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text(tutorialController.currentStep.instructionText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(tutorialController.currentStep == .tapForInfo ? "Continue" : "Next") {
                    tutorialController.nextStep()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .frame(maxWidth: 500)
            .background(Color.white.opacity(0.95))
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Finished Card (Centered)
    private var finishedCard: some View {
        VStack(spacing: 20) {
            Text("Great Job on Completing the tutorial! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Try to form new compounds and check out lessons for guided help.")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Done") {
                tutorialController.dismissTutorial()
            }
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(30)
        .frame(maxWidth: 450)
        .background(Color.white.opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 6)
        .padding(.horizontal, 20)
    }
}

// MARK: - Shared Holder

@MainActor
final class TutorialControllerHolder {
    static let shared = TutorialControllerHolder()
    let controller = TutorialController()
}
