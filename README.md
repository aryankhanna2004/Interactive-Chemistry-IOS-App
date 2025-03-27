# Interactive Chemistry Lab: A Hands-on Chemistry Learning Experience

Interactive Chemistry Lab is an iOS educational application that provides an engaging, interactive environment for learning chemistry through hands-on experimentation. The app allows users to combine elements, discover compounds, and understand chemical reactions through a visual and intuitive interface.

## About the App

Interactive Chemistry Lab addresses the challenge of making abstract chemical concepts more tangible and engaging for learners. Through an intuitive touch interface, users can:

- Experiment with chemical elements in a risk-free virtual environment
- Discover and create compounds through hands-on interaction
- Learn both IUPAC and common names for chemical substances
- Understand reaction mechanisms through visual feedback
- Track progress and earn achievements through a badge system


https://github.com/user-attachments/assets/bf1c1d58-f4bb-4d9a-91c1-5d3e258757a6


### Key Features

1. **Interactive Workspace**: A dynamic canvas where users can drag, combine, and manipulate chemical elements.
2. **Real-time Reactions**: Instant visualization of chemical reactions when compatible elements are combined.
3. **Dual Learning Modes**:
   - Playground Mode for free experimentation
   - Guided Lessons for structured learning
4. **Comprehensive Information**: Each compound includes:
   - IUPAC nomenclature
   - Common names and uses
   - Interesting facts
   - Balanced reaction equations
5. **Progress Tracking**: 
   - Achievement badges for discoveries
   - Lesson completion tracking
   - Personal dashboard with statistics

## Repository Structure
```
chem2.swiftpm/
├── MyApp.swift                    # Application entry point and main app configuration
├── ContentView.swift              # Main view controller managing the lab interface
├── ChemistryLabView.swift         # Home screen and navigation setup
├── WorkspaceViewModel.swift       # Core business logic for chemical reactions
├── ReactionRepository.swift       # Database of chemical compounds and reactions
├── CanvasViews.swift             # Canvas interface for element manipulation
├── ElementSelectionPanel.swift    # UI for selecting chemical elements
├── BadgeView.swift               # Achievement system interface
├── DashboardView.swift           # Progress tracking and statistics view
├── guidedlesson/                 # Guided learning module
│   ├── GuidedLessons.swift       # Lesson content and structure
│   └── LessonsListView.swift     # Lesson navigation interface
├── Overlays/                     # UI overlay components
│   ├── CompletionOverlay.swift   # Lesson completion feedback
│   ├── CompoundInfoPanel.swift   # Compound information display
│   └── NewDiscoveryOverlay.swift # New compound discovery notifications
└── Tutorial/                     # Tutorial system
    └── TutorialManager.swift     # Tutorial flow management
```

## Usage Instructions
### Prerequisites
- iOS 16.0 or later
- iPad or iPhone device
- Xcode 14.0 or later (for development)
- Apple Developer account (for deployment)

### Installation
1. Clone the repository:
```bash
git clone [repository-url]
cd chem2.swiftpm
```

2. Open in Xcode:
```bash
xed .
```

3. Select your target device or simulator and run the application

### Quick Start
1. Launch the application
2. Choose between:
   - **Playground Mode**: Free experimentation with chemical elements
   - **Guided Lessons**: Structured learning experience
   - **Dashboard**: Track your progress and achievements

3. Basic Interactions:
```swift
// Drag elements from the selection panel
drag(element) -> canvas

// Combine elements
place(element1) near element2

// View compound information
tap(compound)

// Break down compounds
doubleTap(compound)
```

### More Detailed Examples
1. Creating Water (H₂O):
```swift
// Drag two hydrogen atoms and one oxygen atom close together
H + H + O -> H₂O
```

2. Creating Salt (NaCl):
```swift
// Combine sodium and chlorine
Na + Cl -> NaCl
```

### Troubleshooting
1. Elements Not Combining
   - Ensure elements are placed within the reaction threshold (70 pixels)
   - Check if the elements can form a valid compound
   - Verify that elements are not overlapping

2. Tutorial Not Appearing
   - Check if `UserDefaults.standard.bool(forKey: "hasSeenTutorial122")` is false
   - Reset tutorial: `UserDefaults.standard.removeObject(forKey: "hasSeenTutorial122")`

3. Performance Issues
   - Limit the number of elements on the canvas
   - Clear unused elements using the trash icon
   - Restart the application if performance degrades

## Data Flow
The application processes chemical reactions through a state-driven architecture where element placement triggers reaction checks and compound formation.

```ascii
[Element Selection] -> [Canvas]
         ↓              ↓
[Drag Operation] -> [Placement]
         ↓              ↓
[Reaction Check] -> [Compound Formation]
         ↓              ↓
[State Update] <- [Visual Feedback]
```

Key Component Interactions:
1. WorkspaceViewModel manages element and compound state
2. ReactionRepository provides reaction rules and compound data
3. CanvasView handles element placement and drag operations
4. CompoundInfoPanel displays reaction results
5. TutorialManager guides new users through basic interactions
6. Overlays provide real-time feedback on discoveries and achievements
7. BadgeView tracks and displays user progress

https://github.com/user-attachments/assets/2000d06f-fcd2-48c2-b59d-0da044bcac01

