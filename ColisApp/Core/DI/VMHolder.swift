import Combine
import Foundation

final class VMHolder<T: ObservableObject>: ObservableObject {
    private var cancellable: AnyCancellable?

    var vm: T? {
        didSet {
            cancellable = vm?.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
        }
    }
}
