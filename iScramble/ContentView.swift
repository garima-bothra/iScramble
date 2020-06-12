//
//  ContentView.swift
//  iScramble
//
//  Created by Garima Bothra on 12/06/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    //MARK: Variables
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        //MARK: Navigation View
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Your Score is: \(score)")
                    .padding()
                    .font(.largeTitle)
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing:
                Button("Reset"){
                    self.startGame()
            })
                .onAppear(perform: startGame)
                .alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    //MARK: Add new word to list
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isLengthValid(word: answer) else {
            wordError(title: "Word not possible", message: "Word length cannot be below three!")
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        score += answer.count
        newWord = ""
    }

    //MARK: Start/Restart the game
    func startGame() {
        self.usedWords = []
        self.score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }

    //MARK: Check if word is original
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    //MARK: Check if word is possible
    func isPossible(word: String) -> Bool {
        var copyWord = rootWord
        for letter in word {
            if let pos = copyWord.firstIndex(of: letter) {
                copyWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    //MARK: Check if word length is valid
    func isLengthValid(word: String) -> Bool {
        return word.count < 3 ? false : true
    }

    //MARK: Check if word is real
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    //MARK: Display error alert
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
