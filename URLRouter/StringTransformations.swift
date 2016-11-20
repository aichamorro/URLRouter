//
//  StringTransformations.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

// MARK: Strings treatment for regex processing
internal typealias StringTransform = (String) -> String

internal struct StringTransforms {
    static let removeStartingAndTrailingSlashes: StringTransform = {
        guard let regex = try? NSRegularExpression(pattern: "^\\/+|\\/+$") else {
            fatalError("Couldn't create the regex to remove starting and trailing slashes")
        }
        
        return regex.stringByReplacingMatches(in: $0, options: [], range: $0.rangeForSelf, withTemplate: "")
    }
    
    static let normalizeSlashForRegex: StringTransform = {
        return $0.replacingOccurrences(of: "/", with: "\\/")
    }
    
    static let normalizeWildcards: StringTransform = {
        return $0.replacingOccurrences(of: "*", with: ".*")
    }
    
    static let normalizeURLRouteParameter: StringTransform = {
        guard let regex = try? NSRegularExpression(pattern: "(:\\w+)+?", options: .caseInsensitive) else {
            fatalError("The regex for the url normalizer is not valid")
        }
        
        return regex.stringByReplacingMatches(in: $0, options: [], range: $0.rangeForSelf, withTemplate: "(.+)?")
    }
    
    static let removeURLParameters: StringTransform = {
        guard let regex = try? NSRegularExpression(pattern: "\\?.*$", options: .caseInsensitive) else {
            fatalError("The regex for removing is not valid")
        }
        
        return regex.stringByReplacingMatches(in: $0, options: [], range: $0.rangeForSelf, withTemplate: "")
    }
    
    static let normalizeRegex: StringTransform = { return "^\($0)$" }
}
