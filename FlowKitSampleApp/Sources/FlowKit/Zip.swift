func zip<V1, V2>(_ a1: FlowPromise<V1>, _ a2: FlowPromise<V2>) -> FlowPromise<(V1, V2)> {
    return FlowPromise<(V1, V2)> { completion in
        var r1: V1?
        var r2: V2?

        let zip = {
            if let v1 = r1, let v2 = r2 {
                completion((v1, v2))
            }
        }

        a1.complete { r1 = $0; zip() }
        a2.complete { r2 = $0; zip() }
    }
}
