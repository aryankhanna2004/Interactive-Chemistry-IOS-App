import SwiftUI

struct ChemistryLabHomeView: View {
    @State private var showBadges = false
    @State private var showDashboard = false
    @StateObject private var viewModel = WorkspaceViewModel()
    
    let lessonModules: [LessonModule] = LessonModule.sampleModules
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1) Dark gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // 2) ScrollView so content can overflow
                ScrollView(.vertical, showsIndicators: true) {
                    
                    // 3) Main VStack for content
                    VStack(spacing: 25) {
                        // Logo / Top Image
                        Image("iTunesArtwork")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        // Title & Subtitle
                        Text("Chemistry Lab")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Explore chemical reactions, discover new compounds, and earn badges!")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Buttons row: Playground & Lessons
                        HStack(spacing: 20) {
                            NavigationLink {
                                ContentView(guidedLearningMode: false)
                                    .environmentObject(viewModel)
                            } label: {
                                Label("Playground", systemImage: "flask.fill")
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 4)
                            }
                            
                            NavigationLink {
                                LessonsListView()
                                    .environmentObject(viewModel)
                            } label: {
                                Label("Lessons", systemImage: "book.fill")
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 4)
                            }
                        }
                        
                        // Dashboard Button as NavigationLink instead of sheet.
                               NavigationLink(destination: DashboardView(allLessons: lessonModules)
                                               .environmentObject(viewModel)) {
                                   Label("Dashboard", systemImage: "chart.bar.fill")
                                       .font(.title2)
                                       .padding()
                                       .frame(width: 250)
                                       .background(Color.orange)
                                       .foregroundColor(.white)
                                       .cornerRadius(10)
                                       .shadow(radius: 4)
                               }

                        // Badges Button
                        Button {
                            showBadges = true
                        } label: {
                            Label("View Badges", systemImage: "trophy.fill")
                                .font(.title2)
                                .padding()
                                .frame(width: 250)
                                .background(Color(red: 0, green: 0.5, blue: 0))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        }
                        .sheet(isPresented: $showBadges) {
                            NavigationStack {
                                BadgeView(badges: viewModel.unlockedBadges)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading) {
                                            Button("Close") {
                                                showBadges = false
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    // 4) Make the VStack fill at least the screen height, so it can center if short
                    .frame(minHeight: UIScreen.main.bounds.height, alignment: .center)
                }
            }
        }
    }
}
