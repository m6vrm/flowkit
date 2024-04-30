This library allows you to describe flow coordinators
(https://khanlou.com/2015/01/the-coordinator/) as finite-state machines
(https://en.wikipedia.org/wiki/Finite-state_machine).

Features
========

*   Separation of responsibilities: navigation implementation, navigation logic
    and state transformation are described and can be tested independently
    of each other
*   No shared state
*   Declarativity, DSL out of the box, generation of flow graph description
    in the DOT language
    (https://en.wikipedia.org/wiki/DOT_(graph_description_language))
*   Server-driven flow ready

Concept
=======

                ┌────────────────────────────────────────┐
                │                                        │
             ┌──▼──┐                                     │
             │start◄──────────────────────┐              │
             └──┬──┘                      │              │
                │                         │              │
       initial State & Step               │              │
                │                         │              │
      ┌─────────▼─────────┐               │              │
      │TransitionNavigator│               │              │
      └─────────┬─────────┘               │              │
                │                         │              │
        StepResult & State    next Step & reduced State  │
                │                         │              │
          ┌─────▼──────┐         ┌────────┴─────────┐    │
          │StateReducer│         │TransitionProvider│    │
          └─────┬──────┘         └────────▲─────────┘    │
                │                         │              │
    StepResult & reduced State           no    initial State & Step
                │                         │              │
            ┌───▼───┐                  ┌──┴───┐          │
            │should │                  │should│          │
            │finish?├──no──────────────►retry?├──yes─────┘
            └───┬───┘                  └──────┘
                │
               yes
                │
         ┌──────▼──────┐
         │complete with│
         │ flow result │
         └─────────────┘

The main idea is a vertical separation of responsibilities of the flow:

*   Navigation implementation (TransitionNavigator) – changing the tree
    of screens
*   Navigation logic (TransitionProvider) – determining which screen to go next
*   State transformation (StateReducer) – transformation of data as the flow
    progresses and determining when there is enough data to complete the flow

These components are asynchronous and operate with entities such as Step,
StepResult, State.

Step
----

Flow steps. In fact, these are screens or some kind of navigation actions.
According to the Step the TransitionNavigator makes transition to the screen.

StepResult
----------

The results of the flow steps. Either the data that came from the previous
screen, or some kind of flag indicating a completion of the step.

Based on the result of the step, the StateReducer creates a new state, and
the TransitionProvider determines which transition to make next.

State
-----

The state of the flow collected from the results of the previous steps.
I.e., this is the data collected as the flow progresses, and used either
in the flow itself, or returned at its completion.

Unlike the step and the result of the step, the state is passed to all the main
components of the flow: TransitionNavigator, StateReducer, TransitionProvider.
All of them can use the state for their logic to work correctly, but only
the StateReducer can change the state.

Usage
=====

Add a dependency:

    .package(url: "https://m6v.ru/git/flowkit", .upToNextMinor(from: "0.2.0"))

NOTE: Until 1.0.0 minor versions may be breaking.

Determine the flow steps, the results of the steps and the possible states:

    enum MyFlowStep {
        case amount
        case invalidAmount
        case tariffs
    }

    enum MyFlowStepResult {
        case amount(Int)
        case tariffs(Tariff)
        case confirmation(ConfirmationResult)
    }

    enum MyFlowState {
        case country(Country)
        case amount(Int, country: Country)
        case tariff(Tariff, amount: Int, country: Country)
    }

Implement TransitionNavigator, StateReducer and TransitionProvider:

    final class MyFlowTransitionNavigator: TransitionNavigator { ... }
    final class MyFlowStateReducer: StateReducer { ... }
    final class MyFlowTransitionProvider: TransitionProvider { ... }

Create and start the flow:

    final class MyFlow {
        private lazy var transitionNavigator = MyFlowTransitionNavigator(...)
        private lazy var stateReducer = MyFlowStateReducer(...)
        private lazy var transitionProvider = MyFlowTransitionProvider(...)

        private lazy var flow = Flow(transitionNavigator: transitionNavigator,
                                     stateReducer: stateReducer,
                                     transitionProvider: transitionProvider)

        func start(with country: Country) -> Promise<Transfer> {
            return flow.start(from: .amount, with: .country(country))
        }
    }

Example of flow implementation: Sources/FlowKitExampleTransferFlowFeature/Flow

DSL
===

Instead of implementing the TransitionProvider, you can use the existing
DeclarativeTransitionProvider, which allows you to describe flow using DSL:

    let dsl = FlowDSL {
        emit(using: emitter)
        step {
            on(.error) { forward(to: .alert) }
        }
        step(.amount) {
            on(.invalidAmount) { forward(to: .invalidAmount) }
            next { forward(to: .tariffs) }
        }
        step(.tariffs) {
            next { forward(to: .confirmation) }
        }
        step(.confirmation) {
            on(.confirmationContinue) { forward(to: .success) }
            on(.confirmationEditAmount) { back(to: .amount) }
            on(.confirmationEditTariff) { back(to: .tariffs) }
        }
        step(.success) {
            next { forward(to: .finish) }
        }
    }

    let transitionProvider = DeclarativeTransitionProvider(flowDSL: dsl)

Usage
-----

Create a DSL builder that implements the FlowDSLBuilder protocol:

    final class MyFlowDSLBuilder: FlowDSLBuilder { ... }

To describe the state change reaction, the type defining possible events (Event)
and the emitter function of these events are used.

Define the Event type inside the builder:

    final class MyFlowDSLBuilder: FlowDSLBuilder {
        enum Event {
            case invalidAmount
            case confirmationContinue
            case confirmationEditAmount
            case confirmationEditTariff
        }
    }

Define the event emitter:

    static func emitter(_ stepResult: MyFlowStepResult,
                        _ state: MyFlowState) -> Event? {

        switch stepResult {
        case .amount(let amount) where amount < 100:
            return .invalidAmount
        case .confirmation(.continue, _):
            return .confirmationContinue
        default:
            return nil
        }
    }

Describe the flow using this emitter:

    let dsl = FlowDSL {
        emit(using: emitter)
        step(.amount) {
            on(.invalidAmount) { forward(to: .invalidAmount) }
            next { forward(to: .tariffs) }
        }
    }

Complete example where FlowDSLBuilder is implemented:
Sources/FlowKitExampleTransferFlowFeature/Flow/TransferFlowTransitionProvider.swift

Declarations
------------

*   step(Step) { ... } – event handling for a specific step
*   step { ... } – event handling for *any* step
*   on(Event) { ... } – handle specific event
*   next { ... } – handle when no events were emitted

Graphviz
--------

The DOTBuilder allows you to convert DSL to the DOT graph description language
(https://en.wikipedia.org/wiki/DOT_(graph_description_language)):

    let dot = DOTBuilder()
    let dsl = FlowDSL { ... }

    dot.dsl(dsl)

    print(dot.build())

Result for the example flow:

    strict digraph {
        rankdir=LR
        node [shape=box]

        "*" -> alert [label="on error"]
        amount -> invalidAmount [label="on invalidAmount"]
        amount -> tariffs
        tariffs -> confirmation
        confirmation -> success [label="on confirmationContinue"]
        confirmation -> amount [label="on confirmationEditAmount"]
        confirmation -> tariffs [label="on confirmationEditTariff"]
        success -> finish
    }

See assets/graph.png for visualization.
