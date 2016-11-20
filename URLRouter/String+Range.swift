//
//  String+Range.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

internal extension String {
    func substring(with range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.location)
        let end = self.index(start, offsetBy: range.length)
        let substringRange = start..<end
        
        return self.substring(with: substringRange)
    }
    
    var rangeForSelf: NSRange {
        return NSMakeRange(0, self.characters.count)
    }
}
