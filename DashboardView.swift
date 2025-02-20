import SwiftUI

// Define an accessible orange for progress indicators.
let accessibleOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
// Define a darker orange for headings and reaction text.
let darkerOrange = Color(red: 0.9, green: 0.4, blue: 0.1)

struct LessonProgressData: Identifiable {
    let id: UUID
    let title: String
    let progress: Double // 0.0, 0.5, or 1.0
}

struct DashboardView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let allLessons: [LessonModule]
    
    // Convert lesson data to chart data using our lessonProgress dictionary.
    var progressData: [LessonProgressData] {
        allLessons.map { lesson in
            LessonProgressData(
                id: lesson.id,
                title: lesson.title,
                progress: viewModel.lessonProgress[lesson.id] ?? 0.0
            )
        }
    }
    
    // Overall progress: average progress across all lessons * 100.
    var overallProgress: Double {
        guard !allLessons.isEmpty else { return 0 }
        let total = progressData.reduce(0) { $0 + $1.progress }
        return (total / Double(allLessons.count)) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Overall Progress
                    overallProgressCard
                    
                    // MARK: - Lesson Completion
                    lessonCompletionSection
                    
                    // MARK: - Possible Reactions
                    possibleReactionsSection
                    
                    // MARK: - Discovered Compounds
                    discoveredCompoundsSection
                    
                    // MARK: - Reaction History
                    reactionHistorySection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Dashboard")
            .background(
                // Dark gradient background for the entire page.
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

// MARK: - Subviews

extension DashboardView {
    
    // MARK: Overall Progress Card
    private var overallProgressCard: some View {
        VStack(spacing: 12) {
            Text("Overall Progress")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(accessibleOrange)
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(overallProgress / 100, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(accessibleOrange)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.linear, value: overallProgress)
                
                Text(String(format: "%.0f%%", overallProgress))
                    .font(.title)
                    .bold()
                    .foregroundColor(accessibleOrange)
            }
            .frame(width: 150, height: 150)
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)  // Always white background for contrast
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    // MARK: Lesson Completion Section
    private var lessonCompletionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lesson Completion")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(allLessons) { lesson in
                HStack {
                    Text(lesson.emoji)
                        .font(.largeTitle)
                        .padding(.trailing, 6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                        Text(lesson.description)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.5))
                    }
                    Spacer()
                    
                    ProgressView(value: viewModel.lessonProgress[lesson.id] ?? 0.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: accessibleOrange))
                        .frame(width: 60)
                }
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    // MARK: Possible Reactions Section
    private var possibleReactionsSection: some View {
        let reactions = ReactionRepository.shared.balancedReactions
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Possible Reactions")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(reactions.indices, id: \.self) { idx in
                let reaction = reactions[idx]
                Text(reaction.equationString)
                    .font(.subheadline)
                    .foregroundColor(darkerOrange)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    // MARK: Discovered Compounds Section
    private var discoveredCompoundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discovered Compounds")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.discoveredCompounds.isEmpty {
                Text("No compounds discovered yet.")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.5))
            } else {
                ForEach(Array(viewModel.discoveredCompounds), id: \.self) { formula in
                    Text(formula)
                        .font(.subheadline)
                        .padding(.vertical, 2)
                        .foregroundColor(darkerOrange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    // MARK: Reaction History Section
    private var reactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reaction History")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.reactionHistory.isEmpty {
                Text("No reactions performed yet.")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.5))
            } else {
                ForEach(viewModel.reactionHistory) { compound in
                    HStack {
                        Text(compound.formula)
                            .bold()
                            .foregroundColor(darkerOrange)
                        Text("(\(compound.commonName))")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.5))
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
