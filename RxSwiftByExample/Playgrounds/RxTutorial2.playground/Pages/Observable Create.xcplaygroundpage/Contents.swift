//
//  StoryBookInteractor.playground
//  StorySmartiesInteractor
//
//  Created by Daniel Asher on 15/11/2016.
//  Copyright © 2016 LEXI LABS. All rights reserved.

import UIKit
import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let oneTick = Observable<Void>.create { observer in
    print("💸 Creating / Subscribing.")

    return Observable<Int64>
        .timer(1.0, scheduler: MainScheduler.instance)
        .delaySubscription(1.0, scheduler: MainScheduler.instance)
        .subscribe(onNext: { tick in
            print("🗞 Observing in timer.")
            observer.onNext(())
            observer.onCompleted()
        })
}

print("🏁 Before subscription.")

let sub = oneTick
    .delaySubscription(1.0, scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print("🗞 Observing in oneTick subscription.")
    })

