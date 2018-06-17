//: [Previous](@previous)
import RxSwift
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

var state = Int64(0)

let resetDisposable : () throws -> Disposable = { () in
    let initial = state 
    return Disposables.create { 
        state = initial
        print("Reset state to \(state)")
        }
    }

//Observable<Int64>.using(resetDisposable, observableFactory: { sub in
//        return Observable<Int64>.interval(1.0, scheduler: MainScheduler.instance)
//    })
         
//let tickerWithStateReset = 
//    Observable<Int64>.using(resetDisposable) { sub in
//        return Observable<Int64>.interval(1.0, scheduler: MainScheduler.instance)
//    }
//        
//let tickerSubscription = 
//    tickerWithStateReset
//    .doOn(onNext: { state = $0 })
//    .subscribe { _ in print(state) }

//let a : Observable<Int64> = Observable<Int64>.interval(4.0, scheduler: MainScheduler.instance)
//.take(1)
//.subscribe(onNext: { _ in tickerSubscription.dispose() })

//: [Next](@next)

//let tickWithStateReset2 = Observable<Int64>.using({ _ in 
//        AnonymousDisposable { state = 0 } 
//    }) { reset in
//    
//        return Observable<Int64>.create { observer in 
//            let ticker = Observable<Int64>.interval(1.0, scheduler: MainScheduler.instance)
//            let tickerSub = ticker.subscribe { observer.on($0) }
//            return CompositeDisposable(tickerSub, reset)
//            }
//        }
//tickWithStateReset2.subscribe{ evt in print(evt) }
//: [Next](@next)
