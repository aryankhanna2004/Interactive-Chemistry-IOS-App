import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    let allLessons: [LessonModule]
    
    var body: some View {
        NavigationStack {
            List(allLessons) { lesson in
                HStack {
                    VStack(alignment: .leading) {
                        Text(lesson.title)
                            .font(.headline)
                        Text(lesson.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    // For simplicity: if the lesson’s id is in completedLessons, show full progress.
                    let progressValue = viewModel.completedLessons.contains(lesson.id) ? 100.0 : 0.0
                    ProgressView(value: progressValue, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(width: 100)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Lesson Progress")
        }
    }
}
