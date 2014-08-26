---
layout: post
title: "Swift - String and Characters 정리"
description: ""
category: "mac/ios"
tags: [swift, string, character, literal, type, scalar, unicode, utf]
---
{% include JB/setup %}

## 문자열과 문자(Strings and Characters)

문자열은 문자들의 집합.

Swift 문자열은 String 타입으로 표시되면 Character 타입 값의 집합을 표현한 것.

Swift 문자열과 문자 타입은 빠르며 유니코드에 호환됨.

두 개의 문자열을 연결할 때 `+` 연산자를 사용하여 간단함.

Swift 문자열 타입은 Foundation의 NSString 클래스에 연결됨. Cocoa 또는 Cocoa Touch의 Foundation 프레임워크에 NSString API를 호출하여 String 값을 만드는 것이 가능함. 특정 API에서 NSString 인스턴스에 필요한 String 값으로 사용할 수 있음.


### 문자열 리터럴(String Literals)

문자열 리터럴은 상수나 변수의 초기 값을 사용할 수 있도록 함.

	let someString = "Some string literal value"

Swift에서 someString은 String 타입의 영향을 받음. 이는 초기 값이 문자열 리터럴 값이기 때문.

### 빈 문자열 초기화(Initializing an Empty String)

빈 문자열은 String 인스턴스를 초기화 하거나 빈 문자열 리터럴 값을 변수에 할당함.

	var emptyString = ""               // empty string literal
	var anotherEmptyString = String()  // initializer syntax
	// these two strings are both empty, and are equivalent to each other

빈 문자열 값은 isEmpty 속성을 통해 확인할 수 있음.

	if emptyString.isEmpty {
	    println("Nothing to see here")
	}
	// prints "Nothing to see here"


### 문자열 가변성(String Mutability)

특정 문자열을 변수에 할당하여 수정할 수 있는지를 나타내거나 상수를 말함.

	var variableString = "Horse"
	variableString += " and carriage"
	// variableString is now "Horse and carriage"
	 
	let constantString = "Highlander"
	constantString += " and another Highlander"
	// this reports a compile-time error - a constant string cannot be modified

Objective-C와 Cocoa에선 다르게 NSString과  NSMutableString 두 개의 클래스를 선택하여 사용함.


### 문자열은 값 타입(Strings Are Value Type)

Swift 문자열 타입은 값 타입. 문자열 값은 함수나 메소드를 통해 문자열 값이 복사되어 전달됨. 전달된 문자열은 원본이 아님.

Cocoa에 NSString과는 다르게 NSString을 메소드나 함수에 전달하면 같은 단일 NSString에 참조를 할당함. 특별히 요청하지 않는 이상 문자열 값은 복사되지 않음.


### 문자 작업(Working with Characters)

Swift 문자열 타입은 지정된 순서로 문자 값의 집합으로 표시. 

`for-in` 반복문을 통해 각가의 문자 값에 접근 가능함.

	for character in "Dog!🐶" {
	    println(character)
	}
	// D
	// o
	// g
	// !
	// 🐶

또한, 문자는 독립적으로 상수나 문자로 사용 가능.

	let yenSign: Character = "¥"


### 문자열과 문자의 연결(Concatenating Strings and Characters)

String 값은 덧셈 연산자(+)를 가지고 새로운 문자열 값을 생성함.

	let string1 = "hello"
	let string2 = " there"
	var welcome = string1 + string2
	// welcome now equals "hello there"

문자열 값과 기존 문자열 값을 덧셈 할당 연산자(+=)를 통해 연결함.

	var instruction = "look over"
	instruction += string2
	// instruction now equals "look over there"

문자와 문자열 값은 String 타입의 `append` 메소드를 통해 합침.

	let exclamationMark: Character = "!"
	welcome.append(exclamationMark)
	// welcome now equals "hello there!"


### 문자열 삽입(String Interpolation)

문자열 삽입은 상수, 변수, 리터럴 그리고 표현식을 혼합하여 문자열 리터럴 안에 값을 포함시켜 새로운 문자열 값을 만드는 방법.

