---
layout: post
title: "[Swift5][RIBs] Uber의 RIBs 프로젝트에서 얻은 경험 (2) - 강제성"
description: ""
category: "programming"
tags: [iOS, Swift, Uber, RIBs]
---
{% include JB/setup %}

처음에 어플리케이션 만들 때는 그냥 만들어도 됩니다. 하지만 서비스 규모가 커지고, 다수의 개발자들과 같이 개발하다보면 체계적인 규칙이 필요해지고 필요한 구조를 선택하게 됩니다. 

MVC, MVVM, MVVM, ReactorKit 같은 구조들이 있지만 이와 같은 구조들은 화면에만 초점이 맞춰져 있습니다. 하지만 이런 구조들은 다수의 개발자와 같이 작업시 강제성이 없기 때문에 사람마다 다르게 작업을 하게 됩니다. 그러다보면 각각의 기능을 개발 후, 조합하기가 쉽지 않습니다.

하지만 RIBs는 개발시 강제성을 만듭니다. RIB 중 B에 해당하는 Builder가 그 역할을 하게 됩니다. 

## Dependency, Component

RIB에서 필요한 데이터를 정의하는 곳입니다. Dependency 프로토콜에 정의된 것들은 Dependency를 따르는 Component가 구현을 하도록 합니다.

```
protocol GameDependency: Dependency {
    /// 플레이어1 이름 데이터 정의
    var player1Name: String { get }
    /// 플레이어2 이름 데이터 정의
    var player2Name: String { get }
}

final class GameComponent: Component<GameDependency> {
    /// Builder에서 Component에 접근하기 위해 fileprivate으로 범위 설정
    fileprivate var player1Name: String {
        return dependency.player1Name
    }

    fileprivate var player2Name: String {
        return dependency.player2Name
    }
}

extension GameComponent: GameDependency {
    var player1Name: String {
        return self.leftPlayerName
    }
    var player2Name: String {
        return self.rightPlayerName
    }
}
```

위의 코드를 한번 살펴봅시다.

GameDependency는 `player1Name`, `player2Name`이 필요로 한다고 정의합니다. 그러면 GameRIB에서의 GameComponent는 GameDependency를 따르므로, `player1Name`, `player2Name`를 구현해야 합니다. 그리고 GameComponent는 GameDependency에서 데이터를 가져와 Init 하는 것이 아니라, GameDependency로 접근하여 `player1Name`, `player2Name`를 접근할 수 있게 합니다.

따라서 Game RIB을 사용할 때 이미 GameComponent에서 GameDependency를 구현하였기 때문에 자연스레 DI 구현하게 되었습니다.

만약 GameDependency에서 `player3Name`이 추가로 정의한다면, 컴파일러는 `player3Name`가 구현되어 있지 않은 곳에 에러를 표시할 것입니다. 그러면 우리는 에러가 표시된 곳을 찾아 구현하면 됩니다. 따라서 컴파일러에 의존하여 개발하기 때문에 실수할 여지가 없습니다.


## Builder

RIB은 Builder로부터 시작한다라고 볼 수 있습니다. Builder는 각 구성 요소 클래스와 자식 RIB의 Builder를 만드는 로직을 가지며, 세부 구현에 영향을 미치지 않습니다. 자식 RIB의 Builder는 Router에서 가지고 있으며 Router에서 자식 Builder에 build 함수를 통해 자식 Router를 만들어 attach를 하게 됩니다.

```
protocol GameBuildable: Buildable {
    /// build 함수로부터 Router를 얻어, 부모 RIB이 attach를 할 수 있도록 함.
    func build(withListener listener: GameListener) -> GameRouting
}

final class GameBuilder: Builder<GameDependency>, GameBuildable {
    override init(dependency: GameDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: GameListener) -> GameRouting {
        let component = GameComponent(dependency: dependency)

        /// player1Name, player2Name, scoreStream는 component를 접근하여 데이터를 가져오며, 이는 직접 값을 접근하지 않도록 하기 위함.

        let viewController = GameViewController(player1Name: component.player1Name,
                                                player2Name: component.player2Name)

        let interactor = GameInteractor(presenter: viewController,
                                        scoreStream: component.scoreStream)
        interactor.listener = listener
        return GameRouter(interactor: interactor, viewController: viewController)
    }
}
```

## Router

Router는 Buildable을 선택해서 자식 RIB을 만들어 Attach를 하거나 ViewController에게 자식 router에서 나온 ViewController를 Push하거나 Present하는 역할을 합니다. 그리고 자식 router의 ViewController를 dismiss하거나 pop을 하는 역할도 수행합니다.

