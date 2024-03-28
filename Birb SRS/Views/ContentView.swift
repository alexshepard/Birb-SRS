//
//  ContentView.swift
//  Birb SRS
//
//  Created by Alex Shepard on 3/24/24.
//

import SwiftUI

struct ContentView: View {
    @State private var birdOrders = [Taxon]()
    @State private var quizItems = [INatObservation]()
    @State private var currentQuizItem = 0
    @State private var quizStarted = false
    @State private var choices = [Taxon]()
    @State private var questionsSeen = 0.0
    @State private var questionsCorrect = 0.0

    @State private var showingAlert = false
    @State private var alertText = ""

    var body: some View {
        Group {
            if quizStarted {
                VStack {
                    AsyncImage(url: quizItems[currentQuizItem].firstPhoto)

                    Text("Choose the order")
                    
                    ForEach(0..<3, id: \.self) { number in
                        Button {
                            choiceTapped(number)
                        } label: {
                            Text(choices[number].preferredCommonName)
                        }

                    }

                    if (questionsSeen > 0) {
                        Text("Accuracy: \(questionsCorrect / questionsSeen * 100)%")
                    }
                }
            } else {
                Button("Start Quiz") {
                    currentQuizItem = 0
                    choices = getChoices()
                    quizStarted = true
                }
                .disabled(quizItems.isEmpty || birdOrders.isEmpty)
            }
        }
        .task {
            await fetchBirdOrders()
            await fetchBirdObservations()
        }
        .alert(alertText, isPresented: $showingAlert) {
            Button("OK") {
                if currentQuizItem == quizItems.count - 1 {
                    // quiz is over
                    quizStarted = false
                    quizItems = []

                    Task {
                        await fetchBirdObservations()
                    }
                } else {
                    askQuestion()
                }
            }
        }
    }

    func choiceTapped(_ number: Int) {
        questionsSeen += 1
        let correctChoice = getCurrentObsOrder()
        if choices[number] == correctChoice {
            alertText = "Correct!"
            questionsCorrect += 1
        } else {
            alertText = "Incorrect, the correct answer was \(correctChoice?.preferredCommonName ?? "unknown")"
        }

        showingAlert = true
    }

    func askQuestion() {
        currentQuizItem += 1
        choices = getChoices()
    }

    func getCurrentObsOrder() -> Taxon? {
        let currentObsAncestry = quizItems[currentQuizItem].taxon.ancestryList
        var currentObsOrder: Taxon?
        for order in birdOrders {
            if currentObsAncestry.contains(order.id) {
                currentObsOrder = order
            }
        }
        return currentObsOrder
    }

    func getRandomBirdOrder() -> Taxon? {
        return self.birdOrders.randomElement()
    }

    func getChoices() -> [Taxon] {
        let correctTaxon = getCurrentObsOrder()
        var nextTaxon: Taxon?

        while nextTaxon == nil || nextTaxon == correctTaxon {
            nextTaxon = getRandomBirdOrder()
        }

        var nextNextTaxon: Taxon?
        while nextNextTaxon == nil || nextNextTaxon == correctTaxon || nextNextTaxon == nextTaxon {
            nextNextTaxon = getRandomBirdOrder()
        }

        guard let correctTaxon = correctTaxon,
              let nextTaxon = nextTaxon,
              let nextNextTaxon = nextNextTaxon else
        {
            print("couldn't get one of the taxa")
            print("correct is \(correctTaxon)")
            print("nextTaxon is \(nextTaxon)")
            print("nextNextTaxon is \(nextNextTaxon)")

            return []
        }

        print("correct is \(correctTaxon)")
        print("nextTaxon is \(nextTaxon)")
        print("nextNextTaxon is \(nextNextTaxon)")

        return [correctTaxon, nextTaxon, nextNextTaxon].shuffled()
    }

    func fetchBirdOrders() async {
        let birdsTaxonId = 3
        let url = URL(string: "https://api.inaturalist.org/v1/taxa?taxon_id=\(birdsTaxonId)&per_page=60&rank=order")!

        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(TaxonQueryResponse.self, from: data)

            print(decodedResponse)
            birdOrders = decodedResponse.results
        } catch let e {
            print(e)
        }
    }

    func fetchBirdObservations() async {
        let birdsTaxonId = 3
        let page = Int.random(in: 0...50)
        let url = URL(string: "https://api.inaturalist.org/v1/observations?taxon_id=\(birdsTaxonId)&per_page=30&page=\(page)")!

        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(ObsQueryResponse.self, from: data)

            print(decodedResponse)
            quizItems = decodedResponse.results.shuffled()
        } catch let e {
            print(e)
        }
    }
}

#Preview {
    ContentView()
}
