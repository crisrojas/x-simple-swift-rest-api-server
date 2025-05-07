// Created by Cristian Felipe Patiño Rojas on 7/5/25.

extension Array {
    subscript(idx idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}
