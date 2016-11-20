//
//  URLMatching.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation
import Quick
import Nimble
import URLRouter

class URLMatchingTests: QuickSpec {
    override func spec() {
        context("As developer I would like to be able to create route testers") {
            it("Can create url testers") {
                let test = URLMatcherFactory.matcher(pattern: "app://test")
                
                expect(test).toNot(beNil())
            }
            
            it("Can create urls with a configured scheme") {
                let factory = URLMatcherFactory.factory(scheme: "app")
                let test = factory("test")

                let url = URL(string: "app://test")!
                expect(test(url)).to(beTrue())
            }
            
            it("Can create url with a configured path") {
                let factory = URLMatcherFactory.factory(scheme: "app", path: "test/my/url")
                let test = factory("/*")
                
                let url = URL(string: "app://test/my/url/*")!
                expect(test(url)).to(beTrue())
            }
            
            it("Can create urls with a configured prefix") {
                let factory = URLMatcherFactory.factory(prefix: "app://test/my/url")
                let test = factory("/*")
                
                let url = URL(string: "app://test/my/url/*")!
                expect(test(url)).to(beTrue())
            }
            
            it("Can ignore slahses") {
                let slashAtEndFactory = URLMatcherFactory.factory(prefix: "app://test/my/url/")
                let noSlashAtEndFactory = URLMatcherFactory.factory(prefix: "app://test/my/url")
                
                let slashAtEndTest = slashAtEndFactory("/*")
                let noSlashAtEndTest = noSlashAtEndFactory("/*/")
                
                let url = URL(string: "app://test/my/url/*")!
                expect(slashAtEndTest(url)).to(beTrue())
                expect(noSlashAtEndTest(url)).to(beTrue())
            }
        }
        
        context("As developer I would like to be able to test route patterns") {
            it("matches identical routes") {
                let test = URLMatcherFactory.matcher(pattern: "app://test")
                
                expect(test(URL(string: "app://test")!)).to(beTrue())
                expect(test(URL(string: "app://test2")!)).to(beFalse())
            }
            
            it("matches routes with wildcards") {
                let test = URLMatcherFactory.matcher(pattern: "app://*")
                
                expect(test(URL(string: "app://test")!)).to(beTrue())
                expect(test(URL(string: "app://different")!)).to(beTrue())
                expect(test(URL(string: "app://this/is/even/more/different")!)).to(beTrue())
            }
            
            it("matches routes with path parameters") {
                let test = URLMatcherFactory.matcher(pattern: "app://host/:domain/:action")
                
                expect(test(URL(string: "app://host/feed/list")!)).to(beTrue())
                expect(test(URL(string: "app://other/feed/list")!)).to(beFalse())
            }
            
            it("matches routes with url parameters") {
                let test = URLMatcherFactory.matcher(pattern: "app://host/:domain/:action")
                
                expect(test(URL(string: "app://host/feed/list?parameters=true&number=some&hopes-it-works=high")!)).to(beTrue())
            }
        }
    }
}
