//
//  ContentView.swift
//  Shared
//
//  Created by Trevor Whittingham on 4/12/22.
//

import SwiftUI
import Combine
import Splash

enum OutputType: CaseIterable {
    case html, attributedString
    
    var description: String {
        switch self {
        case .html:
            return "HTML"
        case .attributedString:
            return "Attributed String"
        }
    }
}

class ViewModel: ObservableObject {
    @Published var outputFormat: OutputType = .html
    @Published var inputText = ""
    @Published var highlightedText: NSAttributedString = .init(string: "")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $outputFormat.sink { [weak self] _ in
            self?.highlightText()
        }.store(in: &cancellables)
    }
    
    func highlightText() {
        guard !inputText.isEmpty else {
            highlightedText = .init(string: "")
            return
        }
        
        switch outputFormat {
        case .attributedString:
            let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: .midnight(withFont: .init(size: 12))))
            highlightedText = highlighter.highlight(inputText)
        case .html:
            let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
            let highlightedTextWithCodeTags = """
                <pre>
                <code>
                \(highlighter.highlight(inputText))
                </code>
                </pre>
                """
            highlightedText = .init(string: highlightedTextWithCodeTags)
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Picker("Syntax type", selection: $viewModel.outputFormat) {
                    ForEach(OutputType.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
                .pickerStyle(.segmented)
                
                Spacer()
                    .layoutPriority(0)
            }
            
            TextEditor(text: $viewModel.inputText)
                .border(.tertiary)
                .overlay {
                    Text(viewModel.inputText.isEmpty ? "Enter Swift code to begin highlighting" : "")
                        .allowsHitTesting(false)
                }
            
            Button {
                highlightText()
            } label: {
                Text("Highlight (⌘ + enter)")
            }
            .keyboardShortcut(.return)

            switch viewModel.outputFormat {
            case .html:
                TextEditor(text: .constant(viewModel.highlightedText.string))
                    .border(.tertiary)
                
            case .attributedString:
                Text(AttributedString(viewModel.highlightedText))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                copyResultText()
            } label: {
                Text("Copy Result (shift + ⌘ + c)")
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
        }
        .padding()
    }
    
    func highlightText() {
        viewModel.highlightText()
    }
    
    func copyResultText() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([viewModel.highlightedText])
//            .setString(viewModel.highlightedText, forType: .string)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
