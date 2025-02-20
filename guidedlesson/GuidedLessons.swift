import SwiftUI

// MARK: - Lesson & Quiz Data

struct LessonModule: Identifiable {
    let id = UUID()
    
    let title: String
    let description: String
    let emoji: String
    
    let bodyText: String
    let reactionEquation: String?
    
    let backgroundInformation: [String]
    
    let detailHeader: String
    let detailParagraphs: [String]
    
    // Quiz questions (only true/false and multiple choice)
    let quizQuestions: [QuizQuestion]
    
    let guidedLessonTitle: String?
    let guidedLessonHint: String?
    let guidedEmoji: String?
    let guidedOutcomeGoals: [String]?
}

enum QuizQuestionType {
    case multipleChoice
    case trueFalse
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let type: QuizQuestionType
    let prompt: String
    
    // For multiple choice / T/F
    let choices: [String]?
    let correctChoice: String?
}

// MARK: - GenericLessonView

struct GenericLessonView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let lesson: LessonModule
    
    @State private var showDetails = false
    
    // For the 50% overlay after quiz
    @State private var showQuizOverlay = false
    @State private var quizOverlayProgress: Double = 0
    @State private var quizNextStep: String? = nil
    
    // QUIZ STATES
    @State private var userAnswers: [UUID: String] = [:]
    @State private var questionResults: [UUID: Bool] = [:]
    @State private var quizSubmitted = false
    @State private var quizScoreString: String?
    
    // Button pop animation state
    @State private var submitButtonScale: CGFloat = 1.0
    
    // Brand color
    private let brandOrange = Color(red: 0.95, green: 0.60, blue: 0.15)

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1) Title bar
                    titleSection
                    
                    // 2) Body text
                    bodyTextSection
                    
                    // 3) Reaction equation
                    if let eq = lesson.reactionEquation {
                        reactionEquationCard(equation: eq)
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // 4) Background info
                    backgroundInfoSection
                    
                    // 5) Additional info
                    detailsToggleSection
                    
                    Divider().padding(.vertical, 8)
                    
                    // 6) Quiz
                    quizSection
                    
                    // 7) CTA to guided lesson
                    guidedLessonCTA
                        .padding(.top, 20)
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .edgesIgnoringSafeArea(.bottom)
            
            // 50% overlay if user got everything correct
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
}

// MARK: - Subviews

