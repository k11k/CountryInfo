import Foundation
import RxSwift
import RxCocoa

final class ErrorTracker<T>: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<T>()
    
    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
        return source.asObservable().do(onError: onError)
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, T> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }
    
    func asObservable() -> Observable<T> {
        return _subject.asObservable()
    }
    
    func onError(_ error: Swift.Error) {
        if let error = error as? T {
            _subject.onNext(error)
        } else {
            #if DEBUG
            fatalError("Необрабатываемая ошибка!")
            #else
            if let error = Errors.SystemError.unknown as? T {
                _subject.onNext(error)
            } else {
                // Не вызываем onError. Просто логируем,
                // что сюда пришла неведомая ошибка
            }
            #endif
        }
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    func trackError<T>(_ errorTracker: ErrorTracker<T>) -> Observable<E> {
        return errorTracker.trackError(from: self)
    }
}

