// MARK: - Lessons List View
import SwiftUI
extension LessonModule {
    /// Provide an array of sample lesson modules
    static let sampleModules: [LessonModule] = [
        
        // 1) SALT REACTION LESSON
        LessonModule(
            title: "Salt Reaction Lesson",
            description: "Sodium and Chlorine form salt (NaCl).",
            emoji: "🧂",
            bodyText: """
                Welcome to the Salt Reaction Lesson!
                Learn how sodium (Na) reacts with chlorine (Cl) to form table salt (NaCl).
                """,
            reactionEquation: "Na + Cl → NaCl",
            backgroundInformation: [
                "Sodium (Na) is a soft, silvery-white metal known for its reactivity.",
                "Chlorine (Cl) is a yellow-green gas that readily gains an electron.",
                "Historical Note: Salt was once used as currency."
            ],
            detailHeader: "Compound Details",
            detailParagraphs: [
                "Formula: NaCl",
                "Common Uses: Food seasoning, preservation.",
                "Fun Fact: The word 'salary' comes from salt."
            ],
            // Quiz types: True/False and Multiple Choice only
            quizQuestions: [
                QuizQuestion(
                    type: .trueFalse,
                    prompt: "Is NaCl commonly known as table salt?",
                    choices: ["True", "False"],
                    correctChoice: "True"
                ),
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "Which two elements combine to form salt?",
                    choices: ["Na and Cl", "H and O", "O and Cl"],
                    correctChoice: "Na and Cl"
                )
            ],
            guidedLessonTitle: "Salt Reaction",
            guidedLessonHint: "Drag Sodium (Na) and Chlorine (Cl) together in the lab to form salt (NaCl).",
            guidedEmoji: "🧂",
            guidedOutcomeGoals: ["NaCl"]
        ),
        
