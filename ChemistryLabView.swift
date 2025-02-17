import SwiftUI

struct ChemistryLabHomeView: View {
    @State private var showBadges = false
    @State private var showDashboard = false
    @StateObject private var viewModel = WorkspaceViewModel()
    
    // Use sample lessons from our data model (see LessonModule.swift)
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
                
                // 2) Main content in a centered VStack
                VStack {
                    Spacer()
                    
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
                        
                        // NEW: Dashboard Button
                        Button {
                            showDashboard = true
                        } label: {
                            Label("Dashboard", systemImage: "chart.bar.fill")
                                .font(.title2)
                                .padding()
                                .frame(width: 250)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        }
                        .sheet(isPresented: $showDashboard) {
                            DashboardView(allLessons: lessonModules)
                                .environmentObject(viewModel)
                        }
                        
                        // Existing Badges Button
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
            }
        }
    }
}

struct ChemistryLabHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ChemistryLabHomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
