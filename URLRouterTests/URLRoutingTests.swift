//
//  URLRoutingTests.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 21/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation
import Quick
import Nimble
import URLRouter

class URLRoutingTests: QuickSpec {
    override func spec() {
        describe("As a developer I would like to be able to associate actions to URL patterns") {
            it("Can associate a actions to patterns") {
                var hasExecutedAction = false
                let entry = URLRouterEntryFactory.with(pattern: "app://test") { _ in
                    hasExecutedAction = true
                    
                    return nil
                }
                
                let router = URLRouterFactory.with(entries: [entry])
                
                let url: URL = URL(string: "app://test")!
                expect(router(url, nil)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can hold different entries") {
                var hasExecutedAction = false
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test") { _ in
                    fail("It shouldn't execute this")
                    
                    return nil
                }
                
                let patternForGoodHost = URLRouterEntryFactory.with(pattern: "app://good") { _ in
                    hasExecutedAction = true
                    
                    return nil
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost, patternForGoodHost])
                
                let url = URL(string: "app://good")!
                expect(router(url, nil)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can handle wildcards") {
                var numberOfExecutions = 0
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/*") { _ in
                    numberOfExecutions = numberOfExecutions + 1
                    
                    return nil
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost])
                let url = URL(string: "app://test/")!
                let secondURL = URL(string: "app://test/another")!
                
                expect(router(url, nil)).to(beTrue())
                expect(router(secondURL, nil)).to(beTrue())
                expect(numberOfExecutions).to(equal(2))
            }
            
            it("Can handle path parameters") {
                var hasExecutedAction = false
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/:id") { _ in
                    hasExecutedAction = true
                    
                    return nil
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost])
                let url = URL(string: "app://test/56")!
                
                expect(router(url, nil)).to(beTrue())
                expect(hasExecutedAction).to(beTrue())
            }
            
            context("Receiving parameters") {
                it("receives path parameters") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id") { url, parameters in
                        expect(url.absoluteString).to(equal("app://test/5"))
                        expect(parameters["id"]).to(equal("5"))
                        
                        return nil
                    }
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5")!
                    
                    expect(router(url, nil)).to(beTrue())
                }
                
                it("receives more than one path parameter") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id/:action/test") { url, parameters in
                        expect(url.absoluteString).to(equal("app://test/5/edit/test"))
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                        
                        return nil
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5/edit/test")!
                    
                    expect(router(url, nil)).to(beTrue())
                }
                
                it("receives parameters from the url") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/url")
                    { url, parameters in
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                        
                        return nil
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/url?id=5&action=edit")!
                    
                    expect(router(url, nil)).to(beTrue())
                }
                
                it("receives parameters from the url and the path") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id/:action")
                    { url, parameters in
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                        expect(parameters["user"]).to(equal("user-name"))
                        
                        return nil
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5/edit?user=user-name")!
                    
                    expect(router(url, nil)).to(beTrue())
                }
            }
            
            context("Creating results") {
                it("Can create an object in the action and is received in the handler") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id/:action") { url, parameters in
                        return "This is the result: \(parameters["id"]!), \(parameters["action"]!) for \(url)" as AnyObject
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5/edit")!
                    
                    expect(router(url) { result in
                        if let result = result as? String {
                            expect(result).to(equal("This is the result: 5, edit for app://test/5/edit"))
                        } else {
                            fail("Expected a String, but got something different")
                        }
                    }).to(beTrue())
                }
                
                it("Can return tuples") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/action") { url, parameters in
                        return ("This", "is", "a", "test")
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/action")!
                    
                    expect(router(url) { result in
                        if let result = result as? (String, String, String, String) {
                            expect(result.0).to(equal("This"))
                            expect(result.1).to(equal("is"))
                            expect(result.2).to(equal("a"))
                            expect(result.3).to(equal("test"))
                        } else {
                            fail("Expected a tuple of (String, String, String, String) but goto something different")
                        }
                    }).to(beTrue())
                }
                
                it("Can return structs") {
                    struct TestStruct {
                        let name: String
                        let value: Int
                    }
                    
                    let expectedValue = TestStruct(name: "Test", value: 5)
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/action") { url, parameters in
                        return expectedValue
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/action")!
                    
                    expect(router(url) { result in
                    }).to(beTrue())
                }
            }
        }
    }
}
