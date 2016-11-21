//
//  URLMatcherFactory.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

public typealias URLTest = (URL) -> Bool
public typealias StringTest = (String) -> Bool

public struct URLMatcherFactory {
    public static func matcher(pattern: String) -> URLTest {
        return { url in
            let normalizeURL: StringTransform = StringTransforms.normalizeURL
            guard let regex = try? NSRegularExpression(pattern: normalizeURL(pattern), options: .caseInsensitive) else {
                fatalError("The pattern provided is not valid")
            }
        
            let urlString = StringTransforms.removeURLParameters(url.absoluteString)
            return regex.numberOfMatches(in: urlString, options: [], range: urlString.rangeForSelf) > 0
        }
    }
    
    public static func factory(scheme: String) -> (String) -> URLTest {
        guard StringTests.isScheme(scheme) else {
            fatalError("The provided scheme does not comply with the expected pattern: scheme://host/path")
        }

        return { pattern in matcher(pattern: "\(scheme)://\(pattern)") }
    }
    
    public static func factory(scheme: String, path: String) -> (String) -> URLTest {        
        let cleanSlashes: StringTransform = StringTransforms.removeStartingAndTrailingSlashes
        let prefix = "\(scheme)://\(cleanSlashes(path))"
        
        return factory(prefix: prefix)
    }
    
    public static func factory(prefix: String) -> (String) -> URLTest {
        let cleanSlashes: StringTransform = StringTransforms.removeStartingAndTrailingSlashes
        let cleanedPrefix = cleanSlashes(prefix)
        
        guard StringTests.isURL(cleanedPrefix) else {
            fatalError("The provided prefix does not comply with the expected pattern: scheme://host/path")
        }
        
        return { pattern in
            return matcher(pattern: "\(cleanSlashes(prefix))/\(cleanSlashes(pattern))")
        }
    }
}

private func & (lhs: @escaping StringTransform, rhs: @escaping StringTransform) -> StringTransform {
    return { string in lhs(rhs(string)) }
}

internal extension StringTransforms {
    static func normalizeURL(_ string: String) -> String {
        return (
            StringTransforms.removeStartingAndTrailingSlashes &
                StringTransforms.normalizeRegex &
                StringTransforms.normalizeWildcards &
                StringTransforms.normalizeURLRouteParameter &
                StringTransforms.normalizeSlashForRegex
            )(string)
    }
}