```
protocol GameInteractable: Interactable, OffGameListener, TicTacToeListener {
    var router: GameRouting? { get set }
    var listener: GameListener? { get set }
}

protocol GameViewControllable: ViewControllable {
    /// ViewController에 구현될 함수를 정의하며, Router에서 present, dismiss, push, pop 정도의 행위만 하도록 정의함.
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class GameRouter: Router<GameInteractable>, GameRouting {
    /// Buildable을 인자로 받아 자식 RIB을 build하여 만들고, 현재 router에 attach하도록 함.
    init(interactor: GameInteractable,
         viewController: GameViewControllable,
         offGameBuilder: OffGameBuildable,
         ticTacToeBuilder: TicTacToeBuildable) {
        self.viewController = viewController
        self.offGameBuilder = offGameBuilder
        self.ticTacToeBuilder = ticTacToeBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
        attachOffGame()
    }

    // MARK: - GameRouting

    func cleanupViews() {
        if let currentChild = currentChild {
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }

    func routeToTicTacToe() {
        detachCurrentChild()

        let ticTacToe = ticTacToeBuilder.build(withListener: interactor)
        currentChild = ticTacToe
        attachChild(ticTacToe)
        viewController.present(viewController: ticTacToe.viewControllable)
    }

    func routeToOffGame() {
        detachCurrentChild()
        attachOffGame()
    }

    // MARK: - Private

    private let viewController: GameViewControllable
    private let offGameBuilder: OffGameBuildable
    private let ticTacToeBuilder: TicTacToeBuildable

    private var currentChild: ViewableRouting?

    private func attachOffGame() {
        let offGame = offGameBuilder.build(withListener: interactor)
        self.currentChild = offGame
        attachChild(offGame)
        viewController.present(viewController: offGame.viewControllable)
    }

    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }
}
```

## Interactor

Interactor는 비지니스 로직을 담당하며, Present에서 입력한 데이터가 들어왔을 때 적절한 상태로 변경하라고 다시 Present에게 전달하거나, Router에 전달하여 자식 RIB을 만들거나 또는 Listener에게 상태를 전달할 수도 있습니다.

```
protocol GameRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol GamePresentable: Presentable {
    var listener: GamePresentableListener? { get set }

    /// ViewController에 어떤 행위를 할지 정의함.
    func setCell(atRow row: Int, col: Int, withPlayerType playerType: PlayerType)
    func announce(winner: PlayerType?, withCompletionHandler handler: @escaping () -> ())
}

protocol GameListener: class {
    /// 부모 RIB에 해당 행위를 호출한다고 정의함.
    func gameDidEnd(withWinner winner: PlayerType?)
}

final class GameInteractor: PresentableInteractor<GamePresentable>, GameInteractable, GamePresentableListener {

    weak var router: GameRouting?

    weak var listener: GameListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: GamePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    /// ViewController와 상관없이 Interactor가 RIB이 부모 RIB에 Attach되면서 Active가 되는데, 그때 수행할 것을 정의함.
    override func didBecomeActive() {
        super.didBecomeActive()

        initBoard()
    }

    /// 해당 RIB이 Detach되면서 Detactive될때 어떤 행동을 수행할 지 정의함.
    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: - GamePresentableListener

    func placeCurrentPlayerMark(atRow row: Int, col: Int) {
        guard board[row][col] == nil else {
            return
        }

        let currentPlayer = getAndFlipCurrentPlayer()
        board[row][col] = currentPlayer
        presenter.setCell(atRow: row, col: col, withPlayerType: currentPlayer)

        if let winner = checkWinner() {
            presenter.announce(winner: winner) {
                self.listener?.gameDidEnd(withWinner: winner)
            }
        }
    }

    // MARK: - Private

    private var currentPlayer = PlayerType.player1
    private var board = [[PlayerType?]]()

    private func initBoard() {
        for _ in 0..<GameConstants.rowCount {
            board.append([nil, nil, nil])
        }
    }

    private func getAndFlipCurrentPlayer() -> PlayerType {
        let currentPlayer = self.currentPlayer
        self.currentPlayer = currentPlayer == .player1 ? .player2 : .player1
        return currentPlayer
    }

    private func checkWinner() -> PlayerType? {
        // Rows.
        for row in 0..<GameConstants.rowCount {
            guard let assumedWinner = board[row][0] else {
                continue
            }
            var winner: PlayerType? = assumedWinner
            for col in 1..<GameConstants.colCount {
                if assumedWinner.rawValue != board[row][col]?.rawValue {
                    winner = nil
                    break
                }
            }
            if let winner = winner {
                return winner
            }
        }

        // Cols.
        for col in 0..<GameConstants.colCount {
            guard let assumedWinner = board[0][col] else {
                continue
            }
            var winner: PlayerType? = assumedWinner
            for row in 1..<GameConstants.rowCount {
                if assumedWinner.rawValue != board[row][col]?.rawValue {
                    winner = nil
                    break
                }
            }
            if let winner = winner {
                return winner
            }
        }

        // Diagnals.
        guard let p11 = board[1][1] else {
            return nil
        }
        if let p00 = board[0][0], let p22 = board[2][2] {
            if p00.rawValue == p11.rawValue && p11.rawValue == p22.rawValue {
                return p11
            }
        }

        if let p02 = board[0][2], let p20 = board[2][0] {
            if p02.rawValue == p11.rawValue && p11.rawValue == p20.rawValue {
                return p11
            }
        }

        return nil
    }
}

struct GameConstants {
    static let rowCount = 3
    static let colCount = 3
}
```

## 정리

* Builder : Builder에서 RIB이 시작을 하며, 필요한 데이터를 정의를 합니다. 그리고 Builder의 build 함수로부터 router를 얻을 수 있습니다.
* Router : Router에서 자식 RIB을 Attach하거나, Detach를 하는 역할을 수행하며, 트리 구조를 그리게 됩니다.
* Interactor : 비즈니스 로직을 담당하며, 어떻게 행동할지 구현되어 있습니다.