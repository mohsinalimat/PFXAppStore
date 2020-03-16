//
//  AppStoreModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

struct AppStoreModel: Codable {
    var screenshotUrls = [String]()
    var ipadScreenshotUrls = [String]()
    var appletvScreenshotUrls = [String]()
    var artworkUrl60 = ""
    var artworkUrl512 = ""
    var artworkUrl100 = ""
    var artistViewUrl = ""
    var supportedDevices = [String]()
    var advisories = [String]()
    var isGameCenterEnabled = false
    var kind = ""
    var features = [String]()
    var trackCensoredName = ""
    var languageCodesISO2A = [String]()
    var fileSizeBytes = ""
    var sellerUrl = ""
    var contentAdvisoryRating = ""
    var trackViewUrl = ""
    var trackContentRating = ""
    var trackId = 0
    var trackName = ""
    var genreIds = [String]()
    var formattedPrice = ""
    var primaryGenreName = ""
    var isVppDeviceBasedLicensingEnabled = false
    var releaseDate = ""
    var minimumOsVersion = ""
    var sellerName = ""
    var currentVersionReleaseDate = ""
    var releaseNotes = ""
    var primaryGenreId = 0
    var currency = ""
    var version = ""
    var wrapperType = ""
    var artistId = 0
    var artistName = ""
    var genres = [String]()
    var price = 0.0
    var description = ""
    var bundleId = ""
    var averageUserRating = 0.0
    var userRatingCount = 0

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        if let screenshotUrls = try container.decodeIfPresent(Array<String>.self, forKey: .screenshotUrls) { self.screenshotUrls = screenshotUrls }
        if let ipadScreenshotUrls = try container.decodeIfPresent(Array<String>.self, forKey: .ipadScreenshotUrls) { self.ipadScreenshotUrls = ipadScreenshotUrls }
        if let appletvScreenshotUrls = try container.decodeIfPresent(Array<String>.self, forKey: .appletvScreenshotUrls) { self.appletvScreenshotUrls = appletvScreenshotUrls }
        if let artworkUrl60 = try container.decodeIfPresent(String.self, forKey: .artworkUrl60) { self.artworkUrl60 = artworkUrl60 }
        if let artworkUrl512 = try container.decodeIfPresent(String.self, forKey: .artworkUrl512) { self.artworkUrl512 = artworkUrl512 }
        if let artworkUrl100 = try container.decodeIfPresent(String.self, forKey: .artworkUrl100) { self.artworkUrl100 = artworkUrl100 }
        if let artistViewUrl = try container.decodeIfPresent(String.self, forKey: .artistViewUrl) { self.artistViewUrl = artistViewUrl }
        if let supportedDevices = try container.decodeIfPresent(Array<String>.self, forKey: .supportedDevices) { self.supportedDevices = supportedDevices }
        if let advisories = try container.decodeIfPresent(Array<String>.self, forKey: .advisories) { self.advisories = advisories }
        if let isGameCenterEnabled = try container.decodeIfPresent(Bool.self, forKey: .isGameCenterEnabled) { self.isGameCenterEnabled = isGameCenterEnabled }
        if let kind = try container.decodeIfPresent(String.self, forKey: .kind) { self.kind = kind }
        if let features = try container.decodeIfPresent(Array<String>.self, forKey: .features) { self.features = features }
        if let trackCensoredName = try container.decodeIfPresent(String.self, forKey: .trackCensoredName) { self.trackCensoredName = trackCensoredName }
        if let languageCodesISO2A = try container.decodeIfPresent(Array<String>.self, forKey: .languageCodesISO2A) { self.languageCodesISO2A = languageCodesISO2A }
        if let fileSizeBytes = try container.decodeIfPresent(String.self, forKey: .fileSizeBytes) { self.fileSizeBytes = fileSizeBytes }
        if let sellerUrl = try container.decodeIfPresent(String.self, forKey: .sellerUrl) { self.sellerUrl = sellerUrl }
        if let contentAdvisoryRating = try container.decodeIfPresent(String.self, forKey: .contentAdvisoryRating) { self.contentAdvisoryRating = contentAdvisoryRating }
        if let trackViewUrl = try container.decodeIfPresent(String.self, forKey: .trackViewUrl) { self.trackViewUrl = trackViewUrl }
        if let trackContentRating = try container.decodeIfPresent(String.self, forKey: .trackContentRating) { self.trackContentRating = trackContentRating }
        if let trackId = try container.decodeIfPresent(Int.self, forKey: .trackId) { self.trackId = trackId }
        if let trackName = try container.decodeIfPresent(String.self, forKey: .trackName) { self.trackName = trackName }
        if let genreIds = try container.decodeIfPresent(Array<String>.self, forKey: .genreIds) { self.genreIds = genreIds }
        if let formattedPrice = try container.decodeIfPresent(String.self, forKey: .formattedPrice) { self.formattedPrice = formattedPrice }
        if let primaryGenreName = try container.decodeIfPresent(String.self, forKey: .primaryGenreName) { self.primaryGenreName = primaryGenreName }
        if let isVppDeviceBasedLicensingEnabled =
            try container.decodeIfPresent(Bool.self, forKey: .isVppDeviceBasedLicensingEnabled) { self.isVppDeviceBasedLicensingEnabled = isVppDeviceBasedLicensingEnabled }
        if let releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) { self.releaseDate = releaseDate }
        if let minimumOsVersion = try container.decodeIfPresent(String.self, forKey: .minimumOsVersion) { self.minimumOsVersion = minimumOsVersion }
        if let sellerName = try container.decodeIfPresent(String.self, forKey: .sellerName) { self.sellerName = sellerName }
        if let currentVersionReleaseDate = try container.decodeIfPresent(String.self, forKey: .currentVersionReleaseDate) { self.currentVersionReleaseDate = currentVersionReleaseDate }
        if let releaseNotes = try container.decodeIfPresent(String.self, forKey: .releaseNotes) { self.releaseNotes = releaseNotes }
        if let primaryGenreId = try container.decodeIfPresent(Int.self, forKey: .primaryGenreId) { self.primaryGenreId = primaryGenreId }
        if let currency = try container.decodeIfPresent(String.self, forKey: .currency) { self.currency = currency }
        if let version = try container.decodeIfPresent(String.self, forKey: .version) { self.version = version }
        if let wrapperType = try container.decodeIfPresent(String.self, forKey: .wrapperType) { self.wrapperType = wrapperType }
        if let artistId = try container.decodeIfPresent(Int.self, forKey: .artistId) { self.artistId = artistId }
        if let artistName = try container.decodeIfPresent(String.self, forKey: .artistName) { self.artistName = artistName }
        if let genres = try container.decodeIfPresent(Array<String>.self, forKey: .genres) { self.genres = genres }
        if let price = try container.decodeIfPresent(Double.self, forKey: .price) { self.price = price }
        if let description = try container.decodeIfPresent(String.self, forKey: .description) { self.description = description }
        if let bundleId = try container.decodeIfPresent(String.self, forKey: .bundleId) { self.bundleId = bundleId }
        if let averageUserRating = try container.decodeIfPresent(Double.self, forKey: .averageUserRating) { self.averageUserRating = averageUserRating }
        if let userRatingCount = try container.decodeIfPresent(Int.self, forKey: .userRatingCount) { self.userRatingCount = userRatingCount }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(screenshotUrls, forKey: .screenshotUrls)
        try container.encode(ipadScreenshotUrls, forKey: .ipadScreenshotUrls)
        try container.encode(appletvScreenshotUrls, forKey: .appletvScreenshotUrls)
        try container.encode(artworkUrl60, forKey: .artworkUrl60)
        try container.encode(artworkUrl512, forKey: .artworkUrl512)
        try container.encode(artworkUrl100, forKey: .artworkUrl100)
        try container.encode(artistViewUrl, forKey: .artistViewUrl)
        try container.encode(supportedDevices, forKey: .supportedDevices)
        try container.encode(advisories, forKey: .advisories)
        try container.encode(isGameCenterEnabled, forKey: .isGameCenterEnabled)
        try container.encode(kind, forKey: .kind)
        try container.encode(features, forKey: .features)
        try container.encode(trackCensoredName, forKey: .trackCensoredName)
        try container.encode(languageCodesISO2A, forKey: .languageCodesISO2A)
        try container.encode(fileSizeBytes, forKey: .fileSizeBytes)
        try container.encode(sellerUrl, forKey: .sellerUrl)
        try container.encode(contentAdvisoryRating, forKey: .contentAdvisoryRating)
        try container.encode(trackViewUrl, forKey: .trackViewUrl)
        try container.encode(trackContentRating, forKey: .trackContentRating)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(genreIds, forKey: .genreIds)
        try container.encode(formattedPrice, forKey: .formattedPrice)
        try container.encode(primaryGenreName, forKey: .primaryGenreName)
        try container.encode(isVppDeviceBasedLicensingEnabled, forKey: .isVppDeviceBasedLicensingEnabled)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(minimumOsVersion, forKey: .minimumOsVersion)
        try container.encode(sellerName, forKey: .sellerName)
        try container.encode(currentVersionReleaseDate, forKey: .currentVersionReleaseDate)
        try container.encode(releaseNotes, forKey: .releaseNotes)
        try container.encode(primaryGenreId, forKey: .primaryGenreId)
        try container.encode(currency, forKey: .currency)
        try container.encode(version, forKey: .version)
        try container.encode(wrapperType, forKey: .wrapperType)
        try container.encode(artistId, forKey: .artistId)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(genres, forKey: .genres)
        try container.encode(price, forKey: .price)
        try container.encode(description, forKey: .description)
        try container.encode(bundleId, forKey: .bundleId)
        try container.encode(averageUserRating, forKey: .averageUserRating)
        try container.encode(userRatingCount, forKey: .userRatingCount)
    }

    enum Keys: String, CodingKey {
        case screenshotUrls = "screenshotUrls"
        case ipadScreenshotUrls = "ipadScreenshotUrls"
        case appletvScreenshotUrls = "appletvScreenshotUrls"
        case artworkUrl60 = "artworkUrl60"
        case artworkUrl512 = "artworkUrl512"
        case artworkUrl100 = "artworkUrl100"
        case artistViewUrl = "artistViewUrl"
        case supportedDevices = "supportedDevices"
        case advisories = "advisories"
        case isGameCenterEnabled = "isGameCenterEnabled"
        case kind = "kind"
        case features = "features"
        case trackCensoredName = "trackCensoredName"
        case languageCodesISO2A = "languageCodesISO2A"
        case fileSizeBytes = "fileSizeBytes"
        case sellerUrl = "sellerUrl"
        case contentAdvisoryRating = "contentAdvisoryRating"
        case trackViewUrl = "trackViewUrl"
        case trackContentRating = "trackContentRating"
        case trackId = "trackId"
        case trackName = "trackName"
        case genreIds = "genreIds"
        case formattedPrice = "formattedPrice"
        case primaryGenreName = "primaryGenreName"
        case isVppDeviceBasedLicensingEnabled = "isVppDeviceBasedLicensingEnabled"
        case releaseDate = "releaseDate"
        case minimumOsVersion = "minimumOsVersion"
        case sellerName = "sellerName"
        case currentVersionReleaseDate = "currentVersionReleaseDate"
        case releaseNotes = "releaseNotes"
        case primaryGenreId = "primaryGenreId"
        case currency = "currency"
        case version = "version"
        case wrapperType = "wrapperType"
        case artistId = "artistId"
        case artistName = "artistName"
        case genres = "genres"
        case price = "price"
        case description = "description"
        case bundleId = "bundleId"
        case averageUserRating = "averageUserRating"
        case userRatingCount = "userRatingCount"
    }
}
