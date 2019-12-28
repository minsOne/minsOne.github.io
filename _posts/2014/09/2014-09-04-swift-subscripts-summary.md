---
layout: post
title: "[Swift]Subscripts 정리"
description: ""
category: "mac/ios"
tags: [swift, subscript, getter, setter, get, set, newValue, overloading]
---
{% include JB/setup %}

## 서브스크립트(Subscripts)

클래스, 구조 그리고 열거형은 서브스크립트를 정의할 수 있는데 컬렉션, 리스트 또는 순열의 멤버 항목에 접근하기 위한 단축키임. 서브스크립트를 사용하여 설정과 검색을 위해 메소드를 나눌 필요 없이 인덱스로 값을 설정하고 검색함. 예를 들어 someArray[index]로 배열 인스턴스 항목과 someDictionary[key]로 딕셔너리 인스턴스 항목을 접근할 수 있음.

단일 타입에서 다중 서브스크립트를 정의할 수 있고, 서브스크립트에 인덱스 값 타입을 넘기는 것을 기반으로 하여 사용하기 적절한 서브스크립트를 중복 선택할 수 있음. 서브스크립트는 단일 차원에서 제한이 없으며, 사용자 타입에 맞추어 필요한 다중 입력 인자를 가지는 서브스크립트를 정의할 수 있음.

### 서브스크립트 문법(Subscript Syntax)

서브스크립트는 인스턴스 이름 뒤에 중괄호 안에서 하나 이상의 값으로 작성된 타입 인스턴스에 조회하는 것이 가능함. 이러한 문법은 인스턴스 메소드 문법이나 계산 속성 문법과 유사. 서브크립트 정의는 subscript 키워드로 작성하며, 하나 이상의 입력 인자와 반환 타입을 지정하며, 같은 방법으로는 인스턴스 메소드가 있음. 그러나 인스턴스 메소드와는 다르게 서브스크립트는 읽기-쓰기나 읽기 전용으로 되어 있음. 이 행위는 계산 속성을 위한 것으로서 같은 방법으로 getter와 setter에 의해 전달됨.

	subscript(index: Int) -> Int {
	    get {
	        // return an appropriate subscript value here
	    }
	    set(newValue) {
	        // perform a suitable setting action here
	    }
	}

newValue 타입은 서브스크립트의 반환 값과 동일. 계산 속성과 같이 setter의 `(newValue)` 인자를 지정하여 선택할 수 없음. 만약 아무런 지원도 없다면 newValue라는 기본 값은 setter에 제공됨.

읽기 전용 계산 속성으로서 읽기 전용 서브스크립트를 위해 `get` 키워드를 없앨 수 있음.

	subscript(index: Int) -> Int {
	    // return an appropriate subscript value here
	}

다음은 읽기 전용 서브스크립트 구현 예제로, timeTable 구조체가 정수의 n배 표현함.

	struct TimesTable {
	    let multiplier: Int
	    subscript(index: Int) -> Int {
	        return multiplier * index
	    }
	}
	let threeTimesTable = TimesTable(multiplier: 3)
	println("six times three is \(threeTimesTable[6])")
	// prints "six times three is 18"

이 예제에서 TimesTable의 새로운 인스턴스는 세 배의 배수를 표현하는데 구조체의 initializer에 인스턴스의 multiplier 인자 값 사용을 위한 값으로 값 3을 넘겨줌.

호출되는 서브스크립트 threeTimesTable[6]로 threeTimesTable 인스턴스를 조회할 수 있음. 이 세 배 배수에서 6번째를 요청하면, 6의 3배인 18을 반환함.

<div class="alert-info">
n배 테이블은 고정된 산술 규칙이며 threeTimesTable[someIndex]에 새로운 값ㅇ로 설정할 수 없으며, timeTable 서브스크립트는 읽기 전용 서브스크립트로 정의됨.
</div>

### 서브스크립트 사용(Subscript Usage)

정확한 서브스크립트의 의미는 사용되는 컨택스트에 의존함. 서브스크립트는 일반적으로 컬렉션, 리스트 또는 순열의 멤버 항목에 접근하는 단축키로서 사용. 특정 클래스나 구조체의 기능을 위한 가장 적합한 방법으로 서브스크립트를 자유롭게 구현할 수 있음.

다음 예제는 Swift의 딕셔너리 타입에서 딕셔너리 인스턴스에 값을 저장하고 반환하는 서브스크립트를 구현함. 서브스크립트 중괄호 안에 딕셔너리 키 타입의 키는 딕셔너리에 값을 설정할 수 있으며, 서브스크립트로 딕셔너리 값 타입의 값에 할당할 수 있음.

	var numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
	numberOfLegs["bird"] = 2

위 예제에서 numberOfLegs라는 변수와 세 개의 key-value 쌍을 가지는 딕셔너리 표현식으로 초기화를 정의함. numberOfLegs 딕셔너리의 타입은 `[String: Int]`로 추론함. 딕셔너리를 만든 후 "bird" 문자열 키와 Int 타입의 값 2가 딕셔너리에 추가되도록 사용함.

<div class="alert-info">
Swift 딕셔너리 타입은옵셔널 key-value 서브스크립트로 구현되며 옵셔널 타입을 받거나 반환함. numberOfLegs 딕셔너리에서 key-value 서브스크립트는 "Int?"" 또는 "옵셔널 Int" 타입의 값을 받거나 반환함. 딕셔너리 타입은 옵셔널 서브스크립트 타입으로 사용하며, 이는 모든 키가 값을 가지고 있지 않다는 사실에 근거하고, 키에 nil값을 할당하여 삭제하는 방법이 있음.
</div>

### 서브스크립트 옵션(Subscript Options)

서브스크립트는 입력 인자의 어떤 값이든 취하며, 이들 입력 인자는 어떤 타입이든 가능함. 또한, 서브스크립트는 어떤 타입도 반환하며, 변수 인자와 가변 인자도 사용이 가능하지만, in-out 인자는 사용할 수 없으며 기본 인자 값을 지원하지 않음.

클래스나 구조체는 필요한 만큼 많은 서브스크립트 구현을 지원할 수 있으며, 적합한 서브스크립트는 값의 타입 또는 서브스크립트 괄호 안에 포함된 값을 기반으로 추론하여 사용됨. 많은 서브스크립트 정의는 서브스크립트 오버로딩으로 알려짐.

대부분 일반적인 단일 인자를 가지는 서브스크립트와는 다르게, 적합한 타입이라면 다중 인자를 가지는 서브스크립트를 정의할 수 있음. 다음은 Matrix 구조체 예제로 Double 값의 이차원 행렬을 표현함. Matrix 구조체의 서브스크립트는 두 개의 정수 인자를 가짐.

	struct Matrix {
	    let rows: Int, columns: Int
	    var grid: [Double]
	    init(rows: Int, columns: Int) {
	        self.rows = rows
	        self.columns = columns
	        grid = Array(count: rows * columns, repeatedValue: 0.0)
	    }
	    func indexIsValidForRow(row: Int, column: Int) -> Bool {
	        return row >= 0 && row < rows && column >= 0 && column < columns
	    }
	    subscript(row: Int, column: Int) -> Double {
	        get {
	            assert(indexIsValidForRow(row, column: column), "Index out of range")
	            return grid[(row * columns) + column]
	        }
	        set {
	            assert(indexIsValidForRow(row, column: column), "Index out of range")
	            grid[(row * columns) + column] = newValue
	        }
	    }
	}

Matrix는 rows와 columns라는 두 개의 인자를 가지는 초기화를 지원하고, Double 타입의 값을 rows * columns의 크기에 저장하는 배열을 생성함. matrix에 각각의 위치는 0.0 값으로 초기화됨. 이것을 얻기 위해서 배열의 크기와 각각 0.0으로 초기화된 셀을 배열 초기화에 넘겨 올바른 크기의 새로운 배열을 초기화하여 생성함.

새로운 Matrix 인스턴스는 적절한 행과 열을 초기화에 넘겨 만들 수 있음.

	var matrix = Matrix(rows: 2, columns: 2)

앞선 예제에서 생성한 새로운 Matrix 인스턴스는 행과 열이 각각 두 개씩 있으며 Matrix 인스턴스에 grid 배열은 효과적으로 행렬을 눕힌 버전으로 왼쪽 위에서 오른쪽 아래로 읽음.

<img src="{{ site.production_url }}/image/2014/09/subscriptMatrix01_2x.png" alt="subscriptMatrix01" style="width: 400px;"/><br/>

행렬에 값은 콤마로 나누는 서브스크립트 안에 행과 열 값을 넘겨서 설정할 수 있음.

	matrix[0, 1] = 1.5
	matrix[1, 0] = 3.2

두개의 문은 서브스크립트의 setter을 호출하여 행렬의 위에서 오른쪽 위치에 1.5 값으로 설정하며 아래에서 왼쪽 위치에 3.2 값으로 설정함.

<img src="{{ site.production_url }}/image/2014/09/subscriptMatrix02_2x.png" alt="subscriptMatrix02" style="width: 200px;"/><br/>

Matrix 서브스크립트 getter와 setter는 서브스크립트의 행과 열 값이 유효한지 확인하는 assertion을 가짐. 이 assertion을 지원히기 위해 Matrix는 indexIsValidForRow(_:column)이라는 편리한 메소드를 포함하며, 요청한 row와 column이 행렬 범위 안에 있는지 확인함.

	func indexIsValidForRow(row: Int, column: Int) -> Bool {
	    return row >= 0 && row < rows && column >= 0 && column < columns
	}

서브스크립트 접근이 행렬 밖으로 나가면 assertion이 발생함.

	let someValue = matrix[2, 2]
	// this triggers an assert, because [2, 2] is outside of the matrix bounds
