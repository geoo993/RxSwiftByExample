//: Playground - noun: a place where people can play

import RxSwift

let simple = Observable.from([1, 2, 3])

var state = 0
//let returnToInitialState : Void -> AnonymousDisposable = { _ in AnonymousDisposable { state = 0 } }
//let a = Observable<Int64>.using(returnToInitialState) { sub in
//    return Observable<Int64>.interval(1.0, scheduler: MainScheduler.instance)
//}
let ticksWithReturnToInitialState = Observable<Int64>.create { o in 
    let tickSubscription = Observable<Int64>.interval(1.0, scheduler: MainScheduler.instance)
    .subscribe { evt in
        if case .next(let tick) = evt {
            state = Int(tick)
        }
        o.on(evt)
     }
    let returnToInitialState = Disposables.create { 
        state = 0
        print("Return to initial state \(state)") 
        } 
    return CompositeDisposable( tickSubscription, returnToInitialState )
    }
    
let sub1 = ticksWithReturnToInitialState
    .subscribe { evt in 
        print(evt, state)
    } 

Observable<Int64>.interval(4.0, scheduler: MainScheduler.instance)
.take(1)
.subscribe(onNext: { tick in
    sub1.dispose()
})


import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
