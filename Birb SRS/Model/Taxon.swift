//
//  Taxon.swift
//  Birb SRS
//
//  Created by Alex Shepard on 3/24/24.
//

import Foundation
import SwiftData

@Model
class Taxon {
    @Attribute(.unique) let id: Int
    let commonName: String
    let scientificName: String
    let rank: String
    
    init(id: Int, commonName: String, scientificName: String, rank: String) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.rank = rank
    }
    
    convenience init(remoteTaxon: RemoteTaxon) {
        self.init(
            id: remoteTaxon.id,
            commonName: remoteTaxon.preferredCommonName,
            scientificName: remoteTaxon.name,
            rank: remoteTaxon.rank
        )
    }
}

struct RemoteTaxon: Codable {
    let id: Int
    let name: String
    let preferredCommonName: String
    let rank: String
}

struct TaxonQueryResponse: Codable {
    let results: [RemoteTaxon]
    let totalResults: Int
    let page: Int
    let perPage: Int
}

