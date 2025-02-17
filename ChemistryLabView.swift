import SwiftUI

struct ChemistryLabHomeView: View {
    @State private var showBadges = false
    @StateObject private var viewModel = WorkspaceViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("🔬 Chemistry Lab")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("Explore chemical reactions, discover new compounds, and earn badges!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Two main buttons: Playground and Lessons
                HStack(spacing: 20) {
                    NavigationLink {
                        // Playground: interactive lab without guided lesson hints
                        ContentView(guidedLearningMode: false)
                            .environmentObject(viewModel)
                    } label: {
                        Text("Playground")
                            .font(.title2)
                            .padding()
                            .frame(width: 150)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    
                    NavigationLink {
                        // Navigate to a list of lessons
                        LessonsListView()
                            .environmentObject(viewModel)
                    } label: {
                        Text("Lessons")
                            .font(.title2)
                            .padding()
                            .frame(width: 150)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                }
                
                // Badges button
                Button {
                    showBadges = true
                } label: {
                    Text("🏆 View Badges")
                        .font(.title2)
                        .padding()
                        .frame(width: 200)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                }
                .sheet(isPresented: $showBadges) {
                    NavigationStack {
                        BadgeView(badges: viewModel.unlockedBadges)
                            .navigationTitle("Your Badges")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Close") {
                                        showBadges = false
                                    }
                                }
                            }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ChemistryLabHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ChemistryLabHomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
