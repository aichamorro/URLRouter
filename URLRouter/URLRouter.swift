//
//  URLRouter.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 21/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

public typealias URLRouterAction = (Dictionary<String, String>) -> Void
public typealias ParametersCollector<T> = (URL) -> T
public typealias URLRouterEntry = (test: URLTest, action: URLRouterAction, paramsCollector: ParametersCollector<Dictionary<String, String>>?)
public typealias URLRouter = (URL) -> Bool
public typealias URLRouterEngine = ([URLRouterEntry]) -> URLRouter

public struct URLRouterEngineFactory {
    public static let simple: URLRouterEngine = { entries in
        return { url in
            for routerEntry in entries {
                if routerEntry.test(url) == true {
                    routerEntry.action(routerEntry.paramsCollector?(url) ?? [:])
                    
                    return true
                }
            }
            
            return false
        }
    }
}

public struct URLRouterEntryFactory {
    public static func with(pattern: String, action: @escaping URLRouterAction) -> URLRouterEntry {
        return (URLMatcherFactory.matcher(pattern: pattern), action, ParametersCollectorFactory.with(pattern: pattern))
    }
}

public struct URLRouterFactory {
    public static func with(entries: [URLRouterEntry], engine: URLRouterEngine = URLRouterEngineFactory.simple) -> URLRouter {
        return engine(entries)
    }
}

typealias PathParamsCollector = (String) -> ParametersCollector<[String:String]>
typealias PathParamsScanner = (String) -> [String]

private struct PathParametersCollectorFactory {
    fileprivate static let pathParamsCollector: PathParamsCollector = { routePattern in
        let paramNames = PathParametersCollectorFactory.pathParamsScanner(routePattern)
        
        return PathParametersCollectorFactory.pathParamsValuesCollector(withParams: paramNames, routePattern: routePattern)
    }

    private static let pathParamsScanner: PathParamsScanner = { routePattern in
        let paramNamesRegex = NSRegularExpression.pathParametersRegex()
        
        return paramNamesRegex.matches(in: routePattern, options: [], range: routePattern.rangeForSelf).reduce([]) { result, match in
            let string = routePattern.substring(with: match.rangeAt(1))
            
            return result + [string]
        }
    }
    
    private static func pathParamsValuesCollector(withParams params: [String], routePattern: String) -> ParametersCollector<[String:String]> {
        let paramsValues: (String) -> [String] = { string in
            let paramValuesCaptureGroups: () -> NSTextCheckingResult = {
                let paramValuesCollectorRegexPattern = NSRegularExpression.pathParametersValues(for: routePattern)
                
                return paramValuesCollectorRegexPattern.matches(in: string, options: [], range: string.rangeForSelf).first!
            }
            
            let capturedGroupsToStringArray: (NSTextCheckingResult) -> [String] = { match in
                return (1..<match.numberOfRanges).reduce([]) { result, rangeNumber in
                    result + [string.substring(with: match.rangeAt(rangeNumber))]
                }
            }

            return capturedGroupsToStringArray(paramValuesCaptureGroups())
        }
        
        let buildDictionaryFromNamesAndValues: ([String], [String]) -> [String:String] = { names, values in
            var result: [String:String] = [:]
            
            for entry in zip(params, values) {
                result[entry.0] = entry.1
            }
            
            return result
        }
        
        return { url in buildDictionaryFromNamesAndValues(params, paramsValues(url.absoluteString)) }
    }
}

private struct ParametersCollectorFactory {
    public static func with(pattern: String) -> ParametersCollector<Dictionary<String, String>> {
        return PathParametersCollectorFactory.pathParamsCollector(pattern)
    }
}
