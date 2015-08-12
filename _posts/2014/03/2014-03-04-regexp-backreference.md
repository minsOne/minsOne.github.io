---
layout: post
title: "[Regex]역참조 사용하기"
description: ""
category: "Regex"
tags: [regex, 정규식, 정규표현식, 역참조, backreference]
---
{% include JB/setup %}

## 역참조 사용하기

한 문장이 있고 이 문장에 반복해 나오는 문자, 바로 실수로 같은 단어를 두번 입력한 오자를 반드시 찾고 싶다고 가정할 때 두 단어가 일치하는지 알려면 먼저 나온 단어를 찾아야 합니다. 역참조는 정규 표현식 패턴으로 앞서 일치한 부분을 다시 가르킵니다.

예문)

	This is a block of of text,
	several words here are are
    repeated, and and they
    should not be.

정규 표현식)

	[ ]+(\w+)[ ]+\1

결과)

	of of
    are are
    and and

\1은 패턴에서 처음 사용한 하위 표현식과 일치한다는 뜻입니다. \2는 두 번째, \3은 세 번째 사용한 하위 표현식과 일치하는 식입니다.

<div class="alert warning"><strong>주의</strong> : 역참조는 참조하는 표현식이 하위표현식일 때 동작합니다.</div>

다음 위의 역참조를 사용하여 시작과 끝이 일치하는 태그를 찾습니다.

예문)

	<BODY>
	<H1>Welcome to my homepage</H1>
	Content is divided into four sections:<BR>
	<H2>ColdFusion</H2>
    Information about Macromedia ColdFusion.
    <H2>Wireless</H2>
    <Information about Bluetooth, 802.11, and more.
    <H2>This is not valid HTML</H3>
	</BODY>

정규 표현식)

	<([hH][1-6])>.*?</\1>

결과)

	<H1>Welcome to my homepage</H1>
    <H2>ColdFusion</H2>
    <H2>Wireless</H2>

앞의 태그를 하위 표현식으로 묶어 역참조를 사용하도록 하였습니다.

### 치환 작업

치환 작업을 할 때는 정규 표현식이 두 개 필요합니다. 하나는 원하는 부분을 일치시키는 패턴, 다른 하나는 일치한 부분을 치환하는데 사용할 패턴입니다. 

아래는 치환 작업을 수행하는 예제입니다.

예문)

	Hello, ben@forta.com is my email address.

정규 표현식)

	(\w+[\w\.]*@[\w\.]+\.\w+)

치환)

	<A HREF="mailto:$1">$1</A>

결과)

	Hello, <A HREF="mailto:ben@forta.com">ben@forta.com</A> is my email address.

$1은 역참조에서 얻은 결과값이며 치환하는데 사용할 수 있습니다.

<div class="alert warning"><strong>주의</strong> : 정규 표현식 구현에 따라 역참조를 표시하는 방법을 바꿔야 합니다.</div>

예제를 하나 더 참고합니다.

예문)

	313-555-1234
    248-555-9999
    810-555-9000

정규 표현식)

	(\d{3})(-)(\d{3})(-)(\d{4})

치환)

	($1) $3-$5

결과)

	(313) 555-1234
    (248) 555-9999
    (810) 555-9000