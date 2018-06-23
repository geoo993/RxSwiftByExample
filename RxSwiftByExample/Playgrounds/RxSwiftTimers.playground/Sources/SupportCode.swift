
import UIKit
import RxSwift
import RxCocoa

public class SimpleViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}


public extension Observable {
    public func delay(time: Double, scheduler: SchedulerType) -> Observable<E> {
        return self.asObservable().flatMap { value -> Observable<E> in
            return Observable.just(value)
                .delaySubscription(time, scheduler: scheduler)
        }
    }
}

public func *(lhs: Character, rhs: Int) -> String {
    return String(repeating: "\(lhs)", count: rhs)
}

public extension DateFormatter {
    public convenience init(configure: (DateFormatter) -> Void) {
        self.init()
        configure(self)
    }
}
public let formatter = DateFormatter { $0.dateFormat = "HH:mm:ss.SSS" }
