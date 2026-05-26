import Foundation

struct TranslationResult {
    let originalText: String
    let translatedText: String
    let sourceLang: String
    let targetLang: String
}

enum TranslationError: LocalizedError {
    case noApiKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey:
            return L.current == .ja
                ? "DeepL APIキーが設定されていません。"
                : "DeepL API 키가 설정되지 않았습니다."
        case .networkError(let error):
            return "\(L.current == .ja ? "ネットワークエラー" : "네트워크 오류"): \(error.localizedDescription)"
        case .invalidResponse:
            return L.current == .ja ? "APIからの応答が不正です。" : "API 응답이 잘못되었습니다."
        case .apiError(let message):
            return "API: \(message)"
        }
    }
}

struct SupportedLanguage: Identifiable, Hashable {
    let code: String
    let name: String
    var id: String { code }

    static let all: [SupportedLanguage] = [
        SupportedLanguage(code: "JA", name: "日本語 / 일본어"),
        SupportedLanguage(code: "KO", name: "韓国語 / 한국어"),
        SupportedLanguage(code: "EN", name: "English"),
        SupportedLanguage(code: "ZH", name: "中文"),
        SupportedLanguage(code: "DE", name: "Deutsch"),
        SupportedLanguage(code: "FR", name: "Français"),
        SupportedLanguage(code: "ES", name: "Español"),
        SupportedLanguage(code: "PT", name: "Português"),
        SupportedLanguage(code: "IT", name: "Italiano"),
        SupportedLanguage(code: "NL", name: "Nederlands"),
        SupportedLanguage(code: "PL", name: "Polski"),
        SupportedLanguage(code: "RU", name: "Русский"),
    ]
}

class TranslationService {
    static let shared = TranslationService()
    private let baseURL = "https://api-free.deepl.com/v2/translate"

    private init() {}

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "deepl_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "deepl_api_key") }
    }

    var targetLanguage: String {
        get { UserDefaults.standard.string(forKey: "target_language") ?? "KO" }
        set { UserDefaults.standard.set(newValue, forKey: "target_language") }
    }

    func translate(_ text: String, targetOverride: String? = nil) async throws -> TranslationResult {
        guard !apiKey.isEmpty else {
            throw TranslationError.noApiKey
        }

        let target = targetOverride ?? targetLanguage

        let bodyString = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text)&target_lang=\(target)"

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw TranslationError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw TranslationError.apiError("HTTP \(httpResponse.statusCode): \(body)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let translations = json["translations"] as? [[String: Any]],
              let firstTranslation = translations.first,
              let translatedText = firstTranslation["text"] as? String else {
            throw TranslationError.invalidResponse
        }

        let detectedSource = (firstTranslation["detected_source_language"] as? String) ?? "??"

        return TranslationResult(
            originalText: text,
            translatedText: translatedText,
            sourceLang: detectedSource,
            targetLang: target
        )
    }
}
