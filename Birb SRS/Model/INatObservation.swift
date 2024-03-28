//
//  INatObservation.swift
//  Birb SRS
//
//  Created by Alex Shepard on 3/27/24.
//

import Foundation

struct INatObservation: Codable {
    let uuid: UUID
    let taxon: Taxon
    let observationPhotos: [INatObservationPhoto]

    var firstPhoto: URL? {
        self.observationPhotos.first?.photo.mediumUrl
    }
}

struct INatObservationPhoto: Codable {
    let uuid: UUID
    let photo: INatPhoto
}

struct INatPhoto: Codable {
    let id: Int
    let url: URL

    var mediumUrl: URL {
        URL(string: url.absoluteString.replacingOccurrences(of: "square", with: "medium"))!
    }
}

struct ObsQueryResponse: Codable {
    let results: [INatObservation]
    let totalResults: Int
    let page: Int
    let perPage: Int
}

struct Taxon: Codable, Equatable {
    let id: Int
    let name: String
    let preferredCommonName: String
    let ancestry: String

    var ancestryList: [Int] {
        ancestry.split(separator: "/").compactMap { Int($0) }
    }

    static func == (lhs: Taxon, rhs: Taxon) -> Bool {
        lhs.id == rhs.id
    }
}

struct TaxonQueryResponse: Codable {
    let results: [Taxon]
    let totalResults: Int
    let page: Int
    let perPage: Int
}
