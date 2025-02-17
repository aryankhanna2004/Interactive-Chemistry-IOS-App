//
//  LessonsListView.swift
//  chem2
//
//  Created by ET Loaner on 2/16/25.
//

import SwiftUI

/// Holds all the content needed to build a lesson page.
struct LessonModule: Identifiable {
    let id = UUID()
    
    // Basic metadata
    let title: String
    let description: String
    
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
    
    // Guided Mode CTA
    // If these are non-nil, we'll show a "Try in the Lab" button.
    let guidedLessonTitle: String?
    let guidedLessonHint: String?
}


/// A single “lesson page” that displays everything from a LessonModule:
/// Title, body text, reaction equation, background info, a details toggle, a quiz, and a guided CTA.
struct GenericLessonView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    let lesson: LessonModule
    
    @State private var showDetails = false
    @State private var selectedAnswer: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text(lesson.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Main body text
                Text(lesson.bodyText)
                    .font(.body)
                
                // If reactionEquation is non-nil, show it
                if let eq = lesson.reactionEquation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**Reaction Equation:**")
                            .font(.headline)
                        Text(eq)
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                // Background info
                if !lesson.backgroundInformation.isEmpty {
                    ForEach(lesson.backgroundInformation, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.body)
                    }
                    Divider()
                }
                
                // Toggle to show/hide details
                Button(action: {
                    withAnimation { showDetails.toggle() }
                }) {
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if showDetails {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**\(lesson.detailHeader)**")
                            .font(.headline)
                        ForEach(lesson.detailParagraphs, id: \.self) { detail in
                            Text(detail)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // Quiz
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quiz Time!")
                        .font(.headline)
                    
                    Text(lesson.quizQuestion)
                    
                    HStack(spacing: 12) {
                        ForEach(lesson.quizOptions, id: \.self) { option in
                            QuizOption(option: option, selectedOption: $selectedAnswer)
                        }
                    }
                    
                    if let answer = selectedAnswer {
                        Text(answer == lesson.correctAnswer
                             ? "Correct!"
                             : "Oops, that's not correct. Try again!")
                        .foregroundColor(answer == lesson.correctAnswer ? .green : .red)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Spacer(minLength: 30)
                
                // If there's guided lesson info, show a CTA button
                if let guidedTitle = lesson.guidedLessonTitle,
                   let guidedHint = lesson.guidedLessonHint {
                    
                    NavigationLink(destination: {
                        // Navigate to your lab content
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
                        Text("Try forming it in the lab!")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(lesson.title)
    }
}

struct QuizOption: View {
    let option: String
    @Binding var selectedOption: String?
    
    var body: some View {
        Button(action: {
            selectedOption = option
        }) {
            Text(option)
                .padding(8)
                .background(selectedOption == option ? Color.green : Color.gray.opacity(0.3))
                .cornerRadius(8)
        }
    }
}

