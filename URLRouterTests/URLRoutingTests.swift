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
                let entry = URLRouterEntryFactory.with(pattern: "app://test") {
                    hasExecutedAction = true
                }
                
                let router = URLRouterFactory.with(entries: [entry])
                
                let url: URL = URL(string: "app://test")!
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can hold different entries") {
                var hasExecutedAction = false
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test") {
                    fail("It shouldn't execute this")
                }
                
                let patternForGoodHost = URLRouterEntryFactory.with(pattern: "app://good") {
                    hasExecutedAction = true
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost, patternForGoodHost])
                
                let url = URL(string: "app://good")!
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).toEventually(beTrue())
            }
            
            it("Can handle wildcards") {
                var numberOfExecutions = 0
                
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/*") {
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
                let patternForTestHost = URLRouterEntryFactory.with(pattern: "app://test/:id") {
                    hasExecutedAction = true
                }
                
                let router = URLRouterFactory.with(entries: [patternForTestHost])
                let url = URL(string: "app://test/56")!
                
                expect(router(url)).to(beTrue())
                expect(hasExecutedAction).to(beTrue())
            }
        }
    }
}
