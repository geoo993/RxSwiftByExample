// 'RxSwift Transforming Operators'
import RxSwift
import RxSwiftExt
import UIKit
import PlaygroundSupport

// RxCocoa is a seperate set of API that enables applying the concepts and patterns found in RxSwift to iOS, watchOS, tvOS and macOS development.
// Another words Cocoa and CocoaTouch, and it does so via the rx nameSpace.
// RxCocoa added extensions to UIKit, and Foundation classes such as URLSessions and UISwitch,
// letting you apply the same reactive techniques when working with these APIs for example

let simpleVC = SimpleViewController()
let navigator = UINavigationController(rootViewController: simpleVC)
simpleVC.title = "SimpleViewController"
simpleVC.view.backgroundColor = .red
PlaygroundPage.current.liveView = navigator


let switchView = UISwitch(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
switchView.isOn = true
switchView.setOn(true, animated: false)
switchView.center = simpleVC.view.center
simpleVC.view.addSubview(switchView)

let disposeBag = DisposeBag()
switchView.rx
    .isOn
    .subscribe(onNext: { enabled in
        print(enabled ? "Its on" : "Its off")
    }).disposed(by: disposeBag)

