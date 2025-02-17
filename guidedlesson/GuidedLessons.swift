import SwiftUI

struct LessonModule: Identifiable {
    let id = UUID()
    // Basic metadata
    let title: String
    let description: String
    let emoji: String
    // Main content
    let bodyText: String
    let reactionEquation: String?
    // Background info (multiple paragraphs)
    let backgroundInformation: [String]
    // Detailed info that can be toggled
    let detailHeader: String
    let detailParagraphs: [String]
    // Quiz information
    let quizQuestion: String
    let quizOptions: [String]
    let correctAnswer: String
    // Guided lesson info (optional)
    let guidedLessonTitle: String?
    let guidedLessonHint: String?
    let guidedEmoji: String?
    // Outcome goals for the guided lesson (list of product formulas)
    let guidedOutcomeGoals: [String]?
}
import SwiftUI

struct GenericLessonView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let lesson: LessonModule
    
    @State private var selectedAnswer: String? = nil
    @State private var showDetails = false
    
    @State private var showQuizOverlay = false
    @State private var quizOverlayProgress: Double = 0
    @State private var quizNextStep: String? = nil
    
    // Define a main brand orange for headers/buttons.
    private let brandOrange = Color(red: 0.95, green: 0.60, blue: 0.15)

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1) Title bar (brand orange)
                    titleSection
                    
                    // 2) Body text (white card with subtle orange stroke)
                    bodyTextSection
                    
                    // 3) Reaction equation card
                    if let eq = lesson.reactionEquation {
                        reactionEquationCard(equation: eq)
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // 4) Background info section
                    backgroundInfoSection
                    
                    // 5) Additional info toggle
                    detailsToggleSection
                    
                    Divider().padding(.vertical, 8)
                    
                    // 6) Quiz time
                    quizSection
                    
                    // 7) CTA to guided lesson
                    guidedLessonCTA
                        .padding(.top, 20)
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            
            // Quiz overlay
            if showQuizOverlay {
                LessonProgressOverlay(
                    lessonName: lesson.title,
                    currentProgress: quizOverlayProgress,
                    nextStep: quizNextStep
                ) {
                    withAnimation {
                        showQuizOverlay = false
                    }
                }
            }
        }
    }
    
    // 1) Title Section
    private var titleSection: some View {
        HStack {
            Text(lesson.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(lesson.emoji)
                .font(.largeTitle)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity)
        // Use your main brand color here:
        .background(brandOrange)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lesson.title) \(lesson.emoji)")
    }
    
    // 2) Body Text Section
    private var bodyTextSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.bodyText)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        // Subtle orange stroke instead of full color fill:
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandOrange.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement()
        .accessibilityLabel(lesson.bodyText)
    }
    
    // 3) Reaction Equation Card
    private func reactionEquationCard(equation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reaction Equation")
                .font(.title2)
                .bold()
            
            // Use a white box with a light shadow or stroke
            Text(equation)
                .font(.title)
                .foregroundColor(brandOrange)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(brandOrange.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandOrange.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reaction Equation: \(equation)")
    }
    
    // 4) Background Info Section
    @ViewBuilder
    private var backgroundInfoSection: some View {
        if !lesson.backgroundInformation.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Background Info")
                    .font(.title2)
                    .bold()
                
                ForEach(lesson.backgroundInformation, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.body)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(brandOrange.opacity(0.1), lineWidth: 1)
                        )
                        .accessibilityElement()
                        .accessibilityLabel(paragraph)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandOrange.opacity(0.1), lineWidth: 1)
            )
        }
    }

    // 5) Additional Info Toggle
    private var detailsToggleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(brandOrange)
                    
                    Text(showDetails ? "Hide Additional Info" : "Show Additional Info")
                        .bold()
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                // Light brandOrange tint, not a full fill:
                .background(brandOrange.opacity(0.1))
                .cornerRadius(12)
                .accessibilityLabel(showDetails ? "Hide additional info" : "Show additional info")
            }
            if showDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.detailHeader)
                        .font(.title3)
                        .bold()
                    
                    ForEach(lesson.detailParagraphs, id: \.self) { detail in
                        Text(detail)
                            .font(.body)
                            .accessibilityLabel(detail)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandOrange.opacity(0.1), lineWidth: 1)
                )
                .transition(.opacity)
            }
        }
    }
    
    // 6) Quiz Section
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Time!")
                .font(.title2)
                .bold()
            
            Text(lesson.quizQuestion)
                .font(.body)
                .bold()
            
            VStack(spacing: 10) {
                ForEach(lesson.quizOptions, id: \.self) { option in
                    QuizOption(
                        option: option,
                        correctOption: lesson.correctAnswer,
                        selectedOption: $selectedAnswer
                    ) {
                        if !viewModel.completedLessons.contains(lesson.id) && !viewModel.quizCompleted {
                            viewModel.quizCompleted = true
                            showQuizOverlay = true
                            quizOverlayProgress = 50
                            quizNextStep = "Try forming it in the lab!"
                        }
                    }
                }
            }
            
            if let answer = selectedAnswer {
                let feedback = (answer == lesson.correctAnswer)
                    ? "✅ Correct!"
                    : "❌ Oops, that's not correct. Try again!"
                Text(feedback)
                    .foregroundColor(answer == lesson.correctAnswer ? .green : .red)
                    .bold()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandOrange.opacity(0.15), lineWidth: 1)
        )
    }
    
    // 7) Guided Lesson CTA
    @ViewBuilder
    private var guidedLessonCTA: some View {
        if let guidedTitle = lesson.guidedLessonTitle, let guidedHint = lesson.guidedLessonHint {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    NavigationLink(destination: {
                        ContentView(guidedLearningMode: true)
                            .environmentObject(viewModel)
                            .onAppear {
                                viewModel.guidedLearningMode = true
                                viewModel.currentGuidedLessonModule = lesson
                                viewModel.guidedOutcomeProducts = []
                                viewModel.guidedPlaygroundCompleted = false
                                viewModel.currentGuidedLesson = GuidedLesson(title: guidedTitle, hint: guidedHint)
                            }
                    }) {
                        HStack {
                            Image(systemName: "flask")
                                .font(.title3)
                                .accessibilityHidden(true)
                            Text("Try forming it in the lab!")
                                .font(.headline)
                                .bold()
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(brandOrange) // Keep the strong brand color for your CTA
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .accessibilityLabel("Try forming \(guidedTitle) in the lab.")
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - QuizOption
struct QuizOption: View {
    let option: String
    let correctOption: String
    @Binding var selectedOption: String?
    var markLessonComplete: (() -> Void)?
    
    var body: some View {
        Button(action: {
            selectedOption = option
            if option == correctOption {
                markLessonComplete?()
            }
        }) {
            Text(option)
                .font(.body)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedOption == option ? .white : .primary)
                .background(buttonBackground)
                .cornerRadius(12)
                .accessibilityLabel("Answer option: \(option)")
        }
        .padding(.horizontal, 10)
    }
    
    // Unselected: light brand orange; correct: green; incorrect: red
    private var buttonBackground: Color {
        if let selected = selectedOption, selected == option {
            return option == correctOption ? .green : .red
        } else {
            // A soft orange tint for unselected
            return .orange.opacity(0.4)
        }
    }
}
