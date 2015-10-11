---
layout: post
title: "[Swift][일일 코드 #28]코딩도장 - Spiral Array"
description: ""
category: "programming"
tags: [swift, reduce, closure, switch, print]
---
{% include JB/setup %}

### Problem - Spiral Array (Level 3)

문제는 다음과 같다:

	6 6

	  0   1   2   3   4   5
	 19  20  21  22  23   6
	 18  31  32  33  24   7
	 17  30  35  34  25   8
	 16  29  28  27  26   9
	 15  14  13  12  11  10

위처럼 6 6이라는 입력을 주면 6 X 6 매트릭스에 나선형 회전을 한 값을 출력해야 한다.

### Solution

1.맵의 모든 값을 -1로 초기화 합니다.

1.오른쪽 방향으로 시작합니다. 다음 값이 -1이라면 진행 방향은 그대로 두고, -1이 아니거나 범위를 벗어나면 다음 순서대로 방향을 바꿉니다. ( Right -> Down -> Left -> Up )

	extension Int {
		func isNotMinus() -> Bool {
			return self >= 0 ? true : false
		}
	}

	enum Direction {
		case Right, Down, Left, Up
	}

	func nextSpiralF(var spiralMap: Array<Array<Int>>)(var direct: Direction) -> ((x: Int, y: Int), Int) -> ((Direction, (x: Int, y: Int), Array<Array<Int>>)) {
		return {
			spiralMap[$0.y][$0.x] = $1
			switch direct {
			case .Right where $0.x + 1 >= spiralMap[0].count || spiralMap[$0.y][$0.x + 1].isNotMinus() : direct = .Down
			case .Down where $0.y + 1 >= spiralMap.count || spiralMap[$0.y + 1][$0.x].isNotMinus() : direct = .Left
			case .Left where $0.x - 1 < 0 || spiralMap[$0.y][$0.x - 1].isNotMinus() : direct = .Up
			case .Up where $0.y - 1 < 0 || spiralMap[$0.y - 1][$0.x].isNotMinus() : direct = .Right
			default: break
			}
			return (direct, $0, spiralMap)
		}
	}

	func printSpiralMap(spiralMap: Array<Array<Int>>) {
		spiralMap.forEach {
			$0.forEach { print(String(format: "%3d", $0), separator: "", terminator: " ") }
			print("")
		}
	}

	func main(x x: Int, y: Int) {
		let nextSpiral = nextSpiralF(Array<Array<Int>>(count: y, repeatedValue: Array(count: x, repeatedValue: -1)))(direct: .Right)
		let result = (0..<x * y).reduce( (direct: Direction.Right, point: (x: -1, y: 0), spiralMap: Array<Array<Int>>()) ) {
			switch $0.0.direct {
			case .Right: return nextSpiral(($0.0.point.x + 1, $0.0.point.y), $0.1)
			case .Down: return nextSpiral(($0.0.point.x, $0.0.point.y + 1), $0.1)
			case .Left: return nextSpiral(($0.0.point.x - 1, $0.0.point.y), $0.1)
			case .Up: return  nextSpiral(($0.0.point.x, $0.0.point.y - 1), $0.1)
			}
		}
		printSpiralMap(result.spiralMap)
	}

	main(x: 6, y: 6)
	/*
			OutPut
	 0   1   2   3   4   5 
	19  20  21  22  23   6 
	18  31  32  33  24   7 
	17  30  35  34  25   8 
	16  29  28  27  26   9 
	15  14  13  12  11  10 
	*/


### 문제 출처

* [코딩도장](http://codingdojang.com/scode/266)