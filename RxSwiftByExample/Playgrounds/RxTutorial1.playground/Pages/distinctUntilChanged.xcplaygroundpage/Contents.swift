//: [Previous](@previous)

import Foundation
import RxSwift


let rx_OptionalInts : Observable<Int?> = [1,1,1,2,3,nil, nil, 3, 3].toObservable()

rx_OptionalInts
.distinctUntilChanged {
        switch ($0, $1) {
        case (.Some, .None): 
            //print("Caught latest nil")
            return false
        default: return true
        }
    }
.subscribeNext { print($0) }



print("Finished Setup 🙂")
//: [Next](@next)
