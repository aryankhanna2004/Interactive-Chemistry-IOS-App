import SwiftUI

struct ChemistryLabHomeView: View {
    @State private var showBadges = false
    @StateObject private var viewModel = WorkspaceViewModel()
    
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
                
                // 2) Use a parent VStack to center content vertically
                VStack {
                    Spacer() // Push content down from the top
                    
                    VStack(spacing: 25) {
                        // 2) Logo or Top Image
                        Image("iTunesArtwork")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        // 3) Title
                        Text("Chemistry Lab")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // 4) Subtitle
                        Text("Explore chemical reactions, discover new compounds, and earn badges!")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // 5) Buttons row
                        HStack(spacing: 20) {
                            // Playground Button
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
                            
                            // Lessons Button
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
                        
                        // 6) Badges Button
                        Button {
                            showBadges = true
                        } label: {
                            Label("View Badges", systemImage: "trophy.fill")
                                .font(.title2)
                                .padding()
                                .frame(width: 250)
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer() // Push content up from the bottom
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
