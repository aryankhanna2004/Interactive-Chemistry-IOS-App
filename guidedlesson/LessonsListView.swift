// MARK: - Lessons List View
import SwiftUI

extension LessonModule {
    static let sampleModules: [LessonModule] = [
        LessonModule(
            title: "Salt Reaction Lesson",
            description: "Sodium and Chlorine form salt (NaCl).",
            emoji: "🧂",
            bodyText: """
            Welcome to the Salt Reaction Lesson!

            In this lesson, you will learn how sodium (Na) reacts with chlorine (Cl) to form table salt (NaCl). Discover the rich history of salt, its industrial uses, and why it was once a prized commodity.
            """,
            reactionEquation: "Na + Cl → NaCl",
            backgroundInformation: [
                "Sodium (Na) is a soft, silvery-white metal known for its reactivity. It loses an electron easily, making it highly reactive with nonmetals.",
                "Chlorine (Cl) is a yellow-green gas that readily gains an electron to form chloride ions. Its reactivity makes it useful in various chemical processes.",
                "Historical Note: Salt was so valuable in ancient times that it was used as currency and for trade."
            ],
            detailHeader: "Compound Details",
            detailParagraphs: [
                "Formula: NaCl",
                "Common Uses: Food seasoning, preservation, and industrial applications.",
                "Fun Fact: The word 'salary' originates from the Latin word for salt, reflecting its historic value."
            ],
            quizQuestion: "Which two elements combine to form salt?",
            quizOptions: ["Na and Cl", "H and O", "O and Cl"],
            correctAnswer: "Na and Cl",
            guidedLessonTitle: "Salt Reaction",
            guidedLessonHint: "Drag Sodium (Na) and Chlorine (Cl) together in the lab to form salt (NaCl).",
            guidedEmoji: "🧂",
            // Outcome goal: For this guided lesson, expect salt to be formed.
            guidedOutcomeGoals: ["NaCl"]
        ),
        LessonModule(
            title: "Water Reaction Lesson",
            description: "Hydrogen and Oxygen form water (H₂O).",
            emoji: "💧",
            bodyText: """
            Water is essential for all known forms of life. In this lesson, explore how hydrogen (H) and oxygen (O) combine to form water (H₂O). Learn about water's unique properties, its role as a universal solvent, and its significance in nature.
            """,
            reactionEquation: "2H + O → H₂O",
            backgroundInformation: [
                "Hydrogen (H) is the lightest element in the periodic table, often found in its diatomic form (H₂).",
                "Oxygen (O) is critical for respiration and is typically present as O₂ in the atmosphere.",
                "Water's polarity makes it an excellent solvent for a wide range of substances, influencing countless biological and chemical processes."
            ],
            detailHeader: "Properties of Water",
            detailParagraphs: [
                "Formula: H₂O",
                "Key Uses: Drinking, agriculture, industry, and countless biological functions.",
                "Fun Fact: Approximately 60% of the human body is made up of water."
            ],
            quizQuestion: "What is the chemical formula for water?",
            quizOptions: ["H₂O", "CO₂", "NaCl"],
            correctAnswer: "H₂O",
            guidedLessonTitle: "Water Reaction",
            guidedLessonHint: "Drag Hydrogen (H) and Oxygen (O) together to form water (H₂O).",
            guidedEmoji: "💧",
            guidedOutcomeGoals: ["H₂O"]
        ),
        LessonModule(
            title: "Oxygen Gas Lesson",
            description: "Learn how atomic oxygen forms O₂ gas.",
            emoji: "🌬️",
            bodyText: """
            Oxygen gas (O₂) is vital for respiration and combustion. In this lesson, understand how individual oxygen atoms combine to form diatomic oxygen. Delve into its properties, importance in Earth's atmosphere, and industrial applications.
            """,
            reactionEquation: "2O → O₂",
            backgroundInformation: [
                "Oxygen is the third most abundant element in the universe by mass.",
                "On Earth, oxygen gas constitutes about 21% of the atmosphere and is crucial for the survival of most organisms.",
                "Industrial Uses: Oxygen is used in steel-making, welding, and medical applications."
            ],
            detailHeader: "Properties of O₂",
            detailParagraphs: [
                "Formula: O₂",
                "Visual Note: Liquid oxygen has a pale blue color.",
                "Fun Fact: Despite being a colorless gas, liquid oxygen is distinctly blue."
            ],
            quizQuestion: "Which formula represents oxygen gas?",
            quizOptions: ["O", "O₂", "O₃"],
            correctAnswer: "O₂",
            guidedLessonTitle: "Oxygen Gas Formation",
            guidedLessonHint: "Combine two oxygen atoms to see oxygen gas (O₂) form.",
            guidedEmoji: "🌬️",
            guidedOutcomeGoals: ["O₂"]
        ),
        LessonModule(
            title: "Hydrogen Gas Lesson",
            description: "Hydrogen atoms combine to form diatomic hydrogen (H₂).",
            emoji: "⚡",
            bodyText: """
            Hydrogen is the simplest and most abundant element in the universe. This lesson demonstrates how two hydrogen atoms combine to form diatomic hydrogen (H₂), and explores its properties, applications in energy, and its role in the cosmos.
            """,
            reactionEquation: "2H → H₂",
            backgroundInformation: [
                "Hydrogen (H) has one proton and one electron, making it the simplest atom.",
                "Diatomic hydrogen (H₂) is used as a fuel in various energy applications, including fuel cells.",
                "Cosmic Significance: Hydrogen is the primary building block for stars and galaxies."
            ],
            detailHeader: "Properties of H₂",
            detailParagraphs: [
                "Formula: H₂",
                "Characteristic: It is the lightest and most abundant gas in the universe.",
                "Fun Fact: Hydrogen gas is nearly invisible but can be detected by its distinct sound when ignited."
            ],
            quizQuestion: "How many hydrogen atoms are needed to form diatomic hydrogen (H₂)?",
            quizOptions: ["1", "2", "3"],
            correctAnswer: "2",
            guidedLessonTitle: "Hydrogen Gas Formation",
            guidedLessonHint: "Drag two hydrogen atoms together to form H₂.",
            guidedEmoji: "⚡",
            guidedOutcomeGoals: ["H₂"]
        ),
        LessonModule(
            title: "Hydroxyl Radical Lesson (OH)",
            description: "Discover the reactivity of the hydroxyl radical (OH).",
            emoji: "🔥",
            bodyText: """
            The hydroxyl radical (OH) is a highly reactive molecule that plays a key role in atmospheric chemistry. In this lesson, learn how a hydrogen atom and an oxygen atom can form the hydroxyl radical, its role in breaking down pollutants, and its transient nature.
            """,
            reactionEquation: "H + O → OH",
            backgroundInformation: [
                "OH is known as the 'detergent' of the atmosphere due to its ability to react with many pollutants.",
                "It is extremely reactive and short-lived under normal conditions.",
                "Scientific Insight: The presence of OH is crucial for maintaining the balance of various atmospheric chemicals."
            ],
            detailHeader: "Properties of OH",
            detailParagraphs: [
                "Formula: OH",
                "Role: Initiates the breakdown of pollutants and organic compounds in the atmosphere.",
                "Fun Fact: Despite its high reactivity, OH radicals are present in only trace amounts in the air."
            ],
            quizQuestion: "Which elements combine to create the hydroxyl radical?",
            quizOptions: ["H and Cl", "Na and O", "H and O"],
            correctAnswer: "H and O",
            guidedLessonTitle: "Hydroxyl Radical Formation",
            guidedLessonHint: "Drag a hydrogen atom and an oxygen atom together to form OH.",
            guidedEmoji: "🔥",
            guidedOutcomeGoals: ["OH"]
        ),
        LessonModule(
            title: "Salt + Hydroxyl Lesson",
            description: "Explore a reaction between salt (NaCl) and the hydroxyl radical (OH).",
            emoji: "🔬",
            bodyText: """
            In this lesson, we explore a simplified model of a reaction between salt (NaCl) and the hydroxyl radical (OH). Although real-world chemistry may be more complex, this demonstration shows how different reactants can yield multiple products, highlighting the dynamic nature of chemical reactions.
            """,
            reactionEquation: "NaCl + OH → NaOH + Cl",
            backgroundInformation: [
                "NaCl (salt) is a familiar compound used in everyday life for seasoning and preservation.",
                "The hydroxyl radical (OH) can interact with salt under specific conditions to produce sodium hydroxide (NaOH) and chlorine (Cl).",
                "This reaction is presented as a simplified model for educational purposes."
            ],
            detailHeader: "Possible Products",
            detailParagraphs: [
                "Simplified Reaction: NaCl + OH → NaOH + Cl",
                "Sodium Hydroxide (NaOH): Widely used in industry for cleaning and soap making.",
                "Chlorine (Cl): Can be a reactive intermediate in further chemical processes."
            ],
            quizQuestion: "Which product might form from NaCl + OH in this model?",
            quizOptions: ["NaOH + Cl", "NaOH + HCl", "H₂O", "Unknown"],
            correctAnswer: "NaOH + Cl",
            guidedLessonTitle: "Salt + Hydroxyl Reaction",
            guidedLessonHint: "Drag salt (NaCl) and hydroxyl (OH) together to observe the reaction.",
            guidedEmoji: "🔬",
            guidedOutcomeGoals: ["NaOH", "Cl"]  // In this lesson, two products are expected.
        )
    ]
}

import SwiftUI

struct LessonsListView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    private var lessonModules: [LessonModule] {
        LessonModule.sampleModules
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Large heading and description below the back button.
                    Text("Lessons")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                    
                    Text("Explore guided lessons on chemical reactions and deepen your understanding of chemistry.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // List of lessons
                    LazyVStack(spacing: 24) {
                        ForEach(lessonModules) { module in
                            NavigationLink(destination:
                                GenericLessonView(lesson: module)
                                    .environmentObject(viewModel)
                            ) {
                                LessonRow(module: module)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            // Hide the default title text in the navigation bar but keep the bar (and back button).
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - LessonRow Subview

extension LessonsListView {
    struct LessonRow: View {
        let module: LessonModule
        
        var body: some View {
            HStack {
                Text(module.guidedEmoji ?? "")
                    .font(.system(size: 40))
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.primary)
                    
                    // Darker subtext for readability
                    Text(module.description)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                }
                Spacer()
                
                // Dark arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .padding()
            }
            .padding()
            .background(
                // Pastel orange fill
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 1.0, green: 0.93, blue: 0.85))
            )
            .overlay(
                // Dark orange border
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
