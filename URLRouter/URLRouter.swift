//
//  URLRouter.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 21/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

public typealias URLRouterResult = (URL, Dictionary<String, String>) -> Any?
public typealias ParametersCollector<T> = (URL) -> T
public typealias URLRouterEntry = (test: URLTest, resultBuilder: URLRouterResult, paramsCollector: ParametersCollector<Dictionary<String, String>>?)
public typealias URLRouterResultHandler = (Any?) -> Void
public typealias URLRouter = (URL, URLRouterResultHandler?) -> Bool
public typealias URLRouterEngine = ([URLRouterEntry]) -> URLRouter

public struct URLRouterEngineFactory {
    public static let simple: URLRouterEngine = { entries in
        return { url, resultHandler in
            for routerEntry in entries {
                if routerEntry.test(url) == true {
                    let result = routerEntry.resultBuilder(url, routerEntry.paramsCollector?(url) ?? [:])
                    resultHandler?(result)
                    
                    return true
                }
            }
            
            return false
        }
    }
}

public struct URLRouterEntryFactory {
    public static func with(pattern: String, resultBuilder: @escaping URLRouterResult) -> URLRouterEntry {
        return URLRouterEntryFactory.with(pattern: pattern, paramsCollector: ParametersCollectorFactory.default(pattern: pattern), resultBuilder: resultBuilder)
    }
    
    public static func with(pattern: String, paramsCollector: @escaping ParametersCollector<[String:String]>, resultBuilder: @escaping URLRouterResult) -> URLRouterEntry {
        return (URLMatcherFactory.matcher(pattern: pattern), resultBuilder, paramsCollector)
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

private func +<K,V> (left: [K:V], right: [K:V]) -> [K:V] {
    var result: [K:V] = [:]
    
    for dic in [left, right] {
        for (k, v) in dic {
            result.updateValue(v, forKey: k)
        }
    }
    
    return result
}

public struct ParametersCollectorFactory {
    public static func pathParameters(pattern: String) -> ParametersCollector<[String:String]> {
        return PathParametersCollectorFactory.pathParamsCollector(pattern)
    }
    
    public static func urlParameters() -> ParametersCollector<[String:String]> {
        return { url in
            guard let urlComponents = URLComponents(string: url.absoluteString),
                let queryItems = urlComponents.queryItems else { return [:] }
            
            return queryItems.reduce([:]) { result, parameter in
                return result + [parameter.name: parameter.value ?? "\(true)"]
            }
        }
    }
    
    public static func `default`(pattern: String) -> ParametersCollector<[String:String]> {
        let collectors = [ParametersCollectorFactory.pathParameters(pattern: pattern), ParametersCollectorFactory.urlParameters()]
        
        return { url in collectors.reduce([:]) {$0 + $1(url)} }
    }
}
