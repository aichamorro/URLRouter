//
//  URLRouterResultHandlerAdapter.swift
//  URLRouter
//
//  Created by Alberto Chamorro on 23/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

import Foundation

private func adaptURLRouterResult<T>(result: Any?) -> T? {
    guard let converted = result as? T else {
        if (result != nil) { fatalError("The obtained result type does not match the expected one") }

        return nil
    }

    return converted
}

public func URLResultHandlerAdapter<T>(handler: @escaping (T?) -> Void) -> URLRouterResultHandler {
    return { result in handler(adaptURLRouterResult(result: result)) }
}
