//
//  URLRouter.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 21/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

public typealias URLRouterAction = () -> Void
public typealias URLRouterEntry = (test: URLTest, action: URLRouterAction)
public typealias URLRouter = (URL) -> Bool
public typealias URLRouterEngine = ([URLRouterEntry]) -> URLRouter

public struct URLRouterEngineFactory {
    public static let simple: URLRouterEngine = { entries in
        return { url in
            for routerEntry in entries {
                if routerEntry.test(url) == true {
                    routerEntry.action()
                    
                    return true
                }
            }
            
            return false
        }
    }
}

public struct URLRouterEntryFactory {
    public static func with(pattern: String, action: @escaping URLRouterAction) -> URLRouterEntry {
        return (URLMatcherFactory.matcher(pattern: pattern), action)
    }
}

public struct URLRouterFactory {
    public static func with(entries: [URLRouterEntry], engine: URLRouterEngine = URLRouterEngineFactory.simple) -> URLRouter {
        return engine(entries)
    }
}
