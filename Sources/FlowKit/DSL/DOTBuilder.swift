public final class DOTBuilder {
    public enum RankDir: String {
        case LR
        case TB
    }

    public enum NodeShape: String {
        case box
        case ellipse
    }

    public var strict = true
    public var rankDir = RankDir.LR
    public var nodeShape = NodeShape.box

    private var edges: [(from: String, to: String, label: String?)] = []

    public init() { }

    public func dsl<Step, Event, StepResult, State>(_ flowDSL: FlowDSL<Step, Event, StepResult, State>) {
        let graph = Graph()

        // build graph and process fowrads/backs
        for step in flowDSL.definition.steps {
            for condition in step.conditions {
                switch condition.transition {
                case .forwardTo(let destination),
                        .backTo(let destination):

                    graph
                        .node(name: "\(step.step)")
                        .add(child: graph.node(name: "\(destination)"))

                    edges.append((from: "\(step.step)",
                                  to: "\(destination)",
                                  label: condition.event.map { "\($0)" } ))
                default:
                    continue
                }
            }
        }

        // process backs to previous step
        for step in flowDSL.definition.steps {
            for condition in step.conditions {
                guard case .back = condition.transition else { continue }

                for destination in graph.node(name: "\(step.step)").parents {
                    guard let destination = destination.node?.name else { continue }

                    edges.append((from: "\(step.step)",
                                  to: "\(destination)",
                                  label: condition.event.map { "\($0)" } ))
                }
            }
        }
    }

    public func build() -> String {
        var lines: [String] = []

        if strict {
            lines.append("strict digraph {")
        } else {
            lines.append("digrap {")
        }

        lines.append("\trankdir=\(rankDir)")
        lines.append("\tnode [shape=\(nodeShape)]")
        lines.append("")

        for edge in edges {
            if let label = edge.label {
                lines.append("\t\(edge.from) -> \(edge.to) [label=\"\(label)\"]")
            } else {
                lines.append("\t\(edge.from) -> \(edge.to)")
            }
        }

        lines.append("}")

        return lines.joined(separator: "\n")
    }
}

private final class Graph {
    private var nodes = Set<GraphNode>()

    func node(name: String) -> GraphNode {
        let node = GraphNode(name: name)
        return nodes.insert(node).memberAfterInsert
    }
}

private final class GraphNode {
    struct WeakNode: Hashable {
        weak var node: GraphNode?
    }

    private(set) var children = Set<GraphNode>()
    private(set) var parents = Set<WeakNode>()

    let name: String

    init(name: String) {
        self.name = name
    }

    func add(child: GraphNode) {
        child.parents.insert(WeakNode(node: self))
        children.insert(child)
    }
}

extension GraphNode: Hashable {
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }

    static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        return lhs.name == rhs.name
    }
}
