---
layout: post
title: "[iOS][fastlane]Pem과 SSL Certificate Check를 통해 Push 인증서 관리하기"
description: ""
category: "Mac/iOS"
tags: [ios, fastlane, pem, ssl-cert-check, ssl, push, certificate, p12, openssl]
---
{% include JB/setup %}

### Pem과 SSL Certificate Check를 이용하여 Push 인증서 관리하기

Push 인증서는 만든 후 394일 동안 유효합니다. 하지만 서비스를 운영하다 까먹고 유효 기간이 지나 인증서가 만료되기도 합니다. <del>그 전에 서비스가 안 망하면 다행..</del>

그렇기 때문에 매일 인증서가 유효한지 확인해야하는데 이를 [SSL Certificate Check](http://prefetch.net/code/ssl-cert-check)를 통해서 유효한지, 며칠 남아서 만료되고 있는지, 만료되었는지를 알 수 있습니다.

SSL Certificate Check를 내려받아 실행권한을 주고 pem 파일의 남은 기간을 확인할 수 있습니다. 참고로 SSL Certificate Check는 bash 4.0 이상을 지원합니다. 맥이라면 `brew install bash` 실행하여 업데이트합니다.

	$ curl -o ssl-cert-check http://prefetch.net/code/ssl-cert-check
	$ chmod +x ssl-cert-check
	$ ./ssl-cert-check -c app_test.pem -x 200 #만료일 기준 200일

	Host                                            Status       Expires      Days
	----------------------------------------------- ------------ ------------ ----
	FILE:app_test.pem                               Expiring     Jul 15 2016  189

<br/>만약 만료날짜가 얼마남지 않았다면 [Pem](https://github.com/fastlane/pem)을 통해서 인증서를 만들어 갱신합니다.

	$ FASTLANE_PASSWORD=[password] pem -a [bundleId] -u [username] -o app_test.pem
	$ ./ssl-cert-check -c app_test.pem

	Host                                            Status       Expires      Days
	----------------------------------------------- ------------ ------------ ----
	FILE:app_test.pem                               Valid        Feb 5 2017   394

위 스크립트를 crontab으로 매일 만료되고 있는 인증서를 놓치지 않고 갱신할 수 있습니다.

그리고 애플 개발자 센터에서 다음과 같이 인증서가 만들어진 것을 확인할 수 있습니다.

<br/><img src="https://farm2.staticflickr.com/1600/23606687693_4fb96da155_z.jpg" width="640" height="389" alt=""><br/><br/>

또한, bag attribute가 필요하다면 pem으로 내려받을 때 `-p` 옵션을 사용하여 받아 `p12` 파일을 openssl로 `pem` 파일을 만들면 됩니다.

	$ FASTLANE_PASSWORD=[password] pem -a [bundleId] -u [username] -o app_test.pem -p "qwer1234"
	$ openssl pkcs12 -info -in app_test.p12 -passin pass:qwer1234 -out app_test.pem
	$ cat app_test.pem

	Bag Attributes
    	friendlyName: production
    	localKeyID: FA CB 95 61 59 31 *************
	subject=/UID=[bundleId]/CN=Apple Push Services: [bundleId]/OU=******/O=******/C=US
	issuer=/C=US/O=Apple Inc./OU=Apple Worldwide Developer Relations/CN=Apple Worldwide Developer Relations Certification Authority
	-----BEGIN CERTIFICATE-----
	MIIGSjCCBTKgAwIBAgIIS****
	...

만료되고 있는 인증서는 pem이 revoke를 하지 않고 새로운 인증서를 만드는데 최대 2개까지 만들게 됩니다. 하지만 우리가 사용하는 인증서는 갱신되었기 때문에 만료되고 있는 인증서는 개발자 센터에서 revoke를 할 필요 없이 만료되면 알아서 삭제됩니다.(아마도?)

지금까지 Push 인증서를 수동으로 갱신하고 있었다면 이번 기회에 SSL Certificate Check와 Pem을 이용하여 자동으로 갱신하도록 만들어보세요.
<br/><br/>
