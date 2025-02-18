import SwiftUI

// MARK: - Overlay Example

struct LessonProgressOverlay: View {
    let lessonName: String
    let currentProgress: Double  // value from 0 to 100
    let nextStep: String?
    let dismissAction: () -> Void

    @State private var animatedProgress: Double = 0
    @State private var showConfetti: Bool = false

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            // Main card
            VStack(spacing: 24) {
                Text(lessonName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: CGFloat(animatedProgress / 100))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .frame(width: 150, height: 150)
                        .animation(.easeInOut(duration: 1.0), value: animatedProgress)

                    Text("\(Int(animatedProgress))%")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                }

                if animatedProgress < 100, let next = nextStep {
                    Text("Next: \(next)")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("Great Job! Lesson Complete!")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    dismissAction()
                }) {
                    Text("Dismiss")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 32)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 8)

            // Confetti if 100% complete
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            animatedProgress = currentProgress
        }
        .onChange(of: animatedProgress) { newValue in
            // Trigger confetti on 100% completion
            if newValue == 100 {
                showConfetti = true
            }
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                confettiPieces = generateConfetti(in: geometry.size)
                withAnimation(Animation.linear(duration: 3.0)) {
                    for index in confettiPieces.indices {
                        confettiPieces[index].position.y += geometry.size.height
                        confettiPieces[index].opacity = 0
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func generateConfetti(in size: CGSize) -> [ConfettiPiece] {
        var pieces: [ConfettiPiece] = []
        for _ in 0..<50 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: -50...0)
            let piece = ConfettiPiece(
                position: CGPoint(x: x, y: y),
                size: CGFloat.random(in: 5...10),
                color: [Color.red, Color.green, Color.blue, Color.yellow].randomElement() ?? Color.white,
                opacity: 1.0
            )
            pieces.append(piece)
        }
        return pieces
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double
}
