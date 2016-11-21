//
//  RegularExpressionTests.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 21/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation
@testable import URLRouter
import Quick
import Nimble

typealias ParamsScanner = (String) -> [String]

public class NSRegularExpressionTests: QuickSpec {
    public override func spec() {
        context("Capture url parameters names") {
            it("Can capture url parameter names") {
                let pathParamsScanner: (String) -> [String] = { routePattern in
                    guard let regex = try? NSRegularExpression(pattern: ":([a-zA-Z]+)") else {
                        fatalError()
                    }
                    
                    return regex.matches(in: routePattern, options: [], range: NSMakeRange(0, routePattern.characters.count)).reduce([]) { result, match in
                        let string = routePattern.substring(with: match.rangeAt(1))
                        
                        return result + [string]
                    }
                }
                
                let params = pathParamsScanner("/:id/:test")
                expect(params).to(equal(["id","test"]))
            }
        }
    }
}