extension GenericLessonView {
    // 1) Title bar
    private var titleSection: some View {
        HStack {
            Text(lesson.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text(lesson.emoji)
                .font(.largeTitle)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(brandOrange)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    // 2) Body text
    private var bodyTextSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.bodyText)
                .font(.body)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandOrange.opacity(0.15), lineWidth: 1)
        )
    }
    
    // 3) Reaction card
    private func reactionEquationCard(equation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reaction Equation")
                .font(.title2)
                .bold()
                .foregroundColor(.orange)
            
            Text(equation)
                .font(.title)
                .bold()
                .foregroundColor(Color(hue: 0.65, saturation: 0.6, brightness: 0.75))
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemBackground))
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
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandOrange.opacity(0.1), lineWidth: 1)
        )
    }
    
    // 4) Background info
    @ViewBuilder
    private var backgroundInfoSection: some View {
        if !lesson.backgroundInformation.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Background Info")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.orange)
                
                ForEach(lesson.backgroundInformation, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.body)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(brandOrange.opacity(0.1), lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
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
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(brandOrange.opacity(0.1))
                .cornerRadius(12)
            }
            if showDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.detailHeader)
                        .font(.title3)
                        .bold()
                    
                    ForEach(lesson.detailParagraphs, id: \.self) { detail in
                        Text(detail)
                            .font(.body)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
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
        VStack(alignment: .leading, spacing: 16) {
            if !lesson.quizQuestions.isEmpty {
                Text("Quiz Time!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.orange)
                
                // Each question
                ForEach(lesson.quizQuestions) { question in
                    switch question.type {
                    case .multipleChoice:
                        multipleChoiceQuestion(question)
                    case .trueFalse:
                        trueFalseQuestion(question)
                    }
                }
                
                // Buttons row: Submit / Try Again
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            submitButtonScale = 1.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation {
                                submitButtonScale = 1.0
                            }
                        }
                        gradeQuiz()
                    }) {
                        Text("Submit Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(quizSubmitted ? Color.gray : Color.orange)
                            .cornerRadius(8)
                            .scaleEffect(submitButtonScale)
                    }
                    .disabled(quizSubmitted)
                    
                    if quizSubmitted {
                        Button("Try Again") {
                            resetQuiz()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                }
                
                // Display quiz score after the buttons
                if let scoreText = quizScoreString {
                    Text(scoreText)
                        .font(.headline)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var guidedLessonCTA: some View {
        if let guidedTitle = lesson.guidedLessonTitle,
           let guidedHint = lesson.guidedLessonHint {
            // HStack to center the button.
            HStack {
                Spacer()
                
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
                        if let reactionEquation = lesson.reactionEquation {
                            Text("Try forming \(reactionEquation) in the lab!")
                                .font(.headline)
                                .bold()
                        } else {
                            Text("Try forming it in the lab!")
                                .font(.title)
                                .bold()
                        }
                    }
                    .frame(minWidth: 300, minHeight: 50)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Quiz Logic

extension GenericLessonView {
    
    /// Evaluate correctness for multiple choice and true/false questions
    private func gradeQuiz() {
        quizSubmitted = true
        questionResults.removeAll()
        
        let mcTfQuestions = lesson.quizQuestions.filter {
            $0.type == .multipleChoice || $0.type == .trueFalse
        }
        
        var correctCount = 0
        for q in mcTfQuestions {
            let userAnswer = userAnswers[q.id]
            let isCorrect = (userAnswer == q.correctChoice)
            questionResults[q.id] = isCorrect
            if isCorrect { correctCount += 1 }
        }
        
        let totalCount = mcTfQuestions.count
        quizScoreString = "You got \(correctCount) out of \(totalCount) correct. Press Try Again to retake."
        
        // If quiz is fully correct and the lesson isn’t already fully complete...
        if correctCount == totalCount, totalCount > 0 {
            DispatchQueue.main.async {
                // Only update to 50% if not already 100%
                if (self.viewModel.lessonProgress[self.lesson.id] ?? 0.0) < 1.0 {
                    self.viewModel.lessonProgress[self.lesson.id] = 0.5
                }
                self.viewModel.quizCompleted = true
                self.showQuizOverlay = true
                self.quizOverlayProgress = 50
                self.quizNextStep = "Try forming it in the lab!"
            }
        }
    }

    /// Reset quiz so user can re-attempt
    private func resetQuiz() {
        quizSubmitted = false
        userAnswers.removeAll()
        questionResults.removeAll()
        quizScoreString = nil
    }
    
    // MULTIPLE CHOICE
    private func multipleChoiceQuestion(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.prompt)
                .font(.headline)
            
            if let choices = question.choices {
                ForEach(choices, id: \.self) { choice in
                    Button(action: {
                        userAnswers[question.id] = choice
                    }) {
                        HStack {
                            Text(choice)
                            Spacer()
                        }
                        .font(.body)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                        .background(buttonBackgroundForMC(question, choice: choice))
                        .cornerRadius(12)
                    }
                    .disabled(quizSubmitted)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05).cornerRadius(8))
    }
    
    private func buttonBackgroundForMC(_ question: QuizQuestion, choice: String) -> Color {
        if !quizSubmitted {
            return (userAnswers[question.id] == choice)
                ? .orange.opacity(0.4)
                : Color.gray.opacity(0.1)
        } else {
            let isCorrect = (choice == question.correctChoice)
            let userAnswer = userAnswers[question.id]
            if userAnswer == choice {
                return isCorrect ? .green : .red
            } else {
                return Color.gray.opacity(0.1)
            }
        }
    }
    
    // TRUE/FALSE
    private func trueFalseQuestion(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.prompt)
                .font(.headline)
            
            HStack(spacing: 20) {
                tfOptionButton(question, option: "True")
                tfOptionButton(question, option: "False")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05).cornerRadius(8))
    }
    
    private func tfOptionButton(_ question: QuizQuestion, option: String) -> some View {
        Button(option) {
            userAnswers[question.id] = option
        }
        .font(.body)
        .bold()
        .padding()
        .frame(minWidth: 80)
        .foregroundColor(.primary)
        .background(tfBackground(question, option: option))
        .cornerRadius(12)
        .disabled(quizSubmitted)
    }
    
    private func tfBackground(_ question: QuizQuestion, option: String) -> Color {
        if !quizSubmitted {
            return (userAnswers[question.id] == option) ? .orange.opacity(0.4) : Color.gray.opacity(0.1)
        } else {
            let correctAnswer = question.correctChoice
            if userAnswers[question.id] == option {
                return option == correctAnswer ? .green : .red
            } else {
                return Color.gray.opacity(0.1)
            }
        }
    }
}
