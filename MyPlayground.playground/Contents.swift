//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa



var sampleObservable = Variable(1) // 


sampleObservable.asObservable()
	.subscribe(onNext: { val in
		print(val)
}, onError: { error in
	print(error)
}, onCompleted: { 
	print("complete")
}).dispose()


//sampleObservable.value = 10
let val = Observable.just("1111")

val.subscribe(onNext: {
	print($0)
})