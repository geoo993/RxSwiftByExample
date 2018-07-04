// 'RxSwift Transforming Operators'
import RxSwift
import RxSwiftExt
import RxCocoa
import UIKit
import PlaygroundSupport

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}


let episodeI = "The Phantom Menace"
let episodeII = "Attack of the Clones"
let theCloneWars = "The Clone Wars"
let episodeIII = "Revenge of the Sith"
let solo = "Solo"
let rogueOne = "Rogue One"
let episodeIV = "A New Hope"
let episodeV = "The Empire Strikes Back"
let episodeVI = "Return Of The Jedi"
let episodeVII = "The Force Awakens"
let episodeVIII = "The Last Jedi"
let episodeIX = "Episode IX"

let luke = "Luke Skywalker"
let hanSolo = "Han Solo"
let leia = "Princess Leia"
let chewbacca = "Chewbacca"

let lightsaber = "Lightsaber"
let dl44 = "DL-44 Blaster"
let defender = "Defender Sporting Blaster"
let bowcaster = "Bowcaster"

let formatter = DateComponentsFormatter()

func stringFrom(_ minutes: Int) -> String {
    let interval = TimeInterval(minutes)
    return formatter.string(from: interval) ?? ""
}

public let runtimes = [
    episodeI: 136,
    episodeII: 142,
    theCloneWars: 98,
    episodeIII: 140,
    solo: 142,
    rogueOne: 142,
    episodeIV: 121,
    episodeV: 124,
    episodeVI: 134,
    episodeVII: 136,
    episodeVIII: 152
]


// RxSeift is all about asyncrones sequences, but you would often need to make order of the chaos.
// there is a lot you can gain by combining observables.


// to ensure that a subscriber always starts by receiving one or more elements you would use startWith
// startWith prepends a sequence of values onto an observable that subscribers are guaranteed to receive first, before any other element.
example(of: "startWith") {

    let disposeBag = DisposeBag()

    let prequelEpisodes = Observable.of(episodeI, episodeII, episodeIII)

    prequelEpisodes
        .startWith(episodeIV, episodeV)
        .subscribe(onNext: { episode in
            print(episode)
        })
        .disposed(by: disposeBag)
}

// it turns out that startWith is actually a simplefied variant of the Concat operator.
// Concat joins two observables together and combines their elements in the other the observables are specified.
// Concat operator joins observables such that their elements are emitted as one observable to the subscriber, in the order they were specified to concat.
example(of: "concat") {

    let disposeBag = DisposeBag()

    let prequelTrilogy = Observable.of(episodeI, episodeII, episodeIII)

    let originalTrilogy = Observable.of(episodeIV, episodeV, episodeVI)

    prequelTrilogy.concat(originalTrilogy)
        .subscribe(onNext: { episode in
            print(episode)
        })
        .disposed(by: disposeBag)
}

// merge will do as it says, interspersing elements from the combined observables as their elements are emitted
example(of: "merge") {

    let disposeBag = DisposeBag()

    let filmTrilogies = PublishSubject<String>()

    let standaloneFilms = PublishSubject<String>()

    let storyOrder = Observable.of(filmTrilogies, standaloneFilms)

    storyOrder.merge()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    // story chronological order
    filmTrilogies.onNext(episodeI)
    filmTrilogies.onNext(episodeII)

    standaloneFilms.onNext(theCloneWars)

    filmTrilogies.onNext(episodeIII)

    standaloneFilms.onNext(solo)
    standaloneFilms.onNext(rogueOne)

    filmTrilogies.onNext(episodeIV)
}


