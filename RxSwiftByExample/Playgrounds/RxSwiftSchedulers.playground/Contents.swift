// 'RxSwift Schedulers'
import RxSwift
import PlaygroundSupport
import Foundation
import UIKit

let simpleVC = SimpleViewController()
let navigator = UINavigationController(rootViewController: simpleVC)
simpleVC.title = "SimpleViewController"
simpleVC.view.backgroundColor = .red
PlaygroundPage.current.liveView = navigator

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

// RxSwift has a more Rx way of managing threads, using Schedulers.
// By edfault Observables and Operators will work on the same thread as where the subscription occurs, which is typically on the main thread.
// Schedulers provides an abstraction for managing threads and changing that default behavior.
// A Schedular is a context where process takes place, and they are quite an advanced topic in RxSwift.
// The main scheduler singleton in Rx performs work on the main thread.

// There are also a couple of operators that you can use to specify where to do the observing and subscribing, which are ObserveOn and SubcribeOn
// ObserveOn directs where events are received after it is called,
// in a chain of operators what comes after a call to observeOn will be performed on the scheduler that is specified,
// where as subscribeOn will direct where an entire subcsciption is performed, regardless of where it is called.

//print("\n--- Example of:", "Scheduler", "---")
example(of: "Scheduler") {
    let disposeBag = DisposeBag()

    Observable<Int64>
    .interval(1.0, scheduler: MainScheduler.instance)
    .debug("scheduler")
    .take(10)
    .subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
}


example(of: "Alert Controller") {
    let disposeBag = DisposeBag()

    simpleVC.title = "Alert"
    simpleVC.view.backgroundColor = .orange

    let mainView = UIView()
    mainView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300) )
    mainView.backgroundColor = .white
    mainView.center = simpleVC.view.center
    //simpleVC.view.addSubview(mainView)

    /*
    simpleVC.alert(title: "No access to Camera Roll",
          text: "You can grant access to Combinestagram from the Settings app")
        .asObservable()
        .take(5.0, scheduler: MainScheduler.instance) // will cause the alert message to automatically disappaer and the PhotoviewController to dismiss after 5 seconds if the user has not closed before then
        .subscribe(onCompleted: {
            simpleVC.dismiss(animated: true, completion: nil)
            _ = simpleVC.navigationController?.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
    */

}

example(of: "Images") {

    simpleVC.title = "Images"
    simpleVC.view.backgroundColor = .red


    let mainView = UIImageView()
    mainView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300) )
    mainView.backgroundColor = .white
    mainView.center = simpleVC.view.center
    //simpleVC.view.addSubview(mainView)

    /*
     let disposeBag = DisposeBag()
    let urlString = "http://www.simplifiedtechy.net/wp-content/uploads/2017/07/simplified-techy-default.png"

    if let url = URL(string: urlString) {
        URLSession.shared.rx
            .response(request: URLRequest(url: url))
            // subscribe on main thread
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { (response, data) in
                // Update Image
                mainView.image = UIImage(data: data)
            }, onError: { (error) in
                print("error:", error)
            }, onCompleted: {
                // animate image view alpha
                UIView.animate(withDuration: 0) {
                    mainView.alpha = 1
                }

                print("completed ")
            }, onDisposed: {
                print("disposed")
            }).disposed(by: disposeBag)
    }
 */

}
