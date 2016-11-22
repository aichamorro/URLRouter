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
                }
                
                let router = URLRouterFactory.with(entries: [entry])
                
                let url: URL = URL(string: "app://test")!
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can hold different entries") {
                var hasExecutedAction = false
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test") { _ in
                    fail("It shouldn't execute this")
                }
                
                let patternForGoodHost = URLRouterEntryFactory.with(pattern: "app://good") { _ in
                    hasExecutedAction = true
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost, patternForGoodHost])
                
                let url = URL(string: "app://good")!
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can handle wildcards") {
                var numberOfExecutions = 0
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/*") { _ in
                    numberOfExecutions = numberOfExecutions + 1
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost])
                let url = URL(string: "app://test/")!
                let secondURL = URL(string: "app://test/another")!
                
                expect(router(url)).to(beTrue())
                expect(router(secondURL)).to(beTrue())
                expect(numberOfExecutions).to(equal(2))
            }
            
            it("Can handle path parameters") {
                var hasExecutedAction = false
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/:id") { _ in
                    hasExecutedAction = true
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost])
                let url = URL(string: "app://test/56")!
                
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).to(beTrue())
            }
            
            context("Receiving parameters") {
                it("receives path parameters") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id") { url, parameters in
                        expect(url.absoluteString).to(equal("app://test/5"))
                        expect(parameters["id"]).to(equal("5"))
                    }
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5")!
                    
                    expect(router(url)).to(beTrue())
                }
                
                it("receives more than one path parameter") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id/:action/test") { url, parameters in
                        expect(url.absoluteString).to(equal("app://test/5/edit/test"))
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5/edit/test")!
                    
                    expect(router(url)).to(beTrue())
                }
                
                it("receives parameters from the url") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/url")
                    { url, parameters in
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/url?id=5&action=edit")!
                    
                    expect(router(url)).to(beTrue())
                }
                
                it("receives parameters from the url and the path") {
                    let entry = URLRouterEntryFactory.with(pattern: "app://test/:id/:action")
                    { url, parameters in
                        expect(parameters["id"]).to(equal("5"))
                        expect(parameters["action"]).to(equal("edit"))
                        expect(parameters["user"]).to(equal("user-name"))
                    }
                    
                    let router = URLRouterFactory.with(entries: [entry])
                    let url = URL(string: "app://test/5/edit?user=user-name")!
                    
                    expect(router(url)).to(beTrue())
                }
            }
        }
    }
}
