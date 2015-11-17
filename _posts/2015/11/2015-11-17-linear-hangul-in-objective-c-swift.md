---
layout: post
title: "[Objective-C][Swift]한글 풀어쓰기"
description: ""
category: "Mac/iOS"
tags: [한글, swift, objc]
---
{% include JB/setup %}

한글 검색이 필요하여 한글 초성, 중성, 종성을 분리하도록 코드를 Objective-C 코드를 모던하게 수정하였고, Swift 코드로 변환하였습니다.

#### Objective-C

	@interface NSString (Hangul)

	- (NSString *)linearHangul;

	@end

	@implementation NSString (Hangul)

	- (NSString *)linearHangul {
		NSArray<NSArray<NSString *> *> *hangul = @[@[@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ"],
												   @[@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@"ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ"],
												   @[@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ"]];
		NSString *result = @"";
		for (NSInteger i = 0;i < self.length; i++) {
			NSInteger code = [self characterAtIndex:i] - 44032;
			if (code > -1 && code < 11172) {
				NSInteger choIdx = code / 21 / 28;
				NSInteger jungIdx = code % (21 * 28) / 28;
				NSInteger jongIdx = code % 28;
				result = [NSString stringWithFormat:@"%@%@%@%@", result, hangul[0][choIdx], hangul[1][jungIdx], hangul[2][jongIdx]];
			}
			else {
				result = [result stringByAppendingString:[NSString stringWithFormat:@"%C", [self characterAtIndex:i]]];
			}
		}
		return result;
	}

	@end

	// Using
	[@"한글ABC" linearHangul];	// ㅎㅏㄴㄱㅡㄹABC
	@"한글ABC".linearHangul;		// ㅎㅏㄴㄱㅡㄹABC

#### Swift

	extension String {
	    var hangul: String {
	        get {
	            let hangle = [
	                ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"],
	                ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"],
	                ["","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
	            ]

	            return characters.reduce("") { result, char in
	                if case let code = Int(String(char).unicodeScalars.reduce(0){$0.0 + $0.1.value}) - 44032
	                    where code > -1 && code < 11172 {
	                        let cho = code / 21 / 28, jung = code % (21 * 28) / 28, jong = code % 28;
	                        return result + hangle[0][cho] + hangle[1][jung] + hangle[2][jong]
	                }
	                return result + String(char)
	            }
	        }
	    }
	}

	// Test
	assert("ㅎㅏㄴㄱㅡㄹABㅅㅔㅈㅗㅇ" == "한글AB세종".hangul)
	assert("ABCDㅎㅏㄴㄱㅡㄹAD" == "ABCD한글AD".hangul)

### 참고 자료

* [Objective-C 한글 초성, 중성, 종성 분리](http://zetawiki.com/wiki/Objective-C_한글_초성,_중성,_종성_분리)

### 라이선스

* [CC BY-SA 2.0 KR](http://creativecommons.org/licenses/by-sa/2.0/kr/)

<br/>