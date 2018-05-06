---
layout: post
title: "[번역]Keychain Services Programming Guide"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

이 글은 애플 **Keychain Services Programming Guide**를 비공식 번역 글입니다. 해당 글의 원문은 [여기](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html)에서 보실 수 있습니다.

---

# 키체인 서비스 소개

키체인 서비스는 한명 이상의 사용자를 위해 비밀번호, 키, 인증서 및 메모를 안전하게 저장합니다. 유저는 단일 암호로 키체인을 잠금 해제 할 수 있고, 어떠한 키체인 서비스 인식 어플리케이션도 해당 키체인을 사용하여 암호를 저장하고 검색할 수 있습니다. 이 가이드에는 키체인 서비스 개요가 포함되어 있고, 개발자들이 가장 흔하게 사용하는 기능과 데이터 구조를 설명하며, 어플리케이션에서 키체인 서비스를 사용하는 예제 방법을 제공합니다.

## 요약

이 문서는 치케인을 사용하여 암호를 저장하고 검색하는 것에 중점을 둡니다. 여러분의 어플리케이션에서 다음을 위해 비밀번호를 다뤄야한다면 이 문서를 읽으세요:

* 여러 유저 - 예를 들면, 많은 유저가 인증해야 하는 이메일 또는 스케줄링 서버
* 여러 서버 - 예를 들면, 하나 이상의 보안 데이터베이스 서버에 정보를 교환해야하는 은행이나 보험 어플리케이션
* 암호를 입력해야 하는 유저 - 예를 들면, 키체인을 사용하여 유저에게 필요한 여러 보안 웹사이트 비밀번호를 저장할 수 있는 웹 브라우저

이 문서를 사용하기 위해 특별한 인증 체계의 지식은 필요없지만, 암호 사용과 저장과 관련한 모범사례를 숙지하세요.

### 키체인 및 키체인 서비스 API 이해

키체인은 앱과 보안 서비스를 대신하여 데이터의 작은 묶음으로 안전하게 저장하는 암호화된 컨테이너입니다. 키체인 서비스 API를 사용하여 키체인에 접근합니다.

* 관련 챕터 : Keychain Services Concepts, Glossary

### Managing Keychain Items and Keychains

Using the Keychain Services API, you can search for keychain items and read their attributes. You can also add items to a keychain or modify existing items. On macOS, you additionally have the ability to create or delete entire keychains, manage trusted applications, and perform other keychain operations using the API.

### 키체인 아이템과 키체인 관리

키체인 서비스 API 사용, 키체인 아이템을 검색할 수 있고, 키체인 아이템 속성을 읽을 수 있습니다. 또한 키체인에 아이템을 추가하거나 기존 아이템을 수정할 수 있습니다. macOS에서는 전치 키체인 생성과 삭제할 수 있고 신뢰할 수 있는 어플리케이션을 관리하고 API를 사용하여 다른 키체인 작업을 수행할 수 있습니다.

* 관련 챕터 : iOS Keychain Services Tasks, macOS Keychain Services Tasks

### See Also 참고 사항

Keychain Services Reference documents all the functions and structures provided in the Keychain Services API. These include the functions and structures used in this document, plus others used primarily by keychain administrative applications such as the Keychain Access app.

Keychain Services Reference 문서는 키체인 서비스 API에서 제공되는 모든 기능과 구조를 문서화합니다. 여기에는 이 문서에서 사용된 기능과 구조 외에도, Keychain Access 앱과 같은 키체인 관리 어플리케이션에서 사용되는 것들이 주로 포함됩니다.

For more information about storing and retrieving certificates and keys, see Certificate, Key, and Trust Services Reference.

인증서와 키 저장 및 검색에 대한 정보는 [Certificate, Key, and Trust Services Reference](https://developer.apple.com/documentation/security/certificate_key_and_trust_services) 를 보세요.

For a broader discussion of security in software development, read Security Overview and Secure Coding Guide.

소프트웨어 개발 보안에 대한 더 자세한 설명은 [Security Overview](https://developer.apple.com/library/content/documentation/Security/Conceptual/Security_Overview/Introduction/Introduction.html#//apple_ref/doc/uid/TP30000976) and [Secure Coding Guide.](https://developer.apple.com/library/content/documentation/Security/Conceptual/SecureCodingGuide/Introduction.html#//apple_ref/doc/uid/TP40002415)를 보세요.