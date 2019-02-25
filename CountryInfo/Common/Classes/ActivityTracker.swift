import Foundation
import RxSwift
import RxCocoa

public class ActivityTracker: SharedSequenceConvertibleType {
    public typealias E = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let lock = NSRecursiveLock()
    private let variable = BehaviorRelay(value: false)
    private let loading: SharedSequence<SharingStrategy, Bool>
    private var numberOfActivities: Int = 0
    
    public init() {
        loading = variable.asDriver()
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading(decrement: false)
            }, onSubscribe: subscribed)
    }
    
    private func subscribed() {
        lock.lock()
        variable.accept(true)
        numberOfActivities += 1
        lock.unlock()
    }
    
    private func sendStopLoading(decrement: Bool = true) {
        lock.lock()
        if decrement && numberOfActivities > 0 {
            numberOfActivities -= 1
        }
        variable.accept(numberOfActivities > 0)
        lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return loading
    }
    
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityTracker) -> Observable<E> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}

