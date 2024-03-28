//
//  ContentView.swift
//  Birb SRS
//
//  Created by Alex Shepard on 3/24/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query let taxa: [Taxon]
    
    var body: some View {
        List(taxa) { taxon in
            Text(taxon.commonName)
                .foregroundStyle(taxon.rank == "order" ? .primary : .secondary)
        }
        .task {
            let birdsTaxonId = 3
            let url = URL(string: "https://api.inaturalist.org/v1/taxa?taxon_id=\(birdsTaxonId)&rank=order&per_page=60")!
            let request = URLRequest(url: url)
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(TaxonQueryResponse.self, from: data)
                
                
                for result in decodedResponse.results {
                    let taxon = Taxon(remoteTaxon: result)
                    modelContext.insert(taxon)
                }
                
                
                print(decodedResponse)
                
            } catch let e {
                print(e)
            }
        }
    }
}

#Preview {
    ContentView()
}
