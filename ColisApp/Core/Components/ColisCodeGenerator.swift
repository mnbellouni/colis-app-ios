import Foundation

enum ColisCodeGenerator {

    private static let alphabet: [Character] = Array("ACDEFGHJKMNPQRTVWXY234679")

    static func generate(length: Int = 10) -> String {
        var code = ""
        for _ in 0..<length {
            let index = Int.random(in: 0..<alphabet.count)
            code.append(alphabet[index])
        }
        return code
    }

    static func formatted(_ code: String) -> String {
        guard code.count == 10 else { return code }
        let i = code.index(code.startIndex, offsetBy: 5)
        return "\(code[..<i])-\(code[i...])"
    }

    static func isValid(_ code: String) -> Bool {
        let clean = code.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
        guard clean.count == 10 else { return false }
        return clean.allSatisfy { alphabet.contains($0) }
    }

    static func normalize(_ input: String) -> String {
        input.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
    }
}
