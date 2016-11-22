//
//  RegularExpression+URL.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

internal struct StringTests {
    static let isURL: StringTest = {
        return NSRegularExpression.urlRegex().test(string: $0)
    }
    
    static let isScheme: StringTest = {
        return NSRegularExpression.schemeRegex().test(string: $0)
    }
}

fileprivate extension NSRegularExpression {
    static var schemePattern: String = {
        return "^[a-zA-Z][a-zA-Z0-9]*"
    }()
    
    static var hostPattern: String = {
        return "[a-zA-Z0-9_\\-.]*"
    }()
    
    static var pathPattern: String = {
        return "(?:\\/:[a-zA-Z]+|\\/[a-zA-Z0-9\\-]+)*"
    }()
    
    static var urlPattern: String = {
        return "\(NSRegularExpression.schemePattern):\\/\\/\(NSRegularExpression.hostPattern)\(NSRegularExpression.pathPattern)"
    }()
    
    static var pathParametersPattern: String = {
        return ":([a-zA-Z][a-zA-Z0-9]*[^/]{0,1})"
    }()

    static var urlParametersPattern: String = {
       return "[a-zA-Z][a-zA-Z0-9@.\\-_]*=[a-zA-Z0-9@.\\-_]+"
    }()
}

internal extension NSRegularExpression {
    class func schemeRegex(options: NSRegularExpression.Options = []) -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: NSRegularExpression.schemePattern, options: options) else {
            fatalError("The schemes to determine valid urls is not correct")
        }
        
        return regex
    }
    
    class func urlRegex(options: NSRegularExpression.Options = []) -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: NSRegularExpression.urlPattern, options: options) else {
            fatalError("The regex to determine valid urls is not correct")
        }
        
        return regex
    }
    
    class func pathParametersRegex(options: NSRegularExpression.Options = []) -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: NSRegularExpression.pathParametersPattern, options: options) else {
            fatalError("The regex to capture path parameters is not correct")
        }
        
        return regex
    }
    
    class func urlParametersRegex(options: NSRegularExpression.Options = []) -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: NSRegularExpression.urlParametersPattern, options: options) else {
            fatalError("The regex to capture url parameters is not correct")
        }
        
        return regex
    }
    
    class func pathParametersValues(for routePattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression {
        let pathParametersScanRegex = NSRegularExpression.pathParametersRegex(options: options)
        let regexPattern = pathParametersScanRegex.stringByReplacingMatches(in: routePattern, options: [], range: routePattern.rangeForSelf, withTemplate: "([^?]*)")
        
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: options) else {
            fatalError()
        }
        
        return regex
    }
}

internal extension NSRegularExpression {
    func test(string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let matches = self.matches(in: string, options: options, range: NSMakeRange(0, string.characters.count))
        
        if matches.count != 1 {
            return false
        }
        
        let testResult = matches.first!.rangeAt(0)
        return testResult.location == 0 && testResult.length == string.characters.count
    }   
}
