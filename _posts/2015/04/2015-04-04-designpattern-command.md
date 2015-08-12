---
layout: post
title: "[DesignPattern]커맨드 패턴(Command Pattern)"
description: ""
category: "programming"
tags: [designPattern, command, interface, class, inheritance, constructor, abstract, protocol, dependency, protocol]
---
{% include JB/setup %}

## 커맨드 패턴(Command Pattern)

커맨드 패턴은 요청을 객체로 캡슐화하여 명령을 단순화합니다. 요청과 수행에 있어서 분리하여 느슨한 관계를 가집니다.

클라이언트(client)는 커맨드 객체를 생성하며, 인보커(invoker)에 커맨드 객체를 저장합니다. 또한, 커맨드 객체에는 리시버(receiver)에 대한 정보가 있습니다. 커맨드 객체에서 수행하는 메소드는 execute() 뿐이며, 캡슐화하여 리시버에 있는 특정 행동을 처리합니다. 클라이언트는 인보커에게 저장한 커맨드 객체를 수행하도록 요청합니다. 리시버에 있는 특정 행동을 하는 메소드가 호출됩니다.

<br/><img src="/../../../../image/2015/Command_Design_Pattern_Class_Diagram.png" alt="Command_Design_Pattern_Class_Diagram" style="width: 600px;"/><br/><br/>

출처 : [위키피디아][Wikipedia Ko]

다음은 커맨드 패턴으로 사용할 예제 UML입니다.
<br/><img src="/../../../../image/2015/CP_Diagram.png" alt="CommandPattern-UML" style="width: 400px;"/><br/><br/>

Command에서 상속을 받아 LightOffCommand와 LightOnCommand 클래스를 만들며, execute를 통해 Light 객체를 제어합니다. Command 객체는 RemoteControl에서 관리를 하여 동작을 수행하도록 명령을 내립니다.

Command 프로토콜을 만들어 LightOffCommand와 LightOnCommand 클래스가 상속받도록 합니다.

	// Light
	class Light {
		var turnOnOff = false {
			didSet {
				println("Now light is " + (turnOnOff ? "On" : "Off"))
			}
		}
		func on() {
			self.turnOnOff = true
		}
		func off() {
			self.turnOnOff = false
		}
	}

	// Command Protocol
	protocol Command {
		func execute()
	}

	// LightOffCommand and LightOnCommand
	class LightOffCommand: Command {
		var light: Light

		func execute() {
			self.light.off()
		}
	}

<br/>RemoteControl 클래스를 만들어 Command 객체를 관리하고 수행하도록 합니다.

	class RemoteControl {
		var slot: Command?

		func pressedButton() {
			slot?.execute()
		}
	}

<br/> 이제 위의 클래스들을 가지고 Command를 실행할 코드를 작성합니다.

	var remote = RemoteControl()
	let light = Light()
	let onLight = LightOnCommand(light: light)
	let offLight = LightOffCommand(light: light)

	remote.slot = onLight
	remote.pressedButton()
	remote.slot = offLight
	remote.pressedButton()

Light의 turnOnOff 변수에 property observer를 통해 값이 변경되면 출력하도록 하여 값이 변경되었는지 확인할 수 있습니다.

RemoteControl에서 slot가 인보커 역할을 하며, Command 객체를 저장하여 호출할 수 있습니다. 또한, LightOnCommand와 LightOffCommand의 객체에서는 리시버인 Light 객체를 가지고 있습니다. 따라서 Command 객체가 리시버에 명령을 내리도록 합니다.

여러 명령를 수행하도록 커맨드 패턴을 확장하여 사용할 수 있습니다.

	class RemoteControl {
		var slots: [Command] = []
		
		func pressedButton() {
			for slot in slots {
				slot.execute()
			}
		}
	}


## 정리

커맨드 패턴은 [행위 패턴][Behavioral_pattern] 카테고리에 속하며 행동을 캡슐화하여 미리 요청을 가지고 있다가 요청할 때 사용할 수 있도록 합니다. 따라서 요청과 수행의 관계가 느슨하여 SOLID의 DIP(The Dependency Inversion Priciple)를 따릅니다.

## 참고 자료

* Head First Design Pattern
* [Wikipedia En](http://en.wikipedia.org/wiki/Command_pattern)
* [Wikipedia Ko][Wikipedia Ko]

[Behavioral_pattern]: http://en.wikipedia.org/wiki/Behavioral_pattern
[Wikipedia Ko]: http://ko.wikipedia.org/wiki/커맨드_패턴