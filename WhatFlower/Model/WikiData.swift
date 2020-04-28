//
//  WikiData.swift
//  WhatFlower
//
//  Created by Imanol Bernal on 27/04/2020.
//  Copyright © 2020 Imanol Bernal. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct WikiData: Codable {
    let batchcomplete: Bool
    let query: QueryData
}

// MARK: - Query
struct QueryData: Codable {
    let pages: [Page]
}

// MARK: - Page
struct Page: Codable {
    let pageid, ns: Int
    let title, extract: String
    let thumbnail: Thumbnail
    let pageimage: String
}

// MARK: - Thumbnail
struct Thumbnail: Codable {
    let source: String
    let width, height: Int
}