        // 2) WATER REACTION LESSON
        LessonModule(
            title: "Water Reaction Lesson",
            description: "Hydrogen and Oxygen form water (H₂O).",
            emoji: "💧",
            bodyText: """
                Water is essential for all known forms of life. 
                Learn how hydrogen (H) and oxygen (O) combine to form water (H₂O).
                """,
            reactionEquation: "2H + O → H₂O",
            backgroundInformation: [
                "Hydrogen (H) is the lightest element.",
                "Oxygen (O) is critical for respiration.",
                "Water is considered a universal solvent."
            ],
            detailHeader: "Properties of Water",
            detailParagraphs: [
                "Formula: H₂O",
                "Fun Fact: About 60% of the human body is water."
            ],
            // Quiz types: Multiple Choice and True/False only
            quizQuestions: [
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "What is the chemical formula for water?",
                    choices: ["H₂O", "CO₂", "NaCl"],
                    correctChoice: "H₂O"
                ),
                QuizQuestion(
                    type: .trueFalse,
                    prompt: "Is water also called dihydrogen monoxide?",
                    choices: ["True", "False"],
                    correctChoice: "True"
                )
            ],
            guidedLessonTitle: "Water Reaction",
            guidedLessonHint: "Drag Hydrogen (H) and Oxygen (O) together to form water (H₂O).",
            guidedEmoji: "💧",
            guidedOutcomeGoals: ["H₂O"]
        ),
        
        // 3) OXYGEN GAS LESSON
        LessonModule(
            title: "Oxygen Gas Lesson",
            description: "Learn how atomic oxygen forms O₂ gas.",
            emoji: "🌬️",
            bodyText: """
                Oxygen gas (O₂) is vital for respiration and combustion.
                Understand how individual oxygen atoms combine to form dioxygen.
                """,
            reactionEquation: "2O → O₂",
            backgroundInformation: [
                "Oxygen is the third most abundant element in the universe.",
                "Earth’s atmosphere is about 21% oxygen.",
                "Industrial Uses: Oxygen in steel-making, welding, etc."
            ],
            detailHeader: "Properties of O₂",
            detailParagraphs: [
                "Formula: O₂",
                "Fun Fact: Liquid oxygen is pale blue."
            ],
            quizQuestions: [
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "Which formula represents oxygen gas?",
                    choices: ["O", "O₂", "O₃"],
                    correctChoice: "O₂"
                )
            ],
            guidedLessonTitle: "Oxygen Gas Formation",
            guidedLessonHint: "Combine two oxygen atoms to see oxygen gas (O₂).",
            guidedEmoji: "🌬️",
            guidedOutcomeGoals: ["O₂"]
        ),
        
        // 4) HYDROGEN GAS LESSON
        LessonModule(
            title: "Hydrogen Gas Lesson",
            description: "Hydrogen atoms combine to form diatomic hydrogen (H₂).",
            emoji: "⚡",
            bodyText: """
                Hydrogen is the simplest, most abundant element.
                See how two hydrogen atoms combine to form H₂.
                """,
            reactionEquation: "2H → H₂",
            backgroundInformation: [
                "Hydrogen (H) has one proton and one electron.",
                "Diatomic hydrogen (H₂) is used in various energy applications.",
                "Hydrogen is the main fuel for stars."
            ],
            detailHeader: "Properties of H₂",
            detailParagraphs: [
                "Formula: H₂",
                "Fun Fact: Hydrogen gas is nearly invisible."
            ],
            quizQuestions: [
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "How many hydrogen atoms are needed to form H₂?",
                    choices: ["1", "2", "3"],
                    correctChoice: "2"
                ),
                QuizQuestion(
                    type: .trueFalse,
                    prompt: "Hydrogen is the lightest element on the periodic table.",
                    choices: ["True", "False"],
                    correctChoice: "True"
                )
            ],
            guidedLessonTitle: "Hydrogen Gas Formation",
            guidedLessonHint: "Drag two hydrogen atoms together to form H₂.",
            guidedEmoji: "⚡",
            guidedOutcomeGoals: ["H₂"]
        ),
        
        // 5) HYDROXYL RADICAL LESSON
        LessonModule(
            title: "Hydroxyl Radical Lesson (OH)",
            description: "Discover the reactivity of the hydroxyl radical (OH).",
            emoji: "🔥",
            bodyText: """
                The hydroxyl radical (OH) is a highly reactive species
                playing a key role in atmospheric chemistry.
                """,
            reactionEquation: "H + O → OH",
            backgroundInformation: [
                "OH is sometimes called the 'detergent' of the atmosphere.",
                "It is extremely reactive and short-lived.",
                "Small concentrations in the atmosphere control many pollutants."
            ],
            detailHeader: "Properties of OH",
            detailParagraphs: [
                "Formula: OH",
                "Role: Breaks down pollutants in the atmosphere.",
                "Fun Fact: OH is crucial yet present in trace amounts."
            ],
            quizQuestions: [
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "Which elements combine to create the hydroxyl radical?",
                    choices: ["H and Cl", "Na and O", "H and O"],
                    correctChoice: "H and O"
                )
            ],
            guidedLessonTitle: "Hydroxyl Radical Formation",
            guidedLessonHint: "Drag a hydrogen atom and an oxygen atom together to form OH.",
            guidedEmoji: "🔥",
            guidedOutcomeGoals: ["OH"]
        ),
        
        // 6) SALT + HYDROXYL LESSON
        LessonModule(
            title: "Salt + Hydroxyl Lesson",
            description: "Explore a reaction between salt (NaCl) and the hydroxyl radical (OH).",
            emoji: "🔬",
            bodyText: """
                A simplified model: salt (NaCl) reacting with hydroxyl (OH)
                to yield multiple products, showing the dynamic nature of chemistry.
                """,
            reactionEquation: "NaCl + OH → NaOH + Cl",
            backgroundInformation: [
                "NaCl (salt) is widely known in daily life.",
                "OH can transform salt into sodium hydroxide (NaOH) and chlorine (Cl)."
            ],
            detailHeader: "Possible Products",
            detailParagraphs: [
                "NaOH: Used in soap-making and cleaning.",
                "Cl: A reactive halogen element, used in industrial processes."
            ],
            quizQuestions: [
                QuizQuestion(
                    type: .multipleChoice,
                    prompt: "Which products form from NaCl + OH in this model?",
                    choices: ["NaOH + Cl", "NaOH + HCl", "H₂O"],
                    correctChoice: "NaOH + Cl"
                )
            ],
            guidedLessonTitle: "Salt + Hydroxyl Reaction",
            guidedLessonHint: "Drag salt (NaCl) and hydroxyl (OH) together to observe the reaction.",
            guidedEmoji: "🔬",
            guidedOutcomeGoals: ["NaOH", "Cl"]
        )
    ]
}

struct LessonsListView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    private var lessonModules: [LessonModule] {
        LessonModule.sampleModules
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Lessons")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                    
                    Text("Explore guided lessons on chemical reactions and deepen your understanding of chemistry.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
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
                    
                    Text(module.description)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .padding()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 1.0, green: 0.93, blue: 0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
