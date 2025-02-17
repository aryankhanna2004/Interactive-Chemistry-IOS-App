//  ReactionBookView.swift
import SwiftUI

/// A simple list of discovered compounds and reaction history.
struct ReactionBookView: View {
    @EnvironmentObject var viewModel: WorkspaceViewModel
    
    var body: some View {
        List {
            Section(header: Text("Discovered Compounds")) {
                // We only store formula in discoveredCompounds,
                // but you could fetch more info if needed
                ForEach(Array(viewModel.discoveredCompounds), id: \.self) { formula in
                    Text(formula)
                }
            }
            
            Section(header: Text("Reaction History")) {
                ForEach(viewModel.reactionHistory) { compound in
                    HStack {
                        Text(compound.formula).bold()
                        Text("(\(compound.commonName))")
                    }
                }
            }
        }
        .navigationTitle("Reaction Book")
    }
}

