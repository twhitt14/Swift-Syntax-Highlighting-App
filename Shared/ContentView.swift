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
    @Published var outputType: OutputType = .html
    @Published var inputText = ""
    @Published var highlightedText: NSAttributedString = .init(string: "")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $outputType.sink { [weak self] outputType in
            // need to use value from sink closure instead of `outputType` property or we can get out of sync
            self?.highlightText(outputType: outputType)
        }.store(in: &cancellables)
    }
    
    func highlightText(outputType: OutputType? = nil) {
        guard !inputText.isEmpty else {
            highlightedText = .init(string: "")
            return
        }
        
        switch outputType ?? self.outputType {
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
                Picker("Syntax type", selection: $viewModel.outputType) {
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

            ScrollView {
                Text(AttributedString(viewModel.highlightedText))
                    .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .border(.tertiary)
            
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
