//
//  GuidedLessons.swift
//  chem2
//
//  Created by ET Loaner on 2/16/25.
//

import SwiftUI

struct LessonsListView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    // Our curated list of lessons
    private var lessonModules: [LessonModule] {
        [
            LessonModule(
                title: "Salt Reaction Lesson",
                description: "Sodium (Na) and Chlorine (Cl) combine to form table salt (NaCl).",
                bodyText: """
                Welcome to the Salt Reaction Lesson!

                In this lesson, you will learn how sodium (Na) reacts with chlorine (Cl) to form salt (NaCl).
                """,
                reactionEquation: "Na + Cl → NaCl",
                backgroundInformation: [
                    "**About Sodium (Na):**",
                    "Sodium is a soft, silvery-white metal that is highly reactive. It readily loses one electron during reactions.",
                    "**About Chlorine (Cl):**",
                    "Chlorine is a yellow-green gas known for its reactivity. It gains an electron to form a chloride ion."
                ],
                detailHeader: "Compound Details",
                detailParagraphs: [
                    "Formula: NaCl",
                    "Common Uses: Food seasoning, preservation.",
                    "Fun Fact: Salt was once so valuable it was used as currency!"
                ],
                quizQuestion: "Which two elements combine to form salt?",
                quizOptions: ["Na and Cl", "H and O", "O and Cl"],
                correctAnswer: "Na and Cl",
                guidedLessonTitle: "Salt Reaction",
                guidedLessonHint: "Try dragging Sodium (Na) and Chlorine (Cl) together to form Salt (NaCl)."
            ),
            
            LessonModule(
                title: "Water Reaction Lesson",
                description: "Form water (H₂O) from Hydrogen and Oxygen!",
                bodyText: """
                Water is one of the most important compounds for life. 
                In this lesson, we see how Hydrogen (H) and Oxygen (O) combine to form water (H₂O).
                """,
                reactionEquation: "2H + O → H₂O",
                backgroundInformation: [
                    "Hydrogen (H) is the lightest element, often found in diatomic form (H₂).",
                    "Oxygen (O) is a critical gas for life on Earth, typically found as O₂."
                ],
                detailHeader: "Properties of Water",
                detailParagraphs: [
                    "Formula: H₂O",
                    "Common Uses: Universal solvent, essential for life.",
                    "Fun Fact: About 60% of the human body is water!"
                ],
                quizQuestion: "What is the chemical formula for water?",
                quizOptions: ["H₂O", "CO₂", "NaCl"],
                correctAnswer: "H₂O",
                guidedLessonTitle: "Water Reaction",
                guidedLessonHint: "Try dragging Hydrogen (H) and Oxygen (O) together to form Water (H₂O)."
            ),
            
            LessonModule(
                title: "Oxygen Gas Lesson",
                description: "Discover how atomic O forms O₂ gas.",
                bodyText: """
                Oxygen gas (O₂) is essential for respiration. 
                This lesson introduces how atomic oxygen combines to form diatomic oxygen.
                """,
                reactionEquation: "2O → O₂",
                backgroundInformation: [
                    "Oxygen is the third most abundant element in the universe by mass.",
                    "Earth’s atmosphere is about 21% oxygen."
                ],
                detailHeader: "Properties of O₂",
                detailParagraphs: [
                    "Formula: O₂",
                    "Uses: Essential for breathing, steel-making, etc.",
                    "Fun Fact: O₂ has a pale blue color in liquid form."
                ],
                quizQuestion: "Which formula represents oxygen gas?",
                quizOptions: ["O", "O₂", "O₃"],
                correctAnswer: "O₂",
                guidedLessonTitle: nil,
                guidedLessonHint: nil
            ),
            
            LessonModule(
                title: "Hydrogen Gas Lesson",
                description: "See how atomic Hydrogen forms H₂ gas.",
                bodyText: """
                Hydrogen is the simplest element, with just one proton and one electron. 
                Learn how two hydrogen atoms combine to form dihydrogen (H₂).
                """,
                reactionEquation: "2H → H₂",
                backgroundInformation: [
                    "Hydrogen is the most abundant element in the universe.",
                    "It can be used in fuel cells and rocket propulsion."
                ],
                detailHeader: "Properties of H₂",
                detailParagraphs: [
                    "Formula: H₂",
                    "Lightest known gas",
                    "Fun Fact: Hydrogen makes up about 75% of the baryonic mass of the universe."
                ],
                quizQuestion: "How many H atoms are needed to form H₂?",
                quizOptions: ["1", "2", "3"],
                correctAnswer: "2",
                guidedLessonTitle: nil,
                guidedLessonHint: nil
            ),
            
            LessonModule(
                title: "Hydroxyl Radical Lesson (OH)",
                description: "Explore how Hydrogen and Oxygen can form the OH radical.",
                bodyText: """
                The hydroxyl radical (OH) is a highly reactive species found in many chemical processes.
                """,
                reactionEquation: "H + O → OH",
                backgroundInformation: [
                    "The OH radical is crucial in atmospheric chemistry for removing pollutants.",
                    "It’s often called the “detergent” of the atmosphere."
                ],
                detailHeader: "OH Properties",
                detailParagraphs: [
                    "Formula: OH",
                    "Extremely reactive intermediate.",
                    "Short-lived under normal conditions."
                ],
                quizQuestion: "Which elements combine to create the hydroxyl radical?",
                quizOptions: ["H and Cl", "Na and O", "H and O"],
                correctAnswer: "H and O",
                guidedLessonTitle: nil,
                guidedLessonHint: nil
            ),
            
            LessonModule(
                title: "Salt + Hydroxyl Lesson",
                description: "Experiment with NaCl (salt) and OH in the lab.",
                bodyText: """
                This lesson discusses a hypothetical reaction between salt (NaCl) and the hydroxyl radical (OH). 
                In real chemistry, there might be multiple steps or byproducts, but here we’ll illustrate a simplified reaction.
                """,
                reactionEquation: "NaCl + OH → NaOH + Cl",
                backgroundInformation: [
                    "NaOH (sodium hydroxide) is also called lye.",
                    "Chlorine (Cl) can be freed in some reactions, but real chemistry may require complex steps."
                ],
                detailHeader: "Possible Products",
                detailParagraphs: [
                    "NaOH is a strong base used in many industrial processes.",
                    "Chlorine can be re-used or react further."
                ],
                quizQuestion: "Which product might form from NaCl + OH in a simplified model?",
                quizOptions: ["NaOH + Cl", "NaOH + HCl", "H₂O", "Unknown"],
                correctAnswer: "NaOH + Cl",
                guidedLessonTitle: nil,
                guidedLessonHint: nil
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            List(lessonModules) { module in
                NavigationLink(destination: GenericLessonView(lesson: module)
                    .environmentObject(viewModel)) {
                    
                    VStack(alignment: .leading) {
                        Text(module.title)
                            .font(.headline)
                        Text(module.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Lessons")
        }
    }
}
