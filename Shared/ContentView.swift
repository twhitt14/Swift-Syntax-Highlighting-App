//
//  ContentView.swift
//  Shared
//
//  Created by Trevor Whittingham on 4/12/22.
//

import SwiftUI
import Splash

class ViewModel: ObservableObject {
    @Published var text = ""
    @Published var highlightedText = ""
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.text)
                .border(.tertiary)
                .overlay {
                    Text(viewModel.text.isEmpty ? "Enter Swift code to begin highlighting" : "")
                        .allowsHitTesting(false)
                }
            
            Button {
                highlightText()
            } label: {
                Text("Highlight")
            }
            .keyboardShortcut(.return)

            TextEditor(text: .constant(viewModel.highlightedText))
                .border(.tertiary)
            
            Button {
                copyResultText()
            } label: {
                Text("Copy Result")
            }
            .keyboardShortcut("c")
        }
        .padding()
    }
    
    func highlightText() {
        viewModel.highlightedText = highlighter.highlight(viewModel.text)
    }
    
    func copyResultText() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(viewModel.highlightedText, forType: .string)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
