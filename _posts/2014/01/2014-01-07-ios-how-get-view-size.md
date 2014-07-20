---
layout: post
title: "[iOS]왜 landscape로 전환하면 viewDidLoad에서는 회전한 가로 및 세로의 값이 portrait 값으로 주는가?"
description: ""
category: "Mac/iOS"
tags: [viewDidLoad, viewDidAppear, view]
---
{% include JB/setup %}

### 뷰 이벤트

#### viewDidLoad

컨트롤러 뷰가 메모리에 적재된 후에 호출됩니다.

#### viewWillAppear

뷰가 뷰 계층 구조에 추가되기 직전에 뷰 컨트롤러에게 알려줍니다.

#### viewDidAppear

뷰가 뷰 계층 구조에 추가되고 뷰 컨트롤러에게 알려줍니다.

#### viewWillDisappear

뷰가 뷰 계층 구조에서 제거되기 직전에 뷰 컨트롤러에게 알려줍니다.

#### viewDidDisappear

뷰가 뷰 계층 구조에서 제거되고 뷰 컨트롤러에게 알려줍니다.


### 왜 viewDidLoad에서는 landscape일 경우 정상적인 값을 안주는 가?

viewDidLoad는 화면이 회전하기 전에 이벤트가 발생합니다. 따라서 항상 초기값은 `portrait mode`로 되어 있어 viewDidLoad에서 화면의 크기를 구하려고 한다면 항상 `portrait` 크기를 얻게 됩니다.

두가지 방법을 사용할 수 있습니다. 첫번째는 `viewDidAppear`을 호출하여 거기에서 값을 얻는 방법입니다. 이는 뷰가 뷰 계층 구조에 추가가 되고 난 후이므로 화면 회전이 일어난 후 이므로 `landscape` 화면 크기를 얻을 수 있습니다.

두번째 방법은 `가로와 세로를 변경`하여 사용하는 방법입니다. 이는 화면이 생성되기 전이므로 `landscape`로 되는 것을 예상하고 가로와 세로의 크기를 변경 사용하도록 합니다.
