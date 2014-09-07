---
layout: post
title: "Swift - Type Casting 정리"
description: ""
category: ""
tags: [swift, type cast, downcast, is, as, optional, Any, AnyObject]
---
{% include JB/setup %}

## 형 변환(Type Casting)

형 변환은 인스턴스의 타입을 검사하는 방법으로, 인스턴스를 클래스 계층에서의 슈퍼클래스나 서브클래스를 다룬다.

Swift에 형 변환은 is와 as 연산자로 구현되며, 이들 연산자는 값의 타입이나 값 변환을 다른 타입과 검사하는 간단하게 표현되는 방법이다.

해당 타입이 맞는지 프로토콜에 적합한지 확인하기 위해 형 변환을 사용할 수 있다.

### 형 변환을 위한 클래스 계층 정의(Defining a Class Hierarchy for Type Casting)

특정 클래스 인스턴스의 타입을 검사하고 같은 계층 안에서 다른 클래스 인스턴스를 변환하기 위해서 클래스와 서브클래스의 계층으로 형 변환을 사용할 수 있다. 다음 세개의 코드 조각은 클래스 계층과 이들 클래스 인스턴스를 포함하는 배열을 정의한다.

첫번째 코드 조각은 MediaItem이라는 기반 클래스로, 미디어 라이브러리 안에 항목의 종류를 나타내는 기본 기능을 가진다. 문자열 타입의 name 속성과 init(name:String) 이니셜라이저를 선언한다.

	class MediaItem {
	    var name: String
	    init(name: String) {
	        self.name = name
	    }
	}

다음 코드 조각은 MediaItem의 서브클래스 두개로, 첫번째 서브클래스 Movie는 영화나 동영상의 정보를 캡슐화한다. director 속성이 추가된다. 두번째 서브클래스 Song은 artist 속성과 이니셜라이저가 추가된다.

	class Movie: MediaItem {
	    var director: String
	    init(name: String, director: String) {
	        self.director = director
	        super.init(name: name)
	    }
	}
	 
	class Song: MediaItem {
	    var artist: String
	    init(name: String, artist: String) {
	        self.artist = artist
	        super.init(name: name)
	    }
	}

마지막 코드는 library라는 상수 배열을 만들고 Movie 인스턴스 두개와 Song 인스턴스 세개를 가진다. library 배열의 타입은 배열 내용으로 추론되어 초기화된다. Swift의 형 검사자는 Movie와 Song의 MediaItem 슈퍼클래스를 추론하는 것이 가능하며, library 배열은 [MediaItem] 타입으로 추론한다.

	let library = [
	    Movie(name: "Casablanca", director: "Michael Curtiz"),
	    Song(name: "Blue Suede Shoes", artist: "Elvis Presley"),
	    Movie(name: "Citizen Kane", director: "Orson Welles"),
	    Song(name: "The One And Only", artist: "Chesney Hawkes"),
	    Song(name: "Never Gonna Give You Up", artist: "Rick Astley")
	]
	// the type of "library" is inferred to be [MediaItem]

library에는 Movie와 Song 인스턴스가 저장되어 있다. 배열을 반복하고자 한다면 MediaItem 타입으로 반환받으나 Movie나 Song 타입은 아니다. 원래 타입으로 작업하고자 한다면, 이들 타입을 검사하거나 다른 타입으로 다운캐스트가 필요하다.

### 타입 검사(Checking Type)

형 검사 연산자(`is`)를 사용하여 특정 서브클래스 타입의 인스턴스를 검사한다. 타입 검사 연산자는 인스턴스가 서브클래스 타입이라면 `true`를, 그렇지 않으면 `false`를 반환한다.

다음은 movieCount와 songCount 두개의 변수는 Movie와 Song 인스턴스의 수를 세는 예제이다.

	var movieCount = 0
	var songCount = 0
	 
	for item in library {
	    if item is Movie {
	        ++movieCount
	    } else if item is Song {
	        ++songCount
	    }
	}
	 
	println("Media library contains \(movieCount) movies and \(songCount) songs")
	// prints "Media library contains 2 movies and 3 songs"

library 배열에 모든 항목을 반복하는데, for-in 반복문은 item 상수에 배열 안의 다음 MediaItem을 설정한다.

`item is Movie`는 현재 MediaItem가 Movie 인스턴스라면 true를 반환하고 맞지않으면 false를 반환한다. 유사하게 `item is Song`은 Song 인스턴스인지 검사한다. for-in 반복문이 끝나면 movieCount와 songCount의 값은 얼마나 많은 MediaItem 인스턴스에서 각각의 타입을 찾았는지 셈한다.

### 다운캐스팅(Downcasting)

특정 클래스 타입의 상수 또는 변수는 뒷단에 서브클래스의 인스턴스를 참조할 것이다. 위와 같은 경우를 믿는다면, 형 변환 연산자(`as`)으로 서브클래스 타입을 다운캐스트할 수 있다.

다운캐스팅이 실패할 수 있기 때문에, 형 변환 연산자는 두개의 형식으로 된다. 옵셔널 형식 `as?`는 다운캐스트를 하면 타입의 옵셔널 값을 반환한다. 강제 형식 `as`는 다운캐스트와 강제 언래핑한 결과를 한번에 합한 작업을 한다.

형 변환 연산자(`as?`)의 옵셔널 형식 사용은 다운캐스트가 성공한다는 것을 확신할 수 없을때 한다. 형 변환 연산자의 옵셔널 형식은 항상 옵셔널 값을 반환하고 다운캐스트가 가능하지 않으면 nil 값을 반환할 것이다. 성공적인 다운캐스트를 위해 검사를 해야한다.

형 변환 연산자(`as`)의 강제 형식은 다운캐스트가 항상 성공한다고 확신할 때 사용한다. 형 변환 연산자의 강제 형식은 클래스 타입이 정확하지 않으면 런타입 에러를 발생할 수 있다.

다음은 library 안에 각각의 MediaItem을 반복하여 각각의 항목에 적절한 설명을 출력한다. 이를 하기 위해 각각의 항목은 Movie나 Song으로 접근할 필요가 있지만 MediaItem으로 할 필요는 없다. 각 설명을 위해서 Movie나 Song의 director이나 artist 속성에 접근 할 필요가 있다.

배열에 각각의 항목은 Movie나 Song이다. 각각의 항목의 실제 클래스를 알 수 없으며, 형 변환 연산자(`as?`)의 옵셔널 형식으로 반복문에서 매번 다운캐스트를 검사하도록 적절히 사용할 수 있다.

	for item in library {
	    if let movie = item as? Movie {
	        println("Movie: '\(movie.name)', dir. \(movie.director)")
	    } else if let song = item as? Song {
	        println("Song: '\(song.name)', by \(song.artist)")
	    }
	}
	 
	// Movie: 'Casablanca', dir. Michael Curtiz
	// Song: 'Blue Suede Shoes', by Elvis Presley
	// Movie: 'Citizen Kane', dir. Orson Welles
	// Song: 'The One And Only', by Chesney Hawkes
	// Song: 'Never Gonna Give You Up', by Rick Astley

현재 Movie인 item을 다운캐스트하려고 시작하는데, 이는 item이 MediaItem이기 때문에 Movie가 되는 것이 가능하며, 또한 Song도 됩니다. 심지어 MediaItem도 된다. 불확실하기 때문에 형 변환 연산자의 형식 `as?`은 서브클래스 타입에 다운캐스트를 시도할 때 옵셔널 값을 반환한다. `item as Movie`의 결과는 `Movie?` 타입이거나 옵셔널 `Movie`이다.

옵셔널 Movie에 실제로 값을 가지고 있는지 확인하는 옵셔널 바인딩을 사용한다. 옵셔널 바인딩은 `if let movie = item as? Movie`로 작성되며 다음과 같이 읽힌다.

Movie로 item을 접근하려고 시도하는데 만약 movie라는 임시 상수에 옵셔널 Movie가 반환되어 설정되면 성공한 것이다.

다운캐스팅이 성공하면 movie 속성은 movie 인스턴스를 위해 director 이름이 포함되는 설명을 출력하는데 사용된다. Song 인스턴스도 유사하다.

<div class="alert-info">
	변환에서 실제론 인스턴스를 수정하거나 값을 변경하지 않는다. 근본적인 인스턴스는 그대로 남아 있다. 변환된 타입의 인스턴스로서 간단히 접근하고 다룬다.
</div>

### Any와 AnyObject를 위한 형 변환(Type Casting for Any and AnyObject)

Swift는 두 개의 특수 타입을 지원한다.

* `AnyObject`는 어떠한 클래스 타입의 인스턴스를 표현할 수 있다.
* `Any`는 함수 타입을 제외한 나머지 모든 타입의 인스턴스를 표현할 수 있다.