// combineLatest is another type method that will take the latest from each of the sources observables whenever any source observable emits,
// and pass those latest elements to a closure for you to specify how to combine them.
// ⚠️ another thing to note is that combine latest will wait until all source observables emit an initial value.
// so you could use startWith on each source observable to make sure tthat you have a value upon subscription
example(of: "combineLatest") {

    let disposeBag = DisposeBag()

    let characters = Observable.of(luke, hanSolo, leia, chewbacca)

    let primaryWeapons = Observable.of(lightsaber, dl44, defender, bowcaster)

    Observable.combineLatest(characters, primaryWeapons) { character, weapon -> String in
        return "\(character): \(weapon)" }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// there are also other variance of combineLatest that will let combine up-to 8 source observables.
// there are several use cases for combineLatest, such as to observe several textfields that combines their value evertime text is entered in any of the textfields.
// but what if you only wanted to emit a new combined element when all source observables have emitted a new element.
// Zip will help to do this.
// Zip will wait until all source observables have produces an element,
// at a corresponding index before emitting the combinedLatest element.
example(of: "zip") {

    let disposeBag = DisposeBag()

    let characters = Observable.of(luke, hanSolo, leia, chewbacca)

    let primaryWeapons = Observable.of(lightsaber, dl44, defender, bowcaster)

    Observable.zip(characters, primaryWeapons) { character, weapon -> String in
        return "\(character): \(weapon)" }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// switchLatest will allow you to switch between two source observables.
// switchLatest produces values only from the most recent observable sequence
// each time a new inner observable sequence is received, it will unsubscribe from prvious observable sequence.
// FlatmapLatest is actually a combination of map and switchLatest.
example(of: "switchLatest") {

    let disposeBag = DisposeBag()

    let prequelEpisodes = PublishSubject<String>()
    let originalEpisodes = PublishSubject<String>()

    Observable.of(prequelEpisodes, originalEpisodes)
        .switchLatest()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    originalEpisodes.onNext(episodeV)
    
    originalEpisodes.onNext(episodeIV)

    prequelEpisodes.onNext(episodeI)

    prequelEpisodes.onNext(episodeII)

    prequelEpisodes.onNext(episodeIII)

}

// AMB is a new switching operator,
// it will subcribe to both source observable and wait unitl either one emits an element and then stay subscribed to that one,
// and unsubscribe to the other observable
example(of: "amb") {

    let disposeBag = DisposeBag()

    let prequelEpisodes = PublishSubject<String>()

    let originalEpisodes = PublishSubject<String>()

    prequelEpisodes.amb(originalEpisodes)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    // keep in mind that amb will unsubscribe from the other observable as soon as the first one emits.
    // it does not matter whether the first to emit is the one amb is being called on or if its the parameter to amb
    // as a result only episode four and five are printed
    originalEpisodes.onNext(episodeIV)

    prequelEpisodes.onNext(episodeI)

    prequelEpisodes.onNext(episodeII)

    originalEpisodes.onNext(episodeV)

}

// the reduce in RxSwift works very similarly to the reduce in swift
// it allows you to combine an observable with its self using an accumulator
// to determine how to do the combining,
// you can also pass a closure to determine how to perform the accumulation
example(of: "reduce") {

    let disposeBag = DisposeBag()

    Observable.from(runtimes.values)
        .reduce(0, accumulator: +) // summing the results
        .subscribe(onNext: {
            print(stringFrom($0))
        })
        .disposed(by: disposeBag)
}

// a cousin of reduce that also passes through the intermidiate result
// for each new values accumulated, is called scan
// scan get provides the accumulation at each interation of the accumulation
example(of: "scan") {

    let disposeBag = DisposeBag()

    Observable.from(runtimes.values)
        .scan(0, accumulator: +)
        .subscribe(onNext: {
            print(stringFrom($0))
        })
        .disposed(by: disposeBag)

}

// Challenge
example(of: "zip + scan") {

    let disposeBag = DisposeBag()

    let movies = Observable.from(runtimes)
    let times = movies.scan(0) { runtime, movie in
        return runtime + movie.value
    }

    Observable.zip(movies, times) { movie, time in
         (movie.key, movie.value, time) }
        .subscribe(onNext: {
            print("\($0):", stringFrom($1), "(\(stringFrom($2)))")
        })
        .disposed(by: disposeBag)
}


example(of: "skip + zip") {
    let a = Observable.of(1,2,3,4,5,6,7,8)
    let wrap = true
    let b = a.skip(1).concat(a.take(wrap ? 1 : 0))
    let c = Observable.zip(a, b) { ($0, $1) }
    c.do(onCompleted: {  print("Completed") })
        .subscribe(onNext: {
            print( ($0, $1) )
            //print($0)
        })

}


example(of: "withLatestfrom") {
    let timer1 = Observable<Int64>
        .interval(3.0, scheduler: MainScheduler.instance)
    //.subscribeNext { print($0) }
    let timer2 = Observable<Int64>
        .interval(1.0, scheduler: MainScheduler.instance)

    timer1
        .withLatestFrom(timer2) { ($0, $1) }
        .subscribe(onNext: { print(($0, $1)) })
}