각 항목은 백슬래쉬가 앞에 한 쌍의 괄호로 쌓여짐. -> \\(<#Value#>)

	let multiplier = 3
	let message = "\(multiplier) times 2.5 is \(Double(multiplier) * 2.5)"
	// message is "3 times 2.5 is 7.5"


### 유니코드(Unicode)

유니코드는 다른 시스템에서 쓸 수 있도록 하는 국제 표준. 거의 모든 문자와 언어를 표현 가능. Swift에서 문자열 타입과 문자 타입은 모든 유니코드와 호환.

### 유니코드 스칼라(Unicode Scalars)

Swift의 네이티브 문자열 타입은 유니코드 스칼라 값에서 만들어짐. 유니코드 스칼라는 21-bit.

### 문자열 리터럴에 특수 유니코드 문자(Special Unicode Characters in String Literals)

탈출 특수 문자 - \0 (null character), \\\ (backslash), \t (horizontal tab), \n (line feed), \r (carriage return), \\" (double quote) and \\' (single quote)

임의의 유니코드 스칼라는 \u{n}으로 작성, n는 1-8자리 16진수

	let wiseWords = "\"Imagination is more important than knowledge\" - Einstein"
	// "Imagination is more important than knowledge" - Einstein
	let dollarSign = "\u{24}"        // $,  Unicode scalar U+0024
	let blackHeart = "\u{2665}"      // ♥,  Unicode scalar U+2665
	let sparklingHeart = "\u{1F496}" // 💖, Unicode scalar U+1F496


### 확장 자소 클러스터(Extended Grapheme Clusters)

Swift의 문자 타입 모든 인스턴스는 단일 확장 자소 클러스터를 표현함. 확장 자소 클러스터는 하나 이상 유니코드 스칼라의 순서로 인간이 읽을 수 있는 문자를 만듬.

	let eAcute: Character = "\u{E9}"                         // é
	let combinedEAcute: Character = "\u{65}\u{301}"          // e followed by ́
	// eAcute is é, combinedEAcute is é

	let precomposed: Character = "\u{D55C}"                  // 한
	let decomposed: Character = "\u{1112}\u{1161}\u{11AB}"   // ᄒ, ᅡ, ᆫ
	// precomposed is 한, decomposed is 한

	let enclosedEAcute: Character = "\u{E9}\u{20DD}"
	// enclosedEAcute is é⃝

	let regionalIndicatorForUS: Character = "\u{1F1FA}\u{1F1F8}"
	// regionalIndicatorForUS is 🇺🇸


### 문자 세기(Counting Characters)

문자열에 문자를 세기 위해 `countElements` 전역 함수를 호출하며 함수의 인자로 문자열을 넘겨줌.

	let unusualMenagerie = "Koala 🐨, Snail 🐌, Penguin 🐧, Dromedary 🐪"
	println("unusualMenagerie has \(countElements(unusualMenagerie)) characters")
	// prints "unusualMenagerie has 40 characters"

Swift에서 문자 값을 위한 확장 자소 클러스터를 사용하여 문자열에 연결하거나 수정하지만 이는 문자열의 문자 갯수에 항상 영향을 주진 않음.

	var word = "cafe"
	println("the number of characters in \(word) is \(countElements(word))")
	// prints "the number of characters in cafe is 4"
	 
	word += "\u{301}"    // COMBINING ACUTE ACCENT, U+0301
	 
	println("the number of characters in \(word) is \(countElements(word))")
	// prints "the number of characters in café is 4"

Swift에 String의 countElements와 NSString의 length 속성과는 항상 같지 않음. 이는 NSString은 16-bit 코드를 기반으로 하기 때문에 확장 자소 클러스터를 지원하지 못함.


### 문자열 비교(COmparing Strings)

Swift는 문자를 비교하는 세 가지 방법을 제공. 문자열과 문자가 같음, 전위가 같음, 후위가 같음.

### 문자열과 문자 같음(String and Character Equality)

문자열과 문자는 같음 연산자(==)와 같지 않음 연산자(!=)를 가지고 확인함.

	let quotation = "We're a lot alike, you and I."
	let sameQuotation = "We're a lot alike, you and I."
	if quotation == sameQuotation {
	    println("These two strings are considered equal")
	}
	// prints "These two strings are considered equal"

두 문자열 값은 확장 자소 클러스터가 다르게 적용되어도 같다고 간주함.

	// "Voulez-vous un café?" using LATIN SMALL LETTER E WITH ACUTE
	let eAcuteQuestion = "Voulez-vous un caf\u{E9}?"
	 
	// "Voulez-vous un café?" using LATIN SMALL LETTER E and COMBINING ACUTE ACCENT
	let combinedEAcuteQuestion = "Voulez-vous un caf\u{65}\u{301}?"
	 
	if eAcuteQuestion == combinedEAcuteQuestion {
	    println("These two strings are considered equal")
	}
	// prints "These two strings are considered equal"

반대로 보기에는 같지만 다른 문자 비교시 다르다고 간주함.

	let latinCapitalLetterA: Character = "\u{41}"
	 
	let cyrillicCapitalLetterA: Character = "\u{0410}"
	 
	if latinCapitalLetterA != cyrillicCapitalLetterA {
	    println("These two characters are not equivalent")
	}
	// prints "These two characters are not equivalent"

### 전위 후위 같음(Prefix and Suffix Equality)

문자열에 `hasPrefix`와 `hasSuffix` 메소드를 통해 같은 값이 있는지 확인할 수 있음.

	let romeoAndJuliet = [
	    "Act 1 Scene 1: Verona, A public place",
	    "Act 1 Scene 2: Capulet's mansion",
	    "Act 1 Scene 3: A room in Capulet's mansion",
	    "Act 1 Scene 4: A street outside Capulet's mansion",
	    "Act 1 Scene 5: The Great Hall in Capulet's mansion",
	    "Act 2 Scene 1: Outside Capulet's mansion",
	    "Act 2 Scene 2: Capulet's orchard",
	    "Act 2 Scene 3: Outside Friar Lawrence's cell",
	    "Act 2 Scene 4: A street in Verona",
	    "Act 2 Scene 5: Capulet's mansion",
	    "Act 2 Scene 6: Friar Lawrence's cell"
	]

	var act1SceneCount = 0
	for scene in romeoAndJuliet {
	    if scene.hasPrefix("Act 1 ") {
	        ++act1SceneCount
	    }
	}
	println("There are \(act1SceneCount) scenes in Act 1")
	// prints "There are 5 scenes in Act 1"

	var mansionCount = 0
	var cellCount = 0
	for scene in romeoAndJuliet {
	    if scene.hasSuffix("Capulet's mansion") {
	        ++mansionCount
	    } else if scene.hasSuffix("Friar Lawrence's cell") {
	        ++cellCount
	    }
	}
	println("\(mansionCount) mansion scenes; \(cellCount) cell scenes")
	// prints "6 mansion scenes; 2 cell scenes"


### 문자열에 유니코드 표시(Unicode Representations of Strings)

문자열 값은 UTF-8, UTF-16, 21-bit Unicode scalar 값에 접근이 가능함.(utf8, utf16, unicodeScalars 속성)

	let dogString = "Dog‼🐶"


### UTF-8 표시(UTF-8 Representation)

문자열 UTF-8 표시는 utf8 속성을 통해 접근, String.UTF8View 타입이며 이는 UInt8 타입 값의 집합임.

	for codeUnit in dogString.utf8 {
	    print("\(codeUnit) ")
	}
	// 68 111 103 226 128 188 240 159 144 182

### UTF-16 표시(UTF-16 Representation)

문자열 UTF-16 표시는 utf16 속성을 통해 접근, String.UTF16View 타입이며 이는 UInt16 타입 값의 집합임.

	for codeUnit in dogString.utf16 {
	    print("\(codeUnit) ")
	}
	// 68 111 103 8252 55357 56374

### 유니코드 스칼라 표시(Unicode Scalar Representation)

문자열 값의 유니코드 스칼라 표시는 unicodeScalars 속성을 통해 접근, UnicodeScalarView 타입이며 이는 UnicodeScalar 타입 값의 집합임.

	for scalar in dogString.unicodeScalars {
	    print("\(scalar.value) ")
	}
	// 68 111 103 8252 128054

	for scalar in dogString.unicodeScalars {
	    println("\(scalar) ")
	}
	// D
	// o
	// g
	// ‼
	// 🐶