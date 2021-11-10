public struct Promise<Output> {
    public typealias Completion = (Output) -> Void

    private let work: (@escaping Completion) -> Void

    public static var nothing: Self {
        return Self { _ in }
    }

    init(work: @escaping (@escaping Completion) -> Void) {
        self.work = work
    }

    public static func promise(_ value: Output) -> Self {
        return Self { $0(value) }
    }

    public static func promise(_ work: @escaping (@escaping (Output) -> Void) -> Void) -> Self {
        return Self { completion in work { completion($0) } }
    }

    public func then<NewOutput>(_ builder: @escaping (Output) -> Promise<NewOutput>) -> Promise<NewOutput> {
        return Promise<NewOutput> { completion in
            complete { builder($0).complete(using: completion) }
        }
    }

    public func map<NewOutput>(_ builder: @escaping (Output) -> NewOutput) -> Promise<NewOutput> {
        return Promise<NewOutput> { completion in
            complete { completion(builder($0)) }
        }
    }

    public func complete(using completion: @escaping Completion) {
        work { completion($0) }
    }

    public func complete() {
        complete { _ in }
    }
}