<div class="alert-info">
	<code>Any</code>와 <code>AnyObject</code>는 명시적으로 행동과 능력이 필요할 때만 사용된다. 특정 타입으로 지정하여 작업하는 것이 더 낫다.
</div>

### AnyObject

Cocoa API를 작업할 때 `[AnyObject]` 타입을 가지는 배열이나 anyobject 타입 값의 배열을 일반적으로 받는다. Objective-C에서는 명시적인 타입 배열을 가지지 않는다. 그러나 API에 대한 알고있는 정보인 배열을 포함하는 객체의 타입에 대해서 확고할 수 있다. 

이러한 상황은 `AnyObject`보다 옵셔널 언래핑이 필요없이도 더욱 특수한 클래스 타입의 배열에서 각각의 항목을 다운캐스트하기 위해 형 변환 연산자(`as`)의 강제 버전을 사용할 수 있다.

다음은 `[AnyObject]` 타입 배열에 Movie 클래스의 인스턴스 3개를 가지는 예제이다.

	let someObjects: [AnyObject] = [
	    Movie(name: "2001: A Space Odyssey", director: "Stanley Kubrick"),
	    Movie(name: "Moon", director: "Duncan Jones"),
	    Movie(name: "Alien", director: "Ridley Scott")
	]

배열에 Movie 인스턴스를 포함하고 있다는 것을 알기때문에 옵셔널 Movie를 사용하지 않고 직접적으로 형 변환 연산자의 강제버전으로 다운캐스트를 한다.

	for object in someObjects {
	    let movie = object as Movie
	    println("Movie: '\(movie.name)', dir. \(movie.director)")
	}
	// Movie: '2001: A Space Odyssey', dir. Stanley Kubrick
	// Movie: 'Moon', dir. Duncan Jones
	// Movie: 'Alien', dir. Ridley Scott

반복문을 돌면서 someObjects 배열은 각 항목을 [Movie] 타입으로 다운캐스팅을 한다.

	for movie in someObjects as [Movie] {
	    println("Movie: '\(movie.name)', dir. \(movie.director)")
	}
	// Movie: '2001: A Space Odyssey', dir. Stanley Kubrick
	// Movie: 'Moon', dir. Duncan Jones
	// Movie: 'Alien', dir. Ridley Scott

### Any

`Any`를 사용하여 다른 타입들을 혼합하여 작업할 수 있다. 다음은 things라는 배열로 `Any` 타입의 값을 저장한다.

	var things = [Any]()
	 
	things.append(0)
	things.append(0.0)
	things.append(42)
	things.append(3.14159)
	things.append("hello")
	things.append((3.0, 5.0))
	things.append(Movie(name: "Ghostbusters", director: "Ivan Reitman"))

things 배열은 정수 값 두 개, 부동 소수점 값 두 개, 문자열 값 한 개, 튜플 (Double, Double) 타입 한 개, movie 타입 값 한개를 가진다.

switch 문의 경우 안에서 `Any`나 `AnyObject`로 알려진 특정 상수나 변수 타입이 발견하기 위해서 `is`와 `as` 연산자가 사용된다. switch문 안에서 things 배열이 반복되고 각 항목의 타입을 조회한다. 다음은 switch 문 경우들을 나타낸 예제이다.

	for thing in things {
	    switch thing {
	    case 0 as Int:
	        println("zero as an Int")
	    case 0 as Double:
	        println("zero as a Double")
	    case let someInt as Int:
	        println("an integer value of \(someInt)")
	    case let someDouble as Double where someDouble > 0:
	        println("a positive double value of \(someDouble)")
	    case is Double:
	        println("some other double value that I don't want to print")
	    case let someString as String:
	        println("a string value of \"\(someString)\"")
	    case let (x, y) as (Double, Double):
	        println("an (x, y) point at \(x), \(y)")
	    case let movie as Movie:
	        println("a movie called '\(movie.name)', dir. \(movie.director)")
	    default:
	        println("something else")
	    }
	}
	 
	// zero as an Int
	// zero as a Double
	// an integer value of 42
	// a positive double value of 3.14159
	// a string value of "hello"
	// an (x, y) point at 3.0, 5.0
	// a movie called 'Ghostbusters', dir. Ivan Reitman

<div class="alert-info">
	switch 문의 경우는 형 변환 연산자의 강제 버전(<code>as?</code>가 아닌 <code>as</code>)으로 검사하고 지정 타입으로 변환하는데 사용한다. 이 검사는 switch 경우 문의 컨텍스트 안에서 항상 안전하다.
</div>