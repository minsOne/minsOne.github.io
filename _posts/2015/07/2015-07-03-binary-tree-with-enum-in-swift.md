---
layout: post
title: "[Swift]Enumeration를 이용한 Binary Tree 만들기"
description: ""
category: "Mac/iOS"
tags: [swift, generic, enum, enumeration, switch, case, box, class, tree, b-tree, binary tree]
---
{% include JB/setup %}

### Binary Tree

이전 글에서 enum을 통해서 error handling을 다루었습니다. 이번에는 enum을 사용하여 binary tree를 작성해보도록 하겠습니다.

이전에서 사용한 Box 클래스를 사용하여 Tree 형태를 구성합니다.

	final class Box<T> {
		let value: T

		init(_ value: T) {
			self.value = value
		}
	}
	enum Tree<T> {
		case Leaf
		case Node(Box<Tree<T>>, Box<T>, Box<Tree<T>>)
	}

위와 같이 Tree는 아무것도 없는 Leaf와 값을 가지는 Node로 구성되어 있습니다. Node는 Box로 감싸진 왼쪽 가지, 오른쪽 가지 그리고 값을 가지고 있습니다.

Tree는 다음과 같이 선언하고 값을 얻을 수 있습니다.

	let five: Tree<Int> = Tree.Node(Box(Tree.Leaf), Box(5), Box(Tree.Leaf))

	switch five {
	case .Leaf:
		println("Empty")
	case let .Node(left, box, right):
		fprintln("Value : \(box.value)")
	}

위의 코드에서 Box 객체를 가지고 value 값을 출력합니다. 

단일 Tree를 만든다면 다음과 같이 함수를 작성할 수 있습니다.

	func one<T>(x: T) -> Tree<T> {
		return Tree.Node(Box(Tree.Leaf), Box(x), Box(Tree.Leaf))
	}

	func empty<T>() -> Tree<T> {
		return Tree.Leaf
	}

Tree에 값이 몇 개 있는지 함수로 작성할 수 있습니다.

	func count<T>(tree: Tree<T>) -> Int {
		switch tree {
		case .Leaf:
			return 0
		case let .Node(left, box, right):
			return count(left.value) + 1 + count(right.value)
		}
	}

Tree의 값들을 나열하는 함수를 작성할 수 있습니다.

	func elements<T>(tree: Tree<T>) -> [T] {
		switch tree {
		case .Leaf:
			return []
		case let .Node(left, box, right):
			return elements(left.value) + [box.value] + elements(right.value)
		}
	}

Tree에 찾고자 하는 값이 있는지 확인하는 함수를 작성할 수 있습니다.

	func isContains<T: Comparable>(x: T, tree: Tree<T>) -> Bool {
		switch tree {
		case .Leaf:
			return false
		case let .Node(_, box, _) where x == box.value:
			return true
		case let .Node(left, box, _) where x < box.value:
			return isContains(x, left.value)
		case let .Node(_, box, right) where x > box.value:
			return isContains(x, right.value)
		default:
			return false
		}
	}

Tree에 값을 추가하는 함수를 작성할 수 있습니다.

	func insertTree<T: Comparable>(x: T, tree: Tree<T>) -> Tree<T> {
		switch tree {
		case .Leaf:
			return one(x)
		case let .Node(_, box, _) where x == box.value:
			return tree
		case let .Node(left, box, right) where x < box.value:
			return Tree.Node( Box(insertTree(x, left.value)), box, right)
		case let .Node(left, box, right) where x > box.value:
			return Tree.Node(left, box, Box(insertTree(x, right.value)) )
		default:
			return Tree.Leaf
		}
	}

Tree에 값을 삭제하는 함수는 알아서 작성하시길 바랍니다. ㅎㅎㅎ

### 정리

이전 글에서 error handling을 enum으로 할 수 있었고, 이번에는 enum으로 Binary Tree를 작성할 수 있었습니다.

일반적으로 구조체 또는 클래스를 작성해야 할텐데 enum을 통해서 코드를 작성할 수 있어 좀 더 새롭게 언어를 볼 수 있어서 좋은 경험을 얻었습니다.

### 참고 자료

* [Functional Programming in Swift][Functional Programming in Swift]

[Functional Programming in Swift]: http://www.objc.io/books/