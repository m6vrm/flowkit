# FlowKit

Библиотека, позволяющая описывать [координаторы флоу](https://khanlou.com/2015/01/the-coordinator/) как [FSM](https://en.wikipedia.org/wiki/Finite-state_machine).

Особенности:

- Разделение ответственностей: реализация навигации, логика навигации и преобразование состояния описываются и могут быть протестированы независимо друг от друга.
- Отсутствие шареного состояния.
- Возможность стартовать флоу с любого экрана.
- Декларативность, DSL из коробки, генерация [описания графа флоу на языке DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) и вот это все :3
- Server-driven flow ready.

## Содержание

- [Концепция](#концепция)
  - [Step](#step)
  - [StepResult](#stepresult)
  - [State](#state)
- [Использование](#использование)
- [DSL](#dsl)

## Концепция

<p align="center">
    <img src="assets/flow.png">
</p>

Основная идея в вертикальном разделении ответственностей флоу:

- Реализация навигации (`TransitionNavigator`) – изменение дерева экранов.
- Логика навигации (`TransitionProvider`) – определение, на какой экран переходить дальше.
- Преобразование состояния (`StateReducer`) – трансформация данных по мере прохождение флоу и определение, когда данных достаточно для завершения флоу.

Эти компоненты асинхронны и оперируют следующими сущностями: `Step`, `StepResult`, `State`.

### Step

Шаги флоу. Фактически это экраны либо какие-то действия навигации.

Согласно шагу `TransitionNavigator` совершает переход на нужный экран.

### StepResult

Результаты шагов флоу. Либо данные, пришедшие от предыдущего экрана, либо какой-то флаг, говорящий о завершении шага.

По результату шага `StateReducer` создает новое состояние, а `TransitionProvider` определяет, какой переход совершить далее.

### State

Собранное из результатов предыдущих шагов состояние флоу. Т.е. это данные, собранные по мере прохождения флоу, и используемые либо в самом флоу, либо возвращаемые наружу при его завершении.

В отличие от шага и результата шага, состояние передается во все основные компоненты флоу: `TransitionNavigator`, `StateReducer`, `TransitionProvider`. Все они могут использовать состояние для корректной работы своей логики, но изменять состояние может только `StateReducer`.

## Использование

Определяем шаги флоу, результаты шагов, возможные состояния:

```swift
enum MyFlowStep {
    case amount
    case invalidAmount
    case tariffs
    ...
}

enum MyFlowStepResult {
    case amount(Int)
    case tariffs(Tariff)
    case confirmation(ConfirmationResult)
    ...
}

enum MyFlowState {
    case country(Country)
    case amount(Int, country: Country)
    case tariff(Tariff, amount: Int, country: Country)
    ...
}
```

Реализуем `TransitionNavigator`, `StateReducer` и `TransitionProvider`:

```swift
final class MyFlowTransitionNavigator: TransitionNavigator { ... }

final class MyFlowStateRecuer: StateReducer { ... }

final class MyFlowTransitionProvider: TransitionProvider { ... }
```

Собираем и стартуем флоу:

```swift
final class MyFlow {
    private lazy var transitionNavigator = MyFlowTransitionNavigator(...)
    private lazy var stateReducer = MyFlowStateRecuer(...)
    private lazy var transitionProvider = MyFlowTransitionProvider(...)

    private lazy var flow = Flow(transitionNavigator: transitionNavigator,
                                 stateReducer: stateReducer,
                                 transitionProvider: transitionProvider)

    func start(with country: Country) -> Promise<Transfer> {
        return flow.start(from: .amount, with: .country(country))
    }
}
```

[Пример реализации флоу](Sources/FlowKitExampleTransferFlowFeature/Flow)

## DSL

TBD
