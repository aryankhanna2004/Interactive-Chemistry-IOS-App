import SwiftUI

// MARK: - Data Model

struct LessonModule: Identifiable {
    let id = UUID()
    
    // Basic metadata
    let title: String
    let description: String
    let emoji: String // Emoji for lesson (e.g., "🔬")
    
    // Main body text
    let bodyText: String
    
    // An optional reaction equation to highlight
    let reactionEquation: String?
    
    // Background info can be multiple paragraphs
    let backgroundInformation: [String]
    
    // Additional details that appear under a toggle
    let detailHeader: String
    let detailParagraphs: [String]
    
    // Quiz
    let quizQuestion: String
    let quizOptions: [String]
    let correctAnswer: String
    
    // Guided Mode CTA – if non-nil, we'll show a "Try in the Lab" button.
    let guidedLessonTitle: String?
    let guidedLessonHint: String?
    let guidedEmoji: String? // Emoji for guided lesson (e.g., "🧪")
}

// MARK: - Generic Lesson View

struct GenericLessonView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let lesson: LessonModule
    
    @State private var showDetails = false
    @State private var selectedAnswer: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title with constant background and emoji appended
                titleSection
                
                // Main body text in a card-style container
                bodyTextSection
                
                // Reaction Equation Card (if any)
                if let eq = lesson.reactionEquation {
                    reactionEquationCard(equation: eq)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Background Information
                backgroundInfoSection
                
                // Toggle to show/hide details
                detailsToggleSection
                
                Divider()
                    .padding(.vertical, 8)
                
                // Quiz Section
                quizSection
                
                Spacer(minLength: 30)
                
                // Guided Lesson CTA Button
                guidedLessonCTA
            }
            .padding()
        }
        // Use dynamic titles so it adapts to smaller screens
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Subviews
    
    private var titleSection: some View {
        HStack {
            Text(lesson.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                // Let large titles scale down if needed
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(lesson.emoji)
                .font(.largeTitle)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue) // Constant theme color for the title
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine) // Combine text + emoji for VoiceOver
        .accessibilityLabel("\(lesson.title) \(lesson.emoji)")
    }
    
    private var bodyTextSection: some View {
        Text(lesson.bodyText)
            .font(.body)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .accessibilityElement()
            .accessibilityLabel(lesson.bodyText)
    }
    
    private func reactionEquationCard(equation: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Reaction Equation:")
                .font(.headline)
                .bold()
            Text(equation)
                .font(.title)
                .foregroundColor(.orange)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .shadow(radius: 2)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reaction Equation: \(equation)")
    }
    
    @ViewBuilder
    private var backgroundInfoSection: some View {
        if !lesson.backgroundInformation.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(lesson.backgroundInformation, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.body)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                        .accessibilityElement()
                        .accessibilityLabel(paragraph)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.05))
            )
        }
    }
    
    private var detailsToggleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.blue)
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .accessibilityLabel(showDetails ? "Hide extra details" : "Show extra details")
            }
            
            if showDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.detailHeader)
                        .font(.headline)
                        .bold()
                    ForEach(lesson.detailParagraphs, id: \.self) { detail in
                        Text(detail)
                            .font(.body)
                            .accessibilityLabel(detail)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
                .transition(.opacity)
            }
        }
    }
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quiz Time! 🧠")
                .font(.headline)
                .bold()
                .padding(.bottom, 4)
            
            Text(lesson.quizQuestion)
                .font(.body)
                .bold()
            
            VStack(spacing: 10) {
                ForEach(lesson.quizOptions, id: \.self) { option in
                    QuizOption(option: option, selectedOption: $selectedAnswer)
                }
            }
            
            if let answer = selectedAnswer {
                let feedback = (answer == lesson.correctAnswer)
                    ? "✅ Correct!"
                    : "❌ Oops, that's not correct. Try again!"
                
                Text(feedback)
                    .foregroundColor(answer == lesson.correctAnswer ? .green : .red)
                    .bold()
                    .accessibilityLabel(feedback)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var guidedLessonCTA: some View {
        if let guidedTitle = lesson.guidedLessonTitle,
           let guidedHint = lesson.guidedLessonHint {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    NavigationLink(destination: {
                        ContentView(guidedLearningMode: true)
                            .environmentObject(viewModel)
                            .onAppear {
                                viewModel.guidedLearningMode = true
                                viewModel.currentGuidedLesson = GuidedLesson(
                                    title: guidedTitle,
                                    hint: guidedHint
                                )
                            }
                    }) {
                        HStack {
                            Image(systemName: "flask")
                                .font(.title3)
                                .accessibilityHidden(true)
                            Text("Try forming it in the lab!")
                                .font(.headline)  // Smaller than before
                                .bold()
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        // Removed the .frame(maxWidth: .infinity) to make the button smaller
                        .background(Color.blue)
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

// MARK: - Quiz Option View

struct QuizOption: View {
    let option: String
    @Binding var selectedOption: String?
    
    var body: some View {
        Button(action: {
            selectedOption = option
        }) {
            Text(option)
                .font(.body)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                // Use dark green for selected, ensuring white text for contrast
                .foregroundColor(selectedOption == option ? .white : .primary)
                .background(selectedOption == option
                            ? Color(red: 0.0, green: 0.5, blue: 0.0)  // Dark green
                            : Color.gray.opacity(0.3))
                .cornerRadius(12)
                .accessibilityLabel("Answer option: \(option)")
        }
        .padding(.horizontal, 10)
    }
}
