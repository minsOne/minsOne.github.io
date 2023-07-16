---
layout: post
title: "RIBs SwiftUI"
tags: []
published: false
---
{% include JB/setup %}

RIBs에서 View는 옵셔널입니다. 따라서 RIBs에서 View는 UIKit으로 구현하던, SwiftUI로 구현하던 상관없습니다. 

그렇다면, 기존 프로젝트가 UIKit 기반이라면 SwiftUI는 부분적으로 적용할 수 밖에 없습니다. 

만약, SwiftUI는 UIViewController의 View 역할만 담당하게 한다면 SwiftUI, UIKit, RIBs는 공존할 수 있지 않을까요?

SwiftUI의 View는 ObservableObject를 이용하여 구독하여 값을 전달받을 수 있고, 이벤트를 넘겨줄 수 있습니다.

이를 이용하여 View와 Interactor 간의 통신이 가능합니다.

즉, 다음과 같은 구조가 형성됩니다.

// 그림 1

그럼 코드를 작성해봅시다.

```swift
//
//  SampleView.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/16.
//

import Foundation
import SwiftUI
import Combine

struct SampleViewState {
    
}

enum SampleViewAction {
    case tap
    case world
}

protocol SamplePresentableListener: AnyObject {
    var state: AnyPublisher<SampleViewState, Never> { get }
    func request(action: SampleViewAction)
}

class SampleViewModel: ObservableObject {
    private weak var listener: SamplePresentableListener?
    var bag = Set<AnyCancellable>()

    @Published var state: SampleViewState
    
    init(listener: SamplePresentableListener?) {
        self.listener = listener
        self.state = .init()

        listener?.state.sink { [weak self] value in
            self?.state = value
        }.store(in: &bag)
    }
    
    func request(action: SampleViewAction) {
        print(action)
        listener?.request(action: action)
    }
}

struct SampleView: View {
    @ObservedObject var viewModel: SampleViewModel
    
    init(listener: SamplePresentableListener?) {
        self.viewModel = .init(listener: listener)
    }
    
    var body: some View {
        HStack {
            Button("Hello") {
                viewModel.request(action: .tap)
            }
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                Text("Hello").font(.title).border(.gray)
                Spacer().frame(height: 10)
                Text("World").font(.title).border(.gray)
                Spacer()
            }
            .border(Color.blue)
            Spacer()
        }.border(Color.red)
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        SampleView(listener: nil)
    }
}

```