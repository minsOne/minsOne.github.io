---
layout: post
title: "[Algorithm]Binary Tree"
description: ""
category: "programming"
tags: [algorithm, binary, tree, preorder, inorder, postorder, levelorder]
---
{% include JB/setup %}

## 이진 트리

이진 트리(binary tree)는 한 노드가 최대 2개의 자식 노드를 가지는 트리를 말하며 첫 번째 노드는 부모(parent), 자식 노드는 왼쪽(left), 오른쪽(right)라고 불립니다.

![Binary Tree Example](http://upload.wikimedia.org/wikipedia/commons/f/f7/Binary_tree.svg)

* 루트 이진 트리(rooted binary tree)는 모든 노드의 자식이 최대 2개인 루트를 가진 트리입니다.
* 포화 이진 트리(full binary tree)는 모든 노드가 2개의 자식 노드를 가지며 모든 레벨이 꽉 찬 트리입니다.
* 완전 이진 트리(complete binary tree)는 포화 이진 트리같이 모든 레벨이 꽉 찬 트리는 아니지만 모든 노드가 2개의 자식 노드를 가지는 트리입니다.


## 이진 탐색 트리

이진 트리의 모든 노드를 방문하여 작업하는 것을 이진 탐색 트리라고 합니다. 대개 다음과 같은 방법으로 작업을 합니다.

* 전위 순회(pre-order)는 루트 노드에서 왼쪽 서브 트리를 전위 순회하고 오른쪽 서브 트리를 전위 순회합니다. 깊이 우선 순회(depth-first traversal)라고도 합니다.
* 중위 순회(in-order)는 왼쪽 서브 트리를 중위 순회하고 노드를 방문하고 오른쪽 서브 트리를 중위 순회합니다. 대칭 순회(symmetric traversal)이라고 합니다.
* 후위 순회(post-order)는 왼쪽 서브 트리를 후위 순회하고 오른쪽 서브 트리를 후위순회 하고 노드를 방문합니다. 
* 레벨 순서 순회(level-order)는 모든 노드를 낮은 레벨부터 차례대로 순회합니다. 너비 우선 순회(breadth-first traversal)라고도 합니다.

![Binary tree](http://upload.wikimedia.org/wikipedia/commons/6/67/Sorted_binary_tree.svg)

위의 이미지에서 앞에서 설명한 방법으로 탐색하게되면 다음과 같습니다.

* 전위 순회 : F -> B -> A -> D -> C -> E -> G -> I -> H
* 중위 순회 : A -> B -> C -> D -> E -> F -> G -> I -> H
* 후위 순회 : A -> C -> E -> D -> B -> H -> I -> G -> F
* 레벨 순서 순회 : F -> B -> G -> A -> D -> I -> C -> E -> H

### 의사코드

전위 순회

	preorder(node)
		print node->value
		if node->left != null then
			preorder(node->left)
		elseif node->right != null then
			preorder(node->right)
		end
	end

중위 순회

	inorder(node)
		if node->left != null then
			inorder(node->left)
		end

		print node->value

		if node->right != null then
			inorder(node->right)
		end
	end

후위 순회

	postorder(node)
		if node->left != null then
			postorder(node->left)
		end
		if node->right != null then
			postorder(node->right)
		end
		print node->value
	end


레벨 순서 순회

	levelorder(newNode)
		q = empty queue
		q.append(newNode)
		while(not q.empty)
			node = q.dequeue
			print node->value

			if node->left != null then
				q.append(node->left)
			end
			if node->right != null then
				q.append(node->right)
			end
		end
	end

## 참고

- [wikipedia 이진트리](http://ko.wikipedia.org/wiki/이진트리)