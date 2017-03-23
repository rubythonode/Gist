//: Playground - noun: a place where people can play


/*:

// MARK: of

/**
This method creates a new Observable instance with a variable number of elements.

- seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

- parameter elements: Elements to generate.
- parameter scheduler: Scheduler to send elements on. If `nil`, elements are sent immediatelly on subscription.
- returns: The observable sequence whose elements are pulled from the given arguments.
*/

*/

import UIKit
import RxSwift
import RxCocoa


//let bag = DisposeBag()
//var publishSubject = PublishSubject<String>()
//
//let subscription1 = publishSubject.subscribe(onNext:{
//	print(#line, $0)
//}).addDisposableTo(bag)
//
//// Subscription1 receives these 2 events, Subscription won't
//
//publishSubject.onNext("Hello")
//publishSubject.onNext("Again")

// Sub2 will not get "Hello" and "Again" because it susbcribed later
//let subscription2 = publishSubject.subscribe(onNext:{
//	print(#line,$0)
//})

//publishSubject.onNext("Both Subscriptions receive this message")

let first = Observable.from([1, 2, 3, 4, 5, 6, 7])
let second = Observable.from([10, 20, 30, 40, 50, 60, 70])

// scan == reduce in swift

//first.scan(0) { (seed, value) in
//	return value + seed
//	}.subscribe(onNext: {
//	print($0)
//})

//let sequenceOfSequences = Observable.of(first, second)
//
//sequenceOfSequences
//	.flatMap{ return $0 }
//	.subscribe(onNext:{
//	print($0)
//})
//


//Observable.of(2,30,22,5,60,1).filter{$0 > 10}.subscribe(onNext:{
//	print($0)
//})

//Observable.of(1,2,2, 2,11, 11, 1, 1, 3).distinctUntilChanged().subscribe(onNext:{
//	print($0)
//})
//
//Observable.of("2","3").startWith("1").subscribe(onNext:{
//	print($0)
//})

//let publish1 = PublishSubject<Int>()
//let publish2 = PublishSubject<Int>()
//
//Observable.of(publish1,publish2).merge().subscribe(onNext:{
//	print($0)
//})
//publish1.onNext(20)
//publish1.onNext(40)
//publish1.onNext(60)
//publish2.onNext(1)
//publish1.onNext(80)
//publish1.onNext(100)
//publish2.onNext(1)
//
//
//let a = Observable.of(1,2,3,4,5)
//let b = Observable.of("a","b","c","d")
//let c = Observable.of("a","b","c","d")
//
//Observable.zip(a,b,c){
//	return ($0,$1,$2)
// }.subscribe {
//	print($0)
//}

print("")
Observable.of(1,2,3,4,5).do(onNext: {
	$0 * 10 // This has no effect on the actual subscription
}).subscribe(onNext:{
	print($0)
})

let publish1 = PublishSubject<Int>()
let publish2 = PublishSubject<Int>()

let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

Observable.of(publish1,publish2)
	.observeOn(concurrentScheduler)
	.merge()
	.subscribeOn(MainScheduler())
	.subscribe(onNext:{
		print($0)
	})

publish1.onNext(20)
publish1.onNext(40)




