//: [Previous](@previous)

import Foundation
import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let startTime = Date()

let ticker = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .take(2)

ticker
    .flatMap { tick in 
        return Observable<Int>.interval(0.25, scheduler: MainScheduler.instance)
            .take(2) }
    .subscribe(
        onNext: { tick in
        let currentTime = Date()
        let interval = currentTime.timeIntervalSince(startTime)
        print(interval)
    },  onCompleted: {
        print("Completed")
    })

var str = "Hello, playground"

//: [Next](@next)
