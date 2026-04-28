import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(
            width:  proposal.width ?? 0,
            height: rows.last.map { $0.maxY } ?? 0
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(bounds.size), subviews: subviews)
        for row in rows {
            for item in row.items {
                item.view.place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + item.y),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private struct Row {
        var items: [(view: LayoutSubview, x: CGFloat, y: CGFloat, size: CGSize)] = []
        var maxY: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        var x: CGFloat = 0
        var y: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                y += (rows.last?.items.map { $0.size.height }.max() ?? 0) + spacing
                x = 0
                rows.append(Row())
            }
            rows[rows.count - 1].items.append((view, x, y, size))
            rows[rows.count - 1].maxY = y + size.height
            x += size.width + spacing
        }
        return rows
    }
}
