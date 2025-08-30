// MARK: - All Imports we need for the app
import Combine
import SwiftUI
import AVKit
import UniformTypeIdentifiers

// MARK: - NEW: Central Color and Style Management
struct ThemeColors {
    static let background = Color(hex: "#eef5ff")
    static let primaryText = Color(hex: "#0d3d8a")
    static let secondaryText = Color(hex: "#3a506b")

    static let cardBackground = Color.white
    static let cardBackgroundDark = Color(white: 0.15)

    // Adjusted action button background colors for better contrast
    static let actionButtonBackground = Color(hex: "#e0e0e0") // A bit darker gray for light mode
    static let actionButtonBackgroundDark = Color(hex: "#424242") // A bit lighter gray for dark mode
}


// MARK: - Enum for the color scheme (Light, Dark, System)
enum AppColorScheme: Int, CaseIterable, Identifiable {
    case system, light, dark
    var id: Int { self.rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Hell"
        case .dark: return "Dunkel"
        }
    }
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @AppStorage("textSize") var textSize: Double = 16
    @AppStorage("colorScheme") var colorScheme: AppColorScheme = .system
}

// MARK: - The logic for the "Usage" hint
enum Gebrauch: String, Codable {
    // New cases based on user request
    case hoeflich, neutralUmgangssprachlich, beleidigendSchimpfwort, vulgaerDerb

    var anzeigeText: String {
        switch self {
        case .hoeflich: return "Höflich"
        case .neutralUmgangssprachlich: return "Neutral / Umgangssprachlich"
        case .beleidigendSchimpfwort: return "Beleidigend / Schimpfwort"
        case .vulgaerDerb: return "Sehr starkes Schimpfwort, oft tabu, nur in extrem lockeren oder aggressiven Situationen."
        }
    }

    var detailErklaerung: String {
        switch self {
        case .hoeflich: return "Freundlich, respektvoll, für Alltag und formelle Situationen geeignet."
        case .neutralUmgangssprachlich: return "Alltagssprache, locker, nicht beleidigend, kann in Gesprächen benutzt werden."
        case .beleidigendSchimpfwort: return "Negativ, verletzend, sollte nur verstanden werden, nicht benutzen."
        case .vulgaerDerb: return "Sehr starkes Schimpfwort, oft tabu, nur in extrem lockeren oder aggressiven Situationen."
        }
    }
}

// MARK: - Data model (Vokabel)
struct Vokabel: Identifiable, Codable, Hashable {
    let id = UUID()
    let wort: String
    let erklaerung: String
    let kategorie: String
    let videoURL: URL
    let gebrauch: Gebrauch?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case wort, erklaerung, kategorie, videoURL, gebrauch
    }
}

// MARK: - Main view of the app (The entry point)
struct ContentView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showSplash = true

    private var preferredColorScheme: ColorScheme? {
        switch settingsManager.colorScheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else {
                MainTabView()
            }
        }
        .environmentObject(settingsManager)
        .environmentObject(FavoritesManager())
        .preferredColorScheme(preferredColorScheme)
    }
}

// MARK: - Tab Bar (MainTabView)
struct MainTabView: View {
    // ADD THIS SO settingsManager IS AVAILABLE IN THIS VIEW.
    @EnvironmentObject var settingsManager: SettingsManager

    // YOUR COMPLETE VOCABULARY LIST
    let allVokabeln: [Vokabel] = [
        // Existing vocabulary
        Vokabel(wort: "Hallo", erklaerung: "Ein Gruß, um jemanden zu begrüßen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Danke", erklaerung: "Ein Ausdruck der Dankbarkeit.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .hoeflich),
        Vokabel(wort: "Bitte", erklaerung: "Wird verwendet, um eine Bitte auszudrücken oder eine Danksagung zu erwidern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .hoeflich),
        Vokabel(wort: "Tschüss", erklaerung: "Eine Verabschiedung.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bundeskanzler", erklaerung: "Der Bundeskanzler ist der Chef der Regierung in Deutschland. Er bestimmt zusammen mit den Ministern, welche Politik gemacht wird, und leitet die Arbeit der Regierung.", kategorie: "Politik", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bundespräsdient", erklaerung: "Der Bundespräsident ist das Staatsoberhaupt von Deutschland. Er vertritt das Land nach außen, unterschreibt Gesetze und zeigt die Einheit des Staates. Die tägliche Politik bestimmt er nicht – das macht der Bundeskanzler..", kategorie: "Politik", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),

        // MARK: - NEW WORDS FOR CATEGORY "FAMILY"
        Vokabel(wort: "Mutter", erklaerung: "Ein weiblicher Elternteil.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vater", erklaerung: "Ein männlicher Elternteil.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Eltern", erklaerung: "Beide Elternteile, Mutter und Vater.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kind", erklaerung: "Der Nachwuchs einer Person.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kinder", erklaerung: "Mehrere Kinder.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sohn", erklaerung: "Ein männliches Kind.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tochter", erklaerung: "Ein weibliches Kind.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bruder", erklaerung: "Ein männliches Geschwister.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schwester", erklaerung: "Ein weibliches Geschwister.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Geschwister", erklaerung: "Brüder und/oder Schwestern.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Großmutter", erklaerung: "Die Mutter eines Elternteils.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Großvater", erklaerung: "Der Vater eines Elternteils.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Großeltern", erklaerung: "Die Großmutter und der Großvater.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Enkel", erklaerung: "Das Kind eines Sohnes oder einer Tochter.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Enkelin", erklaerung: "Die Tochter eines Sohnes oder einer Tochter.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Onkel", erklaerung: "Der Bruder eines Elternteils.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tante", erklaerung: "Die Schwester eines Elternteils.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Cousin", erklaerung: "Der Sohn von Tante oder Onkel.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Cousine", erklaerung: "Die Tochter von Tante oder Onkel.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Neffe", erklaerung: "Der Sohn eines Bruders oder einer Schwester.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Nichte", erklaerung: "Die Tochter eines Bruders oder einer Schwester.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ehemann", erklaerung: "Der Partner in einer Ehe.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ehefrau", erklaerung: "Die Partnerin in einer Ehe.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verheiratet", erklaerung: "Zwei Personen, die in einer Ehe verbunden sind.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Single", erklaerung: "Eine Person, die in keiner festen Beziehung ist.", kategorie: "Familie", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),

        // MARK: - FINGERALPHABET-VOCABULARY
        Vokabel(wort: "A", erklaerung: "Das Fingeralphaber für den Buchstaben A.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "B", erklaerung: "Das Fingeralphabet für den Buchstaben B.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "C", erklaerung: "Das Fingeralphabet für den Buchstaben C.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "D", erklaerung: "Das Fingeralphabet für den Buchstaben D.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "E", erklaerung: "Das Fingeralphabet für den Buchstaben E.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "F", erklaerung: "Das Fingeralphabet für den Buchstaben F.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "G", erklaerung: "Das Fingeralphabet für den Buchstaben G.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "H", erklaerung: "Das Fingeralphabet für den Buchstaben H.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "I", erklaerung: "Das Fingeralphabet für den Buchstaben I.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "J", erklaerung: "Das Fingeralphabet für den Buchstaben J.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "K", erklaerung: "Das Fingeralphabet für den Buchstaben K.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "L", erklaerung: "Das Fingeralphabet für den Buchstaben L.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "M", erklaerung: "Das Fingeralphabet für den Buchstaben M.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "N", erklaerung: "Das Fingeralphabet für den Buchstaben N.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "O", erklaerung: "Das Fingeralphabet für den Buchstaben O.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "P", erklaerung: "Das Fingeralphabet für den Buchstaben P.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Q", erklaerung: "Das Fingeralphabet für den Buchstaben Q.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "R", erklaerung: "Das Fingeralphabet für den Buchstaben R.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "S", erklaerung: "Das Fingeralphabet für den Buchstaben S.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "T", erklaerung: "Das Fingeralphabet für den Buchstaben T.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "U", erklaerung: "Das Fingeralphabet für den Buchstaben U.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "V", erklaerung: "Das Fingeralphabet für den Buchstaben V.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "W", erklaerung: "Das Fingeralphabet für den Buchstaben W.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "X", erklaerung: "Das Fingeralphabet für den Buchstaben X.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Y", erklaerung: "Das Fingeralphabet für den Buchstaben Y.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Z", erklaerung: "Das Fingeralphabet für den Buchstaben Z.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        // German umlauts and special characters
        Vokabel(wort: "Ä", erklaerung: "Das Fingeralphaber für den Buchstaben Ä.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ö", erklaerung: "Das Fingeralphabet für den Buchstaben Ö.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ü", erklaerung: "Das Fingeralphabet für den Buchstaben Ü.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "ß", erklaerung: "Das Fingeralphabet für den Buchstaben ß.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "SCH", erklaerung: "Das Fingeralphabet für die Buchstabenfolge SCH.", kategorie: "Fingeralphabet", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),

        // MARK: - NUMBER-VOCABULARY
        Vokabel(wort: "0", erklaerung: "Die Gebärde für die Zahl Null.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1", erklaerung: "Die Gebärde für die Zahl Eins.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "2", erklaerung: "Die Gebärde für die Zahl Zwei.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "3", erklaerung: "Die Gebärde für die Zahl Drei.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "4", erklaerung: "Die Gebärde für die Zahl Vier.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "5", erklaerung: "Die Gebärde für die Zahl Fünf.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "6", erklaerung: "Die Gebärde für die Zahl Sechs.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "7", erklaerung: "Die Gebärde für die Zahl Sieben.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "8", erklaerung: "Die Gebärde für die Zahl Acht.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "9", erklaerung: "Die Gebärde für die Zahl Neun.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "10", erklaerung: "Die Gebärde für die Zahl Zehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "11", erklaerung: "Die Gebärde für die Zahl Elf.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "12", erklaerung: "Die Gebärde für die Zahl Zwölf.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "13", erklaerung: "Die Gebärde für die Zahl Dreizehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "14", erklaerung: "Die Gebärde für die Zahl Vierzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "15", erklaerung: "Die Gebärde für die Zahl Fünfzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "16", erklaerung: "Die Gebärde für die Zahl Sechzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "17", erklaerung: "Die Gebärde für die Zahl Siebzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "18", erklaerung: "Die Gebärde für die Zahl Achtzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "19", erklaerung: "Die Gebärde für die Zahl Neunzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "20", erklaerung: "Die Gebärde für die Zahl Zwanzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "21", erklaerung: "Die Gebärde für die Zahl Einundzwanzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "22", erklaerung: "Die Gebärde für die Zahl Zweiundzwanzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "23", erklaerung: "Die Gebärde für die Zahl Dreiundzwanzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "30", erklaerung: "Die Gebärde für die Zahl Dreißig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "40", erklaerung: "Die Gebärde für die Zahl Vierzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "50", erklaerung: "Die Gebärde für die Zahl Fünfzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "60", erklaerung: "Die Gebärde für die Zahl Sechzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "70", erklaerung: "Die Gebärde für die Zahl Siebzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "80", erklaerung: "Die Gebärde für die Zahl Achtzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "90", erklaerung: "Die Gebärde für die Zahl Neunzig.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "100", erklaerung: "Die Gebärde für die Zahl Hundert.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "101", erklaerung: "Die Gebärde für die Zahl Hunderteins.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "105", erklaerung: "Die Gebärde für die Zahl Hundertfünf.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "106", erklaerung: "Die Gebärde für die Zahl Hundertsechs.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "110", erklaerung: "Die Gebärde für die Zahl Hundertzehn.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1000", erklaerung: "Die Gebärde für die Zahl Tausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "2000", erklaerung: "Die Gebärde für die Zahl Zweitausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "3000", erklaerung: "Die Gebärde für die Zahl Dreitausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "10.000", erklaerung: "Die Gebärde für die Zahl Zehntausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "20.000", erklaerung: "Die Gebärde für die Zahl Zwanzigtausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "60.000", erklaerung: "Die Gebärde für die Zahl Sechzigtausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "100.000", erklaerung: "Die Gebärde für die Zahl Hunderttausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "500.000", erklaerung: "Die Gebärde für die Zahl Fünfhunderttausend.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1 Million", erklaerung: "Die Gebärde für die Zahl Eine Million.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1 Milliarden", erklaerung: "Die Gebärde für die Zahl Eine Milliarde.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1 Billionen", erklaerung: "Die Gebärde für die Zahl Eine Billion.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "1980", erklaerung: "Die Gebärde für die Jahreszahl 1980.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "2025", erklaerung: "Die Gebärde für die Jahreszahl 2025.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "90er", erklaerung: "Die Gebärde für die 90er-Jahre.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "2000er", erklaerung: "Die Gebärde für die 2000er-Jahre.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "60er", erklaerung: "Die Gebärde für die 60er-Jahre.", kategorie: "Zahlen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),

        // MARK: - NEW WORDS FOR CATEGORY "Redewendungen"
        Vokabel(wort: "Die Zähne zusammenbeißen", erklaerung: "Eine schwierige Situation ertragen.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Auf den Hund gekommen", erklaerung: "In eine schlechte Situation geraten.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Das ist die Krönung", erklaerung: "Das ist der Höhepunkt, entweder im positiven oder negativen Sinne.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Jemandem den Laufpass geben", erklaerung: "Eine Beziehung beenden.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ins Gras beißen", erklaerung: "Sterben.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ein Stein vom Herzen fällt", erklaerung: "Erleichterung verspüren.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Die Katze im Sack kaufen", erklaerung: "Etwas kaufen, ohne es vorher genau geprüft zu haben.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tomaten auf den Augen haben", erklaerung: "Etwas Offensichtliches nicht sehen.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hast du denn einen Kater?", erklaerung: "Die Frage bezieht sich auf die Auswirkungen von Alkoholkonsum am nächsten Tag. Ein Kater bezeichnet den unangenehmen Zustand nach übermäßigem Alkoholgenuss, der durch Kopfschmerzen, Müdigkeit und allgemeines Unwohlsein gekennzeichnet sein kann.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Probieren geht über studieren", erklaerung: "Man lernt besser durch Ausprobieren als nur durch theoretisches Lernen.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich neige zum Plappern", erklaerung: "Ich rede oft viel und schnell, manchmal auch über Dinge, die nicht so wichtig sind.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Das leuchtet mir ein", erklaerung: "bedeutet, dass jemand etwas verstanden hat und es für logisch oder einleuchtend hält. Es ist eine Bestätigung, dass die Erklärung oder Information nachvollziehbar ist. Man könnte auch sagen: „Ich verstehe das jetzt.“ oder „Das ergibt Sinn.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Lass meine Seifenblase nicht platzen", erklaerung: "bedeutet, dass jemand etwas verstanden hat und es für logisch oder einleuchtend hält. Es ist eine Bestätigung, dass die Erklärung oder Information nachvollziehbar ist. Man könnte auch sagen: „Ich verstehe das jetzt.“ oder „Das ergibt Sinn.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gebongt", erklaerung: "bedeutet umgangssprachlich „abgemacht“ oder „in Ordnung“. Es wird verwendet, wenn man einer Sache zustimmt oder etwas bestätigt.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Darauf bin ich dann kleben geblieben", erklaerung: "Jemand kann nicht von etwas wegkommen. Etwas hat seine Aufmerksamkeit oder macht Probleme, und er beschäftigt sich lange damit.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Fisch und Besuch stinken nach 3 Tagen", erklaerung: "Ein Sprichwort, das bedeutet: Wenn etwas oder jemand zu lange bleibt, wird es unangenehm.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Niemals aus den Augen verlieren.", erklaerung: "Jemand oder etwas immer im Blick behalten, nicht vergessen oder aus dem Sinn verlieren.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Du willst, dass ich dich gegen die Wand fahren lasse?", erklaerung: "Das sagt jemand, wenn er ärgerlich oder drohend ist. Es bedeutet: Willst du, dass ich dich verletze oder in Schwierigkeiten bringe?", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich habe ihn im Griff", erklaerung: "Eine Redewendung, die bedeutet, dass man die Kontrolle über eine Person oder Situation hat.", kategorie: "Redewendungen", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),

        // MARK: - NEW WORDS FOR CATEGORY "Alltagssätze"
        Vokabel(wort: "Guten Morgen", erklaerung: "Eine Form der Begrüßung am Morgen.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Guten Abend", erklaerung: "Eine Form der Begrüßung am Abend.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gute Nacht", erklaerung: "Eine Form der Verabschiedung am Ende des Tages.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich fahre/gehe nach Hause", erklaerung: "Ich bin auf dem Weg nach Hause.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Wie geht es dir?", erklaerung: "Eine Frage nach dem Wohlbefinden einer Person.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Mir geht es nicht gut", erklaerung: "Ein Ausdruck, dass es jemandem körperlich oder emotional schlecht geht.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hast du Durst?", erklaerung: "Eine Frage, ob jemand etwas trinken möchte.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hast du Hunger?", erklaerung: "Eine Frage, ob jemand etwas essen möchte.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Möchtest du auch mitkommen?", erklaerung: "Eine Einladung an jemanden, sich einer Gruppe anzuschließen.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich bin satt", erklaerung: "Ein Ausdruck, dass man genug gegessen hat.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Was machst du?", erklaerung: "Eine Frage nach der aktuellen Aktivität oder dem Vorhaben einer Person.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bist du müde?", erklaerung: "Eine Frage nach dem Zustand der Müdigkeit.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Warum hast du mich ignoriert?", erklaerung: "Eine Frage, um den Grund für eine fehlende Reaktion zu erfahren.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Der Zug ist verpasst", erklaerung: "Eine Aussage über eine verpasste Gelegenheit oder ein verpasstes Verkehrsmittel.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich schaffe es", erklaerung: "Ein Ausdruck von Zuversicht und der Fähigkeit, eine Aufgabe zu bewältigen.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ja, stimmt", erklaerung: "Ein Ausdruck der Zustimmung, dass etwas richtig ist.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Du hast so schnell Gebärdensprache", erklaerung: "Ein Hinweis an eine Person, dass ihre Gebärden zu schnell sind.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bitte langsam Gebärdensprache", erklaerung: "Eine höfliche Aufforderung, die Gebärden zu verlangsamen.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Habe ich mich verständlich ausgedrückt?", erklaerung: "Eine Frage, die nach der Verständlichkeit fragt.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich habe kein Lust", erklaerung: "Ein umgangssprachlicher Ausdruck, dass man etwas nicht tun möchte.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hast du Lust?", erklaerung: "Eine umgangssprachliche Frage, ob jemand etwas tun möchte.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Lehrer:in hat mich ständig zwingen", erklaerung: "Eine Aussage über den Zwang durch eine Lehrperson.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich bin sprachlos", erklaerung: "Ein Ausdruck von großer Überraschung oder Fassungslosigkeit.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Herzlich Willkommen", erklaerung: "Eine höfliche Begrüßung für jemanden, der ankommt.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich fahre mit dem Auto", erklaerung: "Beschreibung der Fahrt mit einem Auto.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Übertrieben nicht", erklaerung: "Eine umgangssprachliche Feststellung, dass etwas nicht übertrieben oder übertrieben dargestellt ist.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich wünsche dir alles Gute zum Geburtstag", erklaerung: "Ein Wunsch, der Glück und Erfolg für das neue Lebensjahr ausdrückt.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich wünsche dir Herzlichen Glückwunsch zum Geburtstag", erklaerung: "Ein förmlicher Glückwunsch zum Geburtstag.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Was laberst du scheiß", erklaerung: "Ein sehr vulgärer und beleidigender Ausdruck, der anzeigt, dass jemand Unsinn redet.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bitte vernünftig", erklaerung: "Eine Aufforderung, sich rational oder angemessen zu verhalten.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Echt unmöglich", erklaerung: "Ein Ausdruck der Empörung oder des Unglaubens über das Verhalten einer Person.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Halt Maul", erklaerung: "Ein sehr unhöflicher und beleidigender Befehl, leise zu sein.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Stört mich nicht", erklaerung: "Ein Ausdruck, der besagt, dass man sich durch etwas nicht gestört fühlt.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ich lache mich kaputt", erklaerung: "Ein umgangssprachlicher Ausdruck für sehr starkes Lachen.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bitte Respekt", erklaerung: "Eine Aufforderung, respektvoll zu sein.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kein Chance", erklaerung: "Ein umgangssprachlicher Ausdruck, dass etwas unmöglich ist.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Laff", erklaerung: "Eine umgangssprachliche, abwertende Beschreibung für eine Person, die als (lahm) oder (langweilig) empfunden wird.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Du begreifst nicht", erklaerung: "Eine Feststellung, dass jemand eine Sache nicht versteht oder nachvollziehen kann.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Du schaffst nicht", erklaerung: "Ein Ausdruck von Zweifel an der Fähigkeit einer Person.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Er gewinnt gegen dich", erklaerung: "Eine Aussage über das Ergebnis eines Wettbewerbs.", kategorie: "Alltagssätze", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, gebrauch: .neutralUmgangssprachlich),
        
        // MARK: - NEW WORDS FROM THE PDF FILE FOR CATEGORY "Allgemein"
        Vokabel(wort: "Muckis", erklaerung: "Umgangssprachlich für starke und gut entwickelte Muskeln.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schmunzeln", erklaerung: "Ein leichtes Lächeln ohne sichtbare Zähne.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Rechenschaft", erklaerung: "Die Verpflichtung, jemandem Bericht zu erstatten oder Informationen weiterzugeben.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schlugen", erklaerung: "Eine alternative Schreibweise für das Verb 'schlagen'.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Alternative", erklaerung: "Eine andere Möglichkeit oder Option.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Distanziert", erklaerung: "Zurückhaltend, kühl oder auf Abstand gehend.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Quasi", erklaerung: "Sozusagen, gewissermaßen, fast.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Quasimodo", erklaerung: "Eine Figur aus dem Roman 'Der Glöckner von Notre-Dame', bekannt für sein ungewöhnliches Aussehen.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Katastrophe", erklaerung: "Eine Katastrophe bezieht sich auf ein schweres Unglück oder eine Situation, die sehr schlecht oder chaotisch ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ehrgeizig", erklaerung: "Wenn jemand ehrgeizig ist, bedeutet das, dass er oder sie hohe Ziele hat und bereit ist, hart zu arbeiten, um diese Ziele zu erreichen.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Eventuell", erklaerung: "Eventuell bedeutet 'möglicherweise' oder 'unter Umständen', um auszudrücken, dass etwas möglich sein könnte, aber nicht sicher ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Konsequenz", erklaerung: "Eine Konsequenz bezieht sich auf die Folge oder das Ergebnis einer Handlung. Es kann auch bedeuten, dass jemand für sein Handeln verantwortlich gemacht wird.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Komponenten", erklaerung: "Komponenten sind Teile oder Elemente, die zusammenkommen, um ein Ganzes zu bilden oder zusammenzuarbeiten.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Manipuliert", erklaerung: "Manipuliert bedeutet, dass etwas oder jemand absichtlich beeinflusst oder kontrolliert wird, oft mit einer verborgenen Agenda.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Egoismus / egoistisch", erklaerung: "Egoismus oder egoistisch zu sein bedeutet, dass man hauptsächlich auf seine eigenen Interessen und Bedürfnisse fokussiert ist und weniger Rücksicht auf andere nimmt.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Genie", erklaerung: "Ein Genie ist eine Person mit außergewöhnlicher Intelligenz oder außergewöhnlichen Fähigkeiten in einem bestimmten Bereich.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Fummeln", erklaerung: "Fummeln bedeutet, dass man mit den Händen herumspielt oder etwas leicht anfasst, oft in einer ungeschickten oder ziellosen Art und Weise.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Splat", erklaerung: "Splat beschreibt das Geräusch oder die Aktion von etwas, das auf eine Oberfläche trifft und einen Fleck oder Spritzer hinterlässt.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Erkundigen", erklaerung: "Sich erkundigen bedeutet, Informationen zu suchen oder Fragen zu stellen, um mehr über etwas zu erfahren.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hervorragend", erklaerung: "Hervorragend bedeutet, dass etwas außergewöhnlich gut, ausgezeichnet oder von hoher Qualität ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Amor", erklaerung: "Amor ist eine mythologische Figur, oft als Engel oder Gott der Liebe dargestellt, der die Menschen dazu bringt, sich zu verlieben.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Inzest", erklaerung: "Inzest bezeichnet sexuelle Beziehungen oder Ehen zwischen engen Verwandten, was in den meisten Gesellschaften als moralisch inakzeptabel angesehen wird.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vaginal", erklaerung: "'Vaginal' bezieht sich auf das weibliche Geschlechtsorgan, nämlich die Vagina. Es ist ein medizinischer Begriff und wird normalerweise nicht umgangssprachlich mit 'Muschi' gleichgesetzt.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gerippe", erklaerung: "Ein Gerippe bezieht sich auf ein Skelett oder die Knochenstruktur eines Lebewesens, wenn es nicht mit Fleisch oder Gewebe bedeckt ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Nicken", erklaerung: "'Nicken' bedeutet zustimmend mit dem Kopf auf und ab zu bewegen, um Ja auszudrücken.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Disziplin", erklaerung: "Disziplin bezieht sich auf die Fähigkeit, sich selbst zu kontrollieren, bestimmte Regeln oder Standards einzuhalten und Verantwortung zu übernehmen.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Prinzipiell", erklaerung: "'Prinzipiell' bedeutet grundsätzlich oder im Grundsatz. Es drückt eine allgemeine Haltung, Meinung oder Einstellung aus.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Interpretieren", erklaerung: "Interpretieren bezieht sich darauf, etwas zu analysieren, zu verstehen oder eine Bedeutung aus etwas herauszulesen, wie zum Beispiel aus dem Verhalten einer Person.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Paparazzi", erklaerung: "Paparazzi sind Fotografen oder Personen, die prominenten Menschen hinterherjagen und versuchen, intime oder sensationelle Fotos von ihnen zu machen. Es kann als eine Art von Stalking angesehen werden.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Autismus", erklaerung: "Autismus ist eine Entwicklungsstörung, die sich in verschiedenen Bereichen wie sozialer Interaktion, Kommunikation und Verhaltensweisen manifestieren kann. Es ist kein Syndrom, sondern eine eigenständige Diagnose.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Faustregel", erklaerung: "Die 50% Faustregel könnte auf die Regel hindeuten, dass eine bestimmte Menge Geld (50% des Einkommens) für die Miete verwendet werden sollte, während die andere Hälfte für andere Ausgaben wie Lebensmittel, Transport usw. verwendet werden kann.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ambivalenz", erklaerung: "Ambivalenz bezieht sich auf das gleichzeitige Vorhandensein widersprüchlicher Gefühle, Meinungen oder Einstellungen gegenüber einer Person, Situation oder einem Objekt.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vorurteilen", erklaerung: "Vorurteilen bezieht sich auf vorgefasste Meinungen, Annahmen oder Urteile über eine Person oder eine Gruppe, die oft auf Stereotypen basieren und respektlos sein können.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Engagement", erklaerung: "Engagement bezieht sich auf die Hingabe, Leidenschaft und Aktivität in Bezug auf eine bestimmte Sache oder ein bestimmtes Ziel. Es kann auch bedeuten, dass man sich für eine Sache einsetzt oder sich engagiert.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Negrito", erklaerung: "'Negrito' ist eine abwertende Bezeichnung für dunkelhäutige Menschen. Der Begriff ist rassistisch und respektlos.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Austoben", erklaerung: "'Austoben' bedeutet, sich körperlich oder emotional freizulassen, oft durch Aktivitäten, bei denen man Energie abbaut oder Gefühle ausdrückt.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Krawalle", erklaerung: "Krawalle beziehen sich auf chaotische oder gewalttätige Auseinandersetzungen in der Öffentlichkeit, während 'Evakuierung' die Maßnahme ist, Menschen aus einem gefährlichen Ort in Sicherheit zu bringen.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Suizid", erklaerung: "Suizid bezeichnet den Akt, sich selbst das Leben zu nehmen. Es handelt sich um ein ernstes Thema, bei dem dringend professionelle Hilfe und Unterstützung benötigt wird.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Begehren", erklaerung: "'Begehren' bedeutet, ein starkes Verlangen nach etwas oder jemandem zu haben, oft mit sexueller oder emotionaler Anziehungskraft verbunden.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Beeinflussen", erklaerung: "'Beeinflussen' bedeutet, einen Einfluss auf jemanden oder etwas auszuüben, um eine Veränderung herbeizuführen oder eine bestimmte Handlung, Meinung oder Einstellung zu beeinflussen.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Agnostisch", erklaerung: "Agnostisch zu sein bedeutet, dass man unsicher oder unklar in Bezug auf die Existenz oder Wahrheit von Gottesvorstellungen ist. Es ist eine Haltung der Unsicherheit oder des Zweifels.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Pforte", erklaerung: "Eine Pforte bezieht sich auf eine Tür oder einen Eingang, oft verwendet im Zusammenhang mit einem Zaun oder einer Einrichtung.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Visagist", erklaerung: "Ein Visagist ist eine Person, die professionell Make-up aufträgt und sich auf die Verschönerung und Veränderung des Aussehens einer Person spezialisiert hat.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Pestizid", erklaerung: "Pestizide sind chemische Substanzen, die zur Bekämpfung von Schädlingen, Unkräutern oder Krankheiten in der Landwirtschaft eingesetzt werden. Sie werden verwendet, um Pflanzen vor Schäden zu schützen, können aber auch Auswirkungen auf die Umwelt und die Gesundheit haben.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verbal, nonverbal, paraverbal", erklaerung: "Diese Begriffe beziehen sich auf verschiedene Arten der Kommunikation. 'Verbal' bezieht sich auf die Verwendung von Worten und Sprache. 'Nonverbal' bezieht sich auf die Kommunikation durch Gesten, Mimik, Körpersprache usw. 'Paraverbal' bezieht sich auf die Art und Weise, wie Worte ausgesprochen werden, wie Tonfall, Betonung und Tempo.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Blinde Vandalismus Zerstörungswut", erklaerung: "Hier werden drei Begriffe verwendet, um eine Art von Zerstörung zu beschreiben. 'Blinde' bedeutet hier wahllos oder ohne klaren Zweck. 'Vandalismus' bezieht sich auf absichtliche Beschädigung oder Zerstörung von Eigentum. 'Zerstörungswut' bedeutet eine extreme Form des Wunsches, Dinge zu zerstören oder Schaden anzurichten.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Amüsiert", erklaerung: "'Amüsiert' bedeutet, dass man sich unterhalten fühlt, Spaß hat oder sich gut unterhält. Es ist mit einer positiven und vergnügten Stimmung verbunden.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Diktator", erklaerung: "Ein Diktator ist eine Einzelperson, die unumschränkte Macht über ein Land oder eine Regierung ausübt und oft autoritär und unterdrückend herrscht. Der Begriff steht im Gegensatz zur Demokratie, in der die Macht auf das Volk verteilt ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schulterzuckend", erklaerung: "'Schulterzuckend' bezieht sich auf eine Geste, bei der man die Schultern anhebt, um auszudrücken, dass man keine Antwort kennt, unsicher ist oder etwas nicht weiß. Es kann auch bedeuten, dass man gleichgültig oder uninteressiert ist.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tuben", erklaerung: "'Tuben' ist kein spezifischer Begriff. Es könnte sich auf Tubenverpackungen beziehen, die für verschiedene Produkte wie Zahnpasta oder Cremes verwendet werden.", kategorie: "Allgemein", videoURL: URL(string: "https://placehold.co/1280x720/000000/FFFFFF?text=Video+folgt")!, gebrauch: .neutralUmgangssprachlich),

        Vokabel(wort: "Bipolar", erklaerung: "Eine psychische Erkrankung, die durch extreme Stimmungsschwankungen zwischen Manie und Depression gekennzeichnet ist.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schwankungsstimmen", erklaerung: "Ein seltener Begriff für Stimmen oder Meinungen, die sich ändern oder schwanken, besonders unter Stress.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Pissoir", erklaerung: "Eine öffentliche Toilette für Männer, die zum Stehen beim Wasserlassen gedacht ist.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Querdenker", erklaerung: "Bezieht sich auf Menschen, die unkonventionelle Ansichten vertreten, oft gegen etablierte Normen. Der Begriff wird auch für eine politische Bewegung verwendet.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sturz", erklaerung: "Das Herunterfallen eines Gegenstandes oder einer Person.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Absturz", erklaerung: "Ein Unfall durch Herunterfallen aus großer Höhe, auch der Zusammenbruch eines Systems (z.B. Computer).", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Rüstzeit", erklaerung: "Die Zeit, die benötigt wird, um eine Maschine oder einen Arbeitsplatz für eine neue Aufgabe vorzubereiten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Erschöpft", erklaerung: "Der Zustand, extrem müde, entkräftet oder energielos zu sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Herangehensweisen", erklaerung: "Verschiedene Methoden, Ansätze oder Strategien, um ein Problem zu lösen oder eine Aufgabe anzugehen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ertragen", erklaerung: "Etwas Schwieriges oder Unangenehmes aushalten oder erdulden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Klang", erklaerung: "Der Ton oder das Geräusch, das durch Schwingungen erzeugt wird; auch die Qualität eines Geräusches.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schnurren", erklaerung: "Das vibrierende Geräusch, das Katzen machen, wenn sie zufrieden sind.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Perfektionistisch", erklaerung: "Die Eigenschaft einer Person, die danach strebt, alles fehlerfrei und in höchster Qualität zu machen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Stechuhr", erklaerung: "Eine Vorrichtung, mit der Mitarbeiter ihre Arbeitszeiten erfassen, indem sie beim Kommen und Gehen stempeln.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Präzis", erklaerung: "Genau, klar und fokussiert; eine akkurate Vorgehensweise.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Teufelspakt", erklaerung: "Eine metaphorische Vereinbarung, bei der jemand moralische Prinzipien aufgibt, um persönlichen Erfolg zu erlangen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Auftauchen", erklaerung: "Unerwartet oder plötzlich erscheinen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Testament", erklaerung: "Ein rechtliches Dokument, in dem eine Person festlegt, was nach ihrem Tod mit ihrem Eigentum geschehen soll.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Trödeln", erklaerung: "Langsam oder zögerlich handeln; sich unnötig viel Zeit lassen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Handlungsabläufe", erklaerung: "Die Reihenfolge von Schritten bei der Durchführung einer Aufgabe oder eines Prozesses.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verblüfft", erklaerung: "Fassungslos, überrascht oder sprachlos sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Erteilen", erklaerung: "Etwas gewähren oder weitergeben, z.B. eine Erlaubnis, einen Auftrag oder eine Information.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Lektion", erklaerung: "Eine Unterrichtseinheit oder eine Erfahrung, aus der man lernt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ermutigen", erklaerung: "Jemanden Mut zusprechen, ihn unterstützen oder anspornen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Anwesenden", erklaerung: "Personen, die bei einer Veranstaltung oder an einem Ort präsent sind.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Entzückend", erklaerung: "Bezaubernd, charmant oder herzig sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .hoeflich),
        Vokabel(wort: "Verschwunden", erklaerung: "Der Zustand, nicht mehr vorhanden oder nicht mehr auffindbar zu sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Weile", erklaerung: "Eine unbestimmte, meist kurze Zeitspanne.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ultimativ", erklaerung: "Das Höchste, Beste oder Endgültige in seiner Art.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Versagen", erklaerung: "In seinen Bemühungen scheitern oder nicht erfolgreich sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sinken", erklaerung: "Sich nach unten bewegen, abfallen oder absinken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Perplex", erklaerung: "Ein Zustand der Verwirrung, Überraschung oder Ratlosigkeit.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Facetten", erklaerung: "Verschiedene Aspekte, Seiten oder Perspektiven einer Sache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Survivor", erklaerung: "Englisch für 'Überlebender'; eine Person, die eine schwierige oder gefährliche Situation überlebt hat.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Institution", erklaerung: "Eine etablierte Organisation oder Einrichtung mit gesellschaftlicher Bedeutung, z.B. eine Schule oder Regierung.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Impulsiv", erklaerung: "Ohne langes Nachdenken oder Planung handeln; spontan auf einen Reiz reagieren.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Quasselstrippe", erklaerung: "Eine Person, die sehr gerne und viel redet.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hindernisse", erklaerung: "Barrieren, Schwierigkeiten oder Probleme, die den Fortschritt behindern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gruselig", erklaerung: "Erschreckend oder beängstigend sein; Unbehagen oder Gänsehaut hervorrufen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Definitiv", erklaerung: "Endgültig, bestimmt oder unumstößlich; ohne Zweifel.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Abwertend", erklaerung: "Eine herablassende, respektlose oder negative Haltung oder Sprache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Beeinträchtigung", erklaerung: "Eine Einschränkung des Hörvermögens, die von leichter Schwerhörigkeit bis zur Gehörlosigkeit reichen kann.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Effektiv", erklaerung: "Wirksam sein; das gewünschte Ergebnis oder Ziel erreichen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sichtweise", erklaerung: "Die individuelle Perspektive, Meinung oder Ansicht einer Person.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Auf die Art und Weise", erklaerung: "Beschreibt die spezifische Form oder das Verfahren, wie etwas getan wird.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Parlamente", erklaerung: "Die gesetzgebenden Versammlungen eines Staates, in denen Abgeordnete politische Entscheidungen treffen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Partei", erklaerung: "Eine politische Organisation mit gemeinsamen Zielen oder eine Gruppe von Menschen bei einer Feier.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tokenismus", erklaerung: "Die nur symbolische Handlung, eine Person einer Minderheit einzubeziehen, um den Anschein von Gleichberechtigung zu erwecken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verachtet", erklaerung: "Stark abgelehnt, gering geschätzt oder herabgewürdigt werden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Entzug", erklaerung: "Der Prozess der Befreiung von einer Sucht (z.B. Alkohol) oder das Wegnehmen von etwas.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kreidebleich", erklaerung: "Sehr blass im Gesicht sein, oft aufgrund von Schreck oder Krankheit.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Oxycodon", erklaerung: "Ein sehr starkes Schmerzmittel aus der Gruppe der Opioide, das abhängig machen kann.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sinnlichkeit", erklaerung: "Die Eigenschaft, sexuell attraktiv oder anziehend zu wirken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kafir", erklaerung: "Ein arabisches Wort für 'Ungläubiger'. Der Begriff kann je nach Kontext abwertend sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Analysieren", erklaerung: "Etwas systematisch und gründlich untersuchen, um es zu verstehen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Betrachten", erklaerung: "Etwas aufmerksam ansehen oder über etwas nachdenken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Assoziiert", erklaerung: "Gedanklich miteinander verbunden oder in Beziehung gesetzt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Variieren", erklaerung: "Sich verändern oder Unterschiede aufweisen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Stattdessen", erklaerung: "Anstelle von etwas anderem.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vermitteln", erklaerung: "Informationen oder Fähigkeiten weitergeben oder eine Verbindung zwischen Personen herstellen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ermitteln", erklaerung: "Durch Nachforschungen etwas herausfinden, oft im polizeilichen oder wissenschaftlichen Kontext.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Übermitteln", erklaerung: "Informationen oder Nachrichten von einem Ort oder einer Person zu einem anderen senden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Explizit", erklaerung: "Klar und deutlich ausgedrückt, ohne Raum für Zweifel.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Wegnicken", erklaerung: "Umgangssprachlich für kurz einschlafen, oft im Sitzen und unabsichtlich.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vorübergehend", erklaerung: "Nur für eine begrenzte Zeit dauernd, nicht für immer.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Scheitern", erklaerung: "Ein Ziel nicht erreichen oder bei einem Vorhaben keinen Erfolg haben.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ruinieren", erklaerung: "Etwas zerstören, stark beschädigen oder in einen sehr schlechten Zustand bringen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Ombudsmann", erklaerung: "Eine unparteiische Schlichtungsperson, die bei Konflikten zwischen Bürgern und Behörden oder Unternehmen vermittelt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Pipetten", erklaerung: "Kleine Glas- oder Kunststoffröhrchen zum Abmessen und Übertragen kleiner Flüssigkeitsmengen im Labor.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Petting", erklaerung: "Intime, sexuelle Berührungen und Zärtlichkeiten ohne Geschlechtsverkehr.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Fingerschnippen", erklaerung: "Ein schnelles, knackendes Geräusch, das durch das schnelle Bewegen von Daumen und Mittelfinger erzeugt wird.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Empowern", erklaerung: "Jemanden befähigen oder ermächtigen, selbstbestimmt und selbstbewusst zu handeln.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schubladendenken", erklaerung: "Die Tendenz, Menschen in einfache, starre Kategorien oder Klischees einzuordnen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Vorgehensweise", erklaerung: "Die Art und Weise oder die Methode, wie man bei einer Aufgabe oder einem Problem vorgeht.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Methode", erklaerung: "Ein geplanter und systematischer Weg, um ein bestimmtes Ziel zu erreichen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Art und Weise", erklaerung: "Beschreibt die spezifische Form oder das Verfahren, wie etwas getan wird.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Rechtsruck", erklaerung: "Eine politische Entwicklung in einer Gesellschaft, bei der konservative oder rechte Positionen an Einfluss gewinnen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Einwanderung", erklaerung: "Der Prozess, bei dem Menschen in ein anderes Land ziehen, um dort dauerhaft zu leben.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Rivalin", erklaerung: "Eine weibliche Person, die mit einer anderen im Wettbewerb steht, z.B. um Liebe, Erfolg oder Anerkennung.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Dynamiken", erklaerung: "Die Kräfte, Prozesse und Interaktionen, die eine Gruppe oder ein System beeinflussen und verändern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Orgie", erklaerung: "Eine sexuelle Aktivität, an der mehrere Personen gleichzeitig teilnehmen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .vulgaerDerb),
        Vokabel(wort: "Draufgänger", erklaerung: "Eine Person, die mutig, risikofreudig und oft ungestüm ist und keine Angst vor Gefahren hat.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Desto", erklaerung: "Ein Wort, das in Vergleichen verwendet wird, um eine proportionale Beziehung auszudrücken (je... desto...).", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Konvertieren", erklaerung: "Den Glauben zu einer anderen Religion wechseln oder Daten in ein anderes Format umwandeln.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Posttraumatische Belastungsstörung", erklaerung: "Eine psychische Erkrankung, die nach einem traumatischen Erlebnis auftreten kann.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kannibalismus", erklaerung: "Der Verzehr von Fleisch der eigenen Art, bei Menschen das Essen von Menschenfleisch.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kulissen", erklaerung: "Die Bühnenbilder und Dekorationen im Theater oder Film.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kabinett", erklaerung: "Die Gruppe der Ministerinnen und Minister, die zusammen die Regierung bilden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Desinformation", erklaerung: "Die gezielte Verbreitung von falschen oder irreführenden Informationen, um die öffentliche Meinung zu täuschen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kolumne", erklaerung: "Ein regelmäßiger, meinungsbetonter Beitrag eines Autors in einer Zeitung oder Zeitschrift.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Makellos", erklaerung: "Perfekt und ohne jegliche Fehler oder Mängel.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kollaborationen", erklaerung: "Zusammenarbeit von zwei oder mehr Personen oder Organisationen an einem gemeinsamen Projekt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Inspiriert", erklaerung: "Durch eine Person, ein Erlebnis oder ein Werk zu neuen kreativen Ideen angeregt werden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verzockt", erklaerung: "Umgangssprachlich für Geld oder eine Chance durch eine riskante, fehlgeschlagene Wette oder Entscheidung verlieren.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überzeugt", erklaerung: "Der Zustand, fest an etwas zu glauben oder von der Richtigkeit einer Sache sicher zu sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überzeugung", erklaerung: "Ein fester Glaube oder eine feste Meinung, die eine Person hat.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schleppen", erklaerung: "Etwas Schweres mühsam ziehen oder tragen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Surreal", erklaerung: "Sehr seltsam, traumhaft oder unwirklich erscheinend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Umgeben", erklaerung: "Sich rings um etwas oder jemanden befinden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "20*C+M+B*25", erklaerung: "Der Segensspruch der Sternsinger: 'Christus mansionem benedicat' (Christus segne dieses Haus), mit der aktuellen Jahreszahl.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Strukturieren", erklaerung: "Dinge ordnen, gliedern oder in eine klare Form bringen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Variationen", erklaerung: "Unterschiedliche Versionen, Abwandlungen oder Ausführungen von etwas.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Spekulationen", erklaerung: "Vermutungen oder Annahmen über etwas, für das es keine gesicherten Informationen gibt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Einzigartig", erklaerung: "Besonders und einmalig sein; sich von allem anderen unterscheiden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Broadway", erklaerung: "Ein berühmtes Theaterviertel in New York, bekannt für seine aufwändigen Musical-Produktionen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überheblichkeit", erklaerung: "Die Eigenschaft, sich selbst für besser oder wichtiger als andere zu halten und dies zu zeigen; Arroganz.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Dementsprechend", erklaerung: "Folglich, deshalb; in Übereinstimmung mit dem, was vorher gesagt wurde.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Infam", erklaerung: "In bösartiger Weise schändlich, niederträchtig oder ehrlos.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Spektakulär", erklaerung: "Sehr beeindruckend, aufregend oder aufsehenerregend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Beeindruckend", erklaerung: "Einen starken, bleibenden Eindruck hinterlassend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gedächtnis", erklaerung: "Die Fähigkeit des Gehirns, Informationen zu speichern und sich daran zu erinnern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Koordinieren", erklaerung: "Verschiedene Aktivitäten oder Personen so aufeinander abstimmen, dass sie gut zusammenarbeiten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Geist", erklaerung: "Der Verstand, die Gedanken und die Seele eines Menschen; auch ein übernatürliches Wesen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Reibungslos", erklaerung: "Ohne Probleme, Störungen oder Schwierigkeiten ablaufend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Metaphorisch", erklaerung: "Im übertragenen, bildhaften Sinne verwendet, nicht wörtlich.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ressourcen", erklaerung: "Mittel, die zur Verfügung stehen, um ein Ziel zu erreichen, z.B. Geld, Material, Zeit oder Wissen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Nostradamus", erklaerung: "Ein französischer Astrologe und Arzt des 16. Jahrhunderts, der für seine Prophezeiungen bekannt ist.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Nüchtern", erklaerung: "Nicht unter dem Einfluss von Alkohol; auch sachlich und unaufgeregt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Deal", erklaerung: "Eine Vereinbarung, ein Geschäft oder ein Kompromiss.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bodenständig", erklaerung: "Praktisch, vernünftig und mit einem guten Sinn für die Realität; nicht abgehoben.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Akzeptabel", erklaerung: "Annehmbar oder ausreichend; gut genug, um akzeptiert zu werden.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sexismus", erklaerung: "Die Diskriminierung oder Benachteiligung von Menschen aufgrund ihres Geschlechts.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Subtil", erklaerung: "Fein, kaum wahrnehmbar oder mit feinen Nuancen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Entstehen", erklaerung: "Beginnen zu existieren; sich bilden oder entwickeln.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Komfort", erklaerung: "Zustand des körperlichen oder seelischen Wohlbefindens; Bequemlichkeit.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gleichaltrige", erklaerung: "Personen, die ungefähr im gleichen Alter sind.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Ideal", erklaerung: "Perfekt, bestmöglich oder einer Vorstellung entsprechend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Aspekt", erklaerung: "Ein bestimmter Teil, eine Seite oder eine Sichtweise einer Sache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überwältigend", erklaerung: "So groß, stark oder beeindruckend, dass es einen fast überfordert.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Brillant", erklaerung: "Außergewöhnlich gut, hervorragend oder glänzend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .hoeflich),
        Vokabel(wort: "Imponieren", erklaerung: "Jemanden stark beeindrucken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Genial", erklaerung: "Besonders klug, kreativ oder auf beeindruckende Weise einfach.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Psyche", erklaerung: "Die Gesamtheit der Gedanken, Gefühle und des Bewusstseins eines Menschen; die Seele.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verborgen", erklaerung: "Versteckt oder nicht direkt sichtbar.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Illustrieren", erklaerung: "Etwas mit Bildern verdeutlichen oder veranschaulichen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Eindrucksvoll", erklaerung: "Einen starken, bleibenden Eindruck hinterlassend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Kollektion", erklaerung: "Eine Sammlung von zusammengehörigen Dingen, besonders in der Mode oder Kunst.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Hörbeeinträchtigung", erklaerung: "Eine Einschränkung des Hörvermögens, die von leichter Schwerhörigkeit bis zur Gehörlosigkeit reichen kann.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Irrelevant", erklaerung: "Unwichtig oder ohne Bedeutung für das aktuelle Thema.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Relevanz", erklaerung: "Die Wichtigkeit oder Bedeutung von etwas in einem bestimmten Zusammenhang.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Relativ", erklaerung: "Im Verhältnis oder im Vergleich zu etwas anderem betrachtet.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sabotieren", erklaerung: "Absichtlich etwas stören, behindern oder zerstören, um einen Erfolg zu verhindern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Erwidern", erklaerung: "Auf etwas antworten oder eine Geste oder Handlung mit einer ähnlichen Tat beantworten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Begnadigen", erklaerung: "Jemandem eine Strafe erlassen, oft durch eine hohe Autorität wie einen Präsidenten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Massenansturm", erklaerung: "Wenn sehr viele Menschen gleichzeitig zu einem Ort oder Ereignis strömen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Optimistisch", erklaerung: "Eine positive und zuversichtliche Lebenseinstellung haben; an das Gute glauben.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Gesellig", erklaerung: "Gern in der Gesellschaft anderer Menschen sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schwärmerei", erklaerung: "Eine begeisterte, oft romantische und manchmal kurzlebige Verehrung für eine Person oder Sache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verpeilt", erklaerung: "Umgangssprachlich für unkonzentriert, verwirrt oder chaotisch.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Abwägen", erklaerung: "Verschiedene Möglichkeiten oder Argumente sorgfältig vergleichen, um eine Entscheidung zu treffen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Zieren", erklaerung: "Etwas schmücken oder schöner machen; auch sich zögerlich oder schüchtern verhalten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Scheu", erklaerung: "Ängstlich oder zurückhaltend im Umgang mit anderen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Neigen zu", erklaerung: "Die Tendenz oder Angewohnheit haben, etwas Bestimmtes zu tun.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Plappern", erklaerung: "Viel und schnell reden, oft über Unwichtiges und meist auf eine harmlose Weise.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Widerstand", erklaerung: "Sich gegen etwas oder jemanden wehren; eine Kraft, die eine Bewegung bremst.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Weder", erklaerung: "Ein Wort, das anzeigt, dass keine von zwei oder mehr Möglichkeiten zutrifft (weder... noch...).", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Projizieren", erklaerung: "Eigene Gefühle oder Wünsche unbewusst auf andere übertragen; auch ein Bild an eine Wand werfen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vermasseln", erklaerung: "Umgangssprachlich für etwas verderben, einen Fehler machen oder bei etwas scheitern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Vorschuss", erklaerung: "Eine Vorauszahlung auf einen Lohn oder eine Leistung, die man später erhält.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Widerlich", erklaerung: "Sehr unangenehm, abstoßend oder ekelhaft.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .beleidigendSchimpfwort),
        Vokabel(wort: "Jemanden abtörnen", erklaerung: "Umgangssprachlich dafür, bei jemandem das Interesse oder die sexuelle Anziehung zu zerstören.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Skeptisch", erklaerung: "Zweifelnd, misstrauisch oder nicht leicht zu überzeugen sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Buhen", erklaerung: "Durch laute 'Buh'-Rufe seine Missbilligung oder Ablehnung ausdrücken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Extrovertiert", erklaerung: "Nach außen gerichtet, gesellig und kontaktfreudig sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Drauflosreden", erklaerung: "Ohne viel nachzudenken oder Vorbereitung spontan zu reden beginnen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Philosophisch", erklaerung: "Sich mit tiefgründigen Fragen des Lebens, des Wissens und des Seins befassend.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Diktieren", erklaerung: "Jemandem einen Text zum Mitschreiben vorsprechen; auch jemandem seinen Willen aufzwingen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Glotzen", erklaerung: "Umgangssprachlich und oft abwertend für intensiv und unhöflich starren.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Akzent", erklaerung: "Die besondere Aussprache, die verrät, woher jemand kommt; auch eine bewusste Hervorhebung.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überwinden", erklaerung: "Ein Hindernis, eine Schwierigkeit oder eine Angst erfolgreich bewältigen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Krachen", erklaerung: "Ein lautes, brechendes Geräusch machen; auch umgangssprachlich für einen heftigen Streit.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Selbstbezogen", erklaerung: "Hauptsächlich auf sich selbst und die eigenen Bedürfnisse und Wünsche konzentriert sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Steg", erklaerung: "Ein schmaler, ins Wasser gebauter Weg aus Holz oder Metall, von dem aus man z.B. schwimmen oder in ein Boot steigen kann.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Konventionell", erklaerung: "Den üblichen gesellschaftlichen Regeln oder Traditionen entsprechend; herkömmlich.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bewältigen", erklaerung: "Eine schwierige Aufgabe, eine Herausforderung oder ein Problem erfolgreich meistern.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Materiell", erklaerung: "Sich auf greifbare Dinge oder Besitz beziehend, wie Geld oder Gegenstände.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Intuition", erklaerung: "Ein Gefühl oder Wissen, das man hat, ohne es logisch erklären zu können; Bauchgefühl.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Schnappschüsse", erklaerung: "Spontan und ohne große Vorbereitung aufgenommene Fotos.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Abwesend", erklaerung: "Nicht an einem Ort anwesend sein; auch gedanklich nicht bei der Sache sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Unterton", erklaerung: "Eine versteckte, nicht direkt ausgesprochene Stimmung oder Bedeutung in der Stimme.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Tonfall", erklaerung: "Die Art und Weise, wie die Stimme klingt und die Gefühle oder Absichten des Sprechers verrät.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Beharren", erklaerung: "Hartnäckig auf der eigenen Meinung oder Forderung bestehen und nicht nachgeben.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Zwar", erklaerung: "Leitet einen Gegensatz ein; wird oft in der Kombination 'zwar..., aber...' verwendet.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Verursachen", erklaerung: "Der Grund oder die Ursache für etwas sein.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Behutsam", erklaerung: "Vorsichtig, sanft und rücksichtsvoll.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Authentisch", erklaerung: "Echt, glaubwürdig und nicht gefälscht oder gespielt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Überwiegend", erklaerung: "Größtenteils, hauptsächlich oder zum größten Teil.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Derb", erklaerung: "Grob, unfein oder rau in der Art oder Sprache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .vulgaerDerb),
        Vokabel(wort: "Vulgär", erklaerung: "Unhöflich, geschmacklos oder auf eine anstößige Weise derb.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .vulgaerDerb),
        Vokabel(wort: "Dessen", erklaerung: "Ein Wort, das den Besitz für ein männliches oder sächliches Substantiv anzeigt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Sexyness", erklaerung: "Die Eigenschaft, sexuell attraktiv oder anziehend zu wirken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Klischee", erklaerung: "Eine übermäßig vereinfachte und oft falsche Vorstellung oder ein Vorurteil über eine Gruppe oder Sache.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Bischofsgewand", erklaerung: "Die zeremonielle Kleidung, die ein Bischof bei Gottesdiensten trägt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .hoeflich),
        Vokabel(wort: "Zerspringen", erklaerung: "Plötzlich und gewaltsam in viele Stücke zerbrechen.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Industrie", erklaerung: "Der Wirtschaftszweig, der Produkte in großem Maßstab in Fabriken herstellt.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Pechvogel", erklaerung: "Eine Person, die ständig Unglück oder Pech hat.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Alpenglühen", erklaerung: "Die rötliche Färbung der Berggipfel durch die auf- oder untergehende Sonne.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Einsetzen", erklaerung: "Etwas für einen bestimmten Zweck verwenden oder starten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Initiieren", erklaerung: "Etwas in die Wege leiten, den Anstoß zu etwas geben oder etwas starten.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich),
        Vokabel(wort: "Farbschema", erklaerung: "Eine Zusammenstellung von Farben, die in einem Design oder Kunstwerk harmonisch zusammenwirken.", kategorie: "Allgemein", videoURL: URL(string: "https://commondatestorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, gebrauch: .neutralUmgangssprachlich)
    ]

    private var preferredColorScheme: ColorScheme? {
        switch settingsManager.colorScheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    var body: some View {
        TabView {
            NavigationView { WelcomeView() }
                .tabItem { Label("Willkommen", systemImage: "house.fill") }

            NavigationView { CategoriesView(allVokabeln: allVokabeln) }
                .tabItem { Label("Gebärdenbuch", systemImage: "books.vertical.fill") }

            NavigationView { GlobalSearchView(allVokabeln: allVokabeln) }
                .tabItem { Label("Suchen", systemImage: "magnifyingglass") }

            NavigationView { FavoritesView() }
                .tabItem { Label("Merken", systemImage: "bookmark.fill") }

            NavigationView { SettingsView() }
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
        }
        .environmentObject(settingsManager)
        .environmentObject(FavoritesManager())
        .preferredColorScheme(preferredColorScheme)
    }
}

// MARK: - Splash View (Start Screen)
struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var opacity: Double = 0.0
    @Environment(\.colorScheme) var colorScheme

    // The background color of the logo
    private var primaryColor: Color {
        Color(hex: "#f2f0ea")
    }

    var body: some View {
        ZStack {
            // Background color that fills the screen.
            primaryColor.ignoresSafeArea()

            // Centered logo with fade-in animation
            Image("SplashScreenImage")
                .resizable()
                .scaledToFill()
                .opacity(opacity)

            // Transition timer
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    self.opacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.showSplash = false
                    }
                }
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme

    let welcomeVideoURL = Bundle.main.url(forResource: "Mein_Film", withExtension: "mp4")
    @State private var player: AVPlayer?

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : ThemeColors.background
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : ThemeColors.primaryText
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    Text("Willkommen in der Welt der Gebärdensprache!")
                        .font(.system(size: settings.textSize + 12, weight: .bold))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center).padding(.top, 20)

                    if let url = welcomeVideoURL {
                        VideoPlayer(player: player)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                            .onAppear {
                                if self.player == nil {
                                    self.player = AVPlayer(url: url)
                                    // Start playing the video
                                    self.player?.play()
                                    // Make the video loop endlessly
                                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
                                        self.player?.seek(to: CMTime.zero)
                                        self.player?.play()
                                    }
                                }
                            }
                            .onDisappear {
                                self.player?.pause()
                            }
                    } else {
                        Text("Das Begrüßungsvideo konnte nicht geladen werden.")
                            .foregroundColor(.red)
                            .font(.system(size: settings.textSize))
                            .padding()
                    }

                    Text("Mit transparenten 3D-Videos wird das Lernen der Gebärdensprache ganz einfach. Unser Ziel ist es, nicht nur die Gebärden, sondern auch die Bedeutung der Wörter zu erklären.")
                        .font(.system(size: settings.textSize))
                        .foregroundColor(colorScheme == .dark ? .gray : ThemeColors.secondaryText)
                        .multilineTextAlignment(.center).padding(.horizontal)

                    Text("Viel Spaß beim Lernen!")
                        .font(.system(size: settings.textSize - 2))
                        .foregroundColor(textColor)

                    Divider().padding(.horizontal)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Einblick in die Gehörlosenkultur")
                            .font(.system(size: settings.textSize + 8, weight: .bold))
                            .foregroundColor(textColor)
                            .padding(.bottom, 5).frame(maxWidth: .infinity, alignment: .center)

                        Text("Was ist Gehörlosenkultur?")
                            .font(.system(size: settings.textSize + 2, weight: .semibold))
                            .foregroundColor(textColor)

                        Text("Die Gehörlosenkultur ist die Kultur von Gemeinschaften gehörloser Menschen, die durch die Verwendung von Gebärdensprache und gemeinsame Erfahrungen geprägt ist. Sie umfasst eigene Werte, soziale Normen, Traditionen, Literatur und Kunst.")
                            .font(.system(size: settings.textSize))
                            .foregroundColor(colorScheme == .dark ? .gray : ThemeColors.secondaryText)

                        Text("Die Deutsche Gebärdensprache (DGS)")
                            .font(.system(size: settings.textSize + 2, weight: .semibold))
                            .foregroundColor(textColor).padding(.top)

                        Text("Die DGS ist eine eigenständige, visuelle Sprache mit einer komplexen Grammatik, die sich unabhängig von der deutschen Lautsprache entwickelt hat. Sie wurde erst im Jahr 2002 in Deutschland als vollwertige Sprache gesetzlich anerkannt.")
                            .font(.system(size: settings.textSize))
                            .foregroundColor(colorScheme == .dark ? .gray : ThemeColors.secondaryText)

                        Text("Tipps zur Kommunikation")
                            .font(.system(size: settings.textSize + 2, weight: .semibold))
                            .foregroundColor(textColor).padding(.top)

                        Text("1. Halte Blickkontakt.\n2. Sprich in normalem Tempo und deutlich, aber schreie nicht.\n3. Nutze natürliche Gestik und Mimik.\n4. Sei geduldig und wiederhole dich bei Bedarf.")
                            .font(.system(size: settings.textSize))
                            .foregroundColor(colorScheme == .dark ? .gray : ThemeColors.secondaryText)
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Startseite")
    }
}

// MARK: - Categories View
struct CategoriesView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let allVokabeln: [Vokabel]

    var kategorien: [String] {
        Array(Set(allVokabeln.map { $0.kategorie })).sorted()
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : ThemeColors.background
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : ThemeColors.primaryText
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 20)]
    }

    private func getCategoryIcon(for name: String) -> String {
        switch name {
        case "Allgemein": return "book.fill"
        case "Familie": return "person.3.fill"
        case "Lebensmittel": return "fork.knife.circle.fill"
        case "Fingeralphabet": return "hand.raised.fill"
        case "Zahlen": return "number.circle.fill"
        case "Redewendungen": return "message.badge.filled.fill"
        case "Alltagssätze": return "figure.walk.circle.fill" // New Icon for the new category
        default: return "books.vertical.fill"
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Text("Wähle eine Kategorie:")
                        .font(.system(size: settings.textSize + 8, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(kategorien, id: \.self) { kategorie in
                            NavigationLink(destination: CategoryDetailView(kategorie: kategorie, vokabeln: allVokabeln.filter { $0.kategorie == kategorie })) {
                                CategoryCardView(
                                    name: kategorie,
                                    iconName: getCategoryIcon(for: kategorie)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Kategorien")
    }
}

// MARK: - Component for the category tile view
struct CategoryCardView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme

    let name: String
    let iconName: String

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? ThemeColors.cardBackgroundDark : ThemeColors.cardBackground
    }

    private var iconColor: Color {
        colorScheme == .dark ? .yellow : ThemeColors.primaryText
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : ThemeColors.primaryText
    }

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(iconColor)

            Text(name)
                .font(.system(size: settings.textSize + 2, weight: .semibold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150)
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.07), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Global Search (GlobalSearchView)
struct GlobalSearchView: View {
    @EnvironmentObject var settings: SettingsManager
    let allVokabeln: [Vokabel]
    @State private var searchText = ""

    var filteredVokabeln: [Vokabel] {
        if searchText.isEmpty { return [] }
        else { return allVokabeln.filter { $0.wort.localizedCaseInsensitiveContains(searchText) }.sorted(by: { $0.wort < $1.wort }) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Suchen...", text: $searchText)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .font(.system(size: settings.textSize))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding([.horizontal, .top])

            List {
                if !filteredVokabeln.isEmpty {
                    ForEach(filteredVokabeln) { vokabel in
                        NavigationLink(destination: VokabelDetailView(vokabel: vokabel)) {
                            Text(vokabel.wort).font(.system(size: settings.textSize, weight: .semibold))
                        }
                    }
                } else if !searchText.isEmpty {
                    Text("Keine Ergebnisse gefunden.").foregroundColor(.secondary).font(.system(size: settings.textSize))
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Globale Suche")
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.editMode) var editMode

    var body: some View {
        VStack {
            if favoritesManager.favoriteVokabeln.isEmpty {
                Text("Du hast noch keine Wörter gemerkt.")
                    .font(.system(size: settings.textSize, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(favoritesManager.favoriteVokabeln.sorted(by: { $0.wort < $1.wort })) { vokabel in
                        NavigationLink(destination: VokabelDetailView(vokabel: vokabel)) {
                            Text(vokabel.wort).font(.system(size: settings.textSize, weight: .semibold))
                        }
                    }
                    .onDelete(perform: favoritesManager.removeFavorites)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Deine Merkliste")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !favoritesManager.favoriteVokabeln.isEmpty {
                    EditButton()
                        .environment(\.locale, Locale(identifier: "de"))
                }
            }
        }
    }
}

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    @Published var favoriteVokabeln: Set<Vokabel> = []
    private let favoritesKey = "favoriteVokabeln"

    init() { loadFavorites() }

    func isFavorite(_ vokabel: Vokabel) -> Bool { favoriteVokabeln.contains(vokabel) }

    func addFavorite(_ vokabel: Vokabel) {
        objectWillChange.send()
        favoriteVokabeln.insert(vokabel)
        saveFavorites()
    }

    func removeFavorite(_ vokabel: Vokabel) {
        objectWillChange.send()
        favoriteVokabeln.remove(vokabel)
        saveFavorites()
    }

    func removeFavorites(at offsets: IndexSet) {
        let sortedFavorites = favoriteVokabeln.sorted { $0.wort < $1.wort }
        offsets.forEach { index in
            let vokabel = sortedFavorites[index]
            favoriteVokabeln.remove(vokabel)
        }
        saveFavorites()
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoriteVokabeln)) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Vokabel].self, from: data) {
            favoriteVokabeln = Set(decoded)
        }
    }

    func exportFavorites() {
        guard let data = try? JSONEncoder().encode(Array(self.favoriteVokabeln)) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Merken.json")
        do {
            try data.write(to: tempURL)
            share(url: tempURL)
        } catch {
            print("Error writing favorites file: \(error)")
        }
    }

    func importFavorites(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let importedArray = try JSONDecoder().decode([Vokabel].self, from: data)
            self.favoriteVokabeln.formUnion(importedArray)
            saveFavorites()
        } catch {
            print("Error importing favorites: \(error)")
        }
    }

    private func share(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .keyWindow?
            .rootViewController?
            .present(activityVC, animated: true, completion: nil)
    }
}

// MARK: - DocumentPicker
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    @EnvironmentObject var settings: SettingsManager
    let kategorie: String
    let vokabeln: [Vokabel]
    @State private var searchText = ""

    let fingeralphabetOrder = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", "ß", "SCH"]

    let zahlenOrder = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "30", "40", "50", "60", "70", "80", "90", "100", "101", "105", "106", "110", "1000", "2000", "3000", "10.000", "20.000", "60.000", "100.000", "500.000", "1 Million", "1 Milliarden", "1 Billionen", "1980", "2025", "90er", "2000er", "60er"]

    var filteredVokabeln: [Vokabel] {
        let filtered = searchText.isEmpty ? vokabeln : vokabeln.filter { $0.wort.localizedCaseInsensitiveContains(searchText) }

        if kategorie == "Fingeralphabe" {
            return filtered.sorted { (vokabel1, vokabel2) -> Bool in
                guard let index1 = fingeralphabetOrder.firstIndex(of: vokabel1.wort),
                      let index2 = fingeralphabetOrder.firstIndex(of: vokabel2.wort) else {
                    return false
                }
                return index1 < index2
            }
        } else if kategorie == "Zahlen" {
            return filtered.sorted { (vokabel1, vokabel2) -> Bool in
                guard let index1 = zahlenOrder.firstIndex(of: vokabel1.wort),
                      let index2 = zahlenOrder.firstIndex(of: vokabel2.wort) else {
                    return vokabel1.wort < vokabel2.wort
                }
                return index1 < index2
            }
        } else {
            return filtered.sorted(by: { $0.wort < $1.wort })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Suchen in \(kategorie)...", text: $searchText)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .font(.system(size: settings.textSize))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding([.horizontal, .top])

            List {
                ForEach(filteredVokabeln) { vokabel in
                    NavigationLink(destination: VokabelDetailView(vokabel: vokabel)) {
                        Text(vokabel.wort).font(.system(size: settings.textSize, weight: .semibold))
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(kategorie)
    }
}

// MARK: - Detail View (VokabelDetailView) - NEW DESIGN
struct VokabelDetailView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var favoritesManager: FavoritesManager

    let vokabel: Vokabel

    @State private var player: AVPlayer?
    @State private var player2: AVPlayer?
    @State private var playbackRate: Float = 1.0
    @State private var zeigeGebrauchInfo = false
    @State private var animateFavorite: Bool = false
    @State private var showSpeedMenu = false
    @State private var isShowingGebarde = true // Default to showing the Gebärde video first

    // --- Computed Properties for design ---
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : ThemeColors.background
    }
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : ThemeColors.primaryText
    }
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : ThemeColors.secondaryText
    }

    // Logic to decide which video to show
    private var showGebardeVideo: Bool {
        let onlyExplanationCategories = ["Redewendungen", "Alltagssätze"]
        return !onlyExplanationCategories.contains(vokabel.kategorie)
    }

    private var showErklaerungVideo: Bool {
        let onlyGebardeCategories = ["Lebensmittel", "Fingeralphabet", "Zahlen"]
        return !onlyGebardeCategories.contains(vokabel.kategorie)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // --- Header: Wort & Erklärung ---
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vokabel.wort)
                                .font(.system(size: settings.textSize + 18, weight: .bold))
                                .foregroundColor(primaryTextColor)
                            Text(vokabel.erklaerung)
                                .font(.system(size: settings.textSize))
                                .foregroundColor(secondaryTextColor)
                        }
                        .padding(.horizontal)

                        // --- Video Card with switch buttons ---
                        VStack(alignment: .leading, spacing: 8) {
                             // Switch for video
                            if showGebardeVideo && showErklaerungVideo {
                                HStack(spacing: 0) {
                                    Button(action: { toggleVideo(showGebarde: true) }) {
                                        Text("Gebärdenwort")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .foregroundColor(isShowingGebarde ? .white : primaryTextColor)
                                            .background(isShowingGebarde ? Color.blue : Color.clear)
                                            .cornerRadius(20)
                                    }
                                    .padding(.trailing, 8)

                                    Button(action: { toggleVideo(showGebarde: false) }) {
                                        Text("Erklärung mit DGS")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .foregroundColor(!isShowingGebarde ? .white : primaryTextColor)
                                            .background(!isShowingGebarde ? Color.blue : Color.clear)
                                            .cornerRadius(20)
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(8)
                                .background(Color.primary.opacity(0.1))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            }

                             // Video Player
                            ZStack {
                                if showGebardeVideo && isShowingGebarde {
                                     VideoPlayer(player: player)
                                } else if showErklaerungVideo {
                                    VideoPlayer(player: player2)
                                } else {
                                     Text("No video available.")
                                         .foregroundColor(.red)
                                }
                            }
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }

                        // --- Usage Hint ---
                        if let gebrauch = vokabel.gebrauch {
                            gebrauchInfoView(gebrauch: gebrauch)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }

                // --- Action Buttons at the bottom ---
                HStack(spacing: 16) {
                    ActionButtonView(
                        iconName: "gauge.medium",
                        label: "Tempo",
                        settings: settings,
                        action: { showSpeedMenu = true }
                    )

                    ActionButtonView(
                        iconName: favoritesManager.isFavorite(vokabel) ? "bookmark.fill" : "bookmark",
                        label: "Merken",
                        settings: settings,
                        color: .blue,
                        scale: animateFavorite ? 1.2 : 1.0,
                        action: toggleFavorite
                    )
                }
                .padding()
                .background(backgroundColor.edgesIgnoringSafeArea(.bottom))
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: "Lerne die Gebärde für '\(vokabel.wort)' in der Gebärdenbuch App!") {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(primaryTextColor)
                }
            }
        }
        .onAppear {
            setupPlayers()
            // Start playing the videos initially
            // The videos will play at the current playbackRate, which is 1.0 by default
            player?.play()
            player2?.play()
        }
        .onDisappear(perform: pausePlayers)
        .onChange(of: playbackRate, initial: false) { oldRate, newRate in
            // Update the rate of both players when the playbackRate state changes
            updatePlayerRates(newRate: newRate)
        }
        .actionSheet(isPresented: $showSpeedMenu) {
            ActionSheet(title: Text("Geschwindigkeit wählen"), buttons: [
                .default(Text("Langsam (0.5x)")) { playbackRate = 0.5 },
                .default(Text("Normal (1.0x)")) { playbackRate = 1.0 },
                .default(Text("Schnell (1.5x)")) { playbackRate = 1.5 },
                .cancel()
            ])
        }
        .alert(isPresented: $zeigeGebrauchInfo) {
            Alert(
                title: Text(vokabel.gebrauch?.anzeigeText ?? "Info"),
                message: Text(vokabel.gebrauch?.detailErklaerung ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // --- Helper functions ---
    private func setupPlayers() {
        if showGebardeVideo && player == nil {
            let videoUrl = vokabel.wort == "Hallo" ? Bundle.main.url(forResource: "Hallo_Gebärde", withExtension: "mp4")! : vokabel.videoURL
            player = AVPlayer(url: videoUrl)
            // Loop the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                player?.seek(to: CMTime.zero)
                player?.play()
                // Ensure the playback rate is maintained after a loop.
                player?.rate = playbackRate
            }
            player?.rate = playbackRate
        }
        if showErklaerungVideo && player2 == nil {
            let videoUrl = vokabel.wort == "Hallo" ? Bundle.main.url(forResource: "Hallo_Erklärung", withExtension: "mp4")! : vokabel.videoURL
            player2 = AVPlayer(url: videoUrl)
            // Loop the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player2?.currentItem, queue: .main) { _ in
                player2?.seek(to: CMTime.zero)
                player2?.play()
                // Ensure the playback rate is maintained after a loop.
                player2?.rate = playbackRate
            }
            player2?.rate = playbackRate
        }
    }

    private func pausePlayers() {
        player?.pause()
        player2?.pause()
    }

    // Neue Funktion, um Videos zu starten/pausieren
    private func toggleVideo(showGebarde: Bool) {
        isShowingGebarde = showGebarde
        if showGebarde {
            player2?.pause()
            player?.seek(to: .zero)
            player?.play()
        } else {
            player?.pause()
            player2?.seek(to: .zero)
            player2?.play()
        }
        // Update the rate after toggling
        updatePlayerRates(newRate: playbackRate)
    }

    private func updatePlayerRates(newRate: Float) {
        player?.rate = newRate
        player2?.rate = newRate
    }

    private func toggleFavorite() {
        if favoritesManager.isFavorite(vokabel) {
            favoritesManager.removeFavorite(vokabel)
        } else {
            favoritesManager.addFavorite(vokabel)
            triggerHapticFeedback(style: .light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                animateFavorite = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { animateFavorite = false }
            }
        }
    }

    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    // --- Subview for the usage hint ---
    @ViewBuilder
    private func gebrauchInfoView(gebrauch: Gebrauch) -> some View {
        HStack {
            Text("Gebrauch: \(gebrauch.anzeigeText)")
                .foregroundColor(secondaryTextColor)
            Button {
                zeigeGebrauchInfo = true
            } label: {
                Image(systemName: "info.circle.fill").foregroundColor(secondaryTextColor)
            }
        }
        .font(.system(size: settings.textSize - 2))
        .padding(8)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Reusable Video Card
// Note: This component is no longer used in the new design but is kept for reference.
struct VideoCardView: View {
    @Binding var player: AVPlayer?
    let title: String
    @ObservedObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let videoURL: URL

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? ThemeColors.cardBackgroundDark : ThemeColors.cardBackground
    }
    private var placeholderColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: settings.textSize - 2, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                } else {
                    placeholderColor
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .cornerRadius(12)
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Reusable Action Button
struct ActionButtonView: View {
    let iconName: String
    let label: String
    @ObservedObject var settings: SettingsManager
    var color: Color = .primary
    var scale: CGFloat = 1.0
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    private var backgroundColor: Color {
        colorScheme == .dark ? ThemeColors.actionButtonBackgroundDark : ThemeColors.actionButtonBackground
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : color)

                Text(label)
                    .font(.system(size: settings.textSize - 4, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(backgroundColor)
            .cornerRadius(16)
            .scaleEffect(scale)
        }
    }
}


// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showDocumentPicker = false

    var body: some View {
        Form {
            Section(header: Text("Erscheinungsbild")) {
                Picker("Modus", selection: $settings.colorScheme) {
                    ForEach(AppColorScheme.allCases) { scheme in
                        Text(scheme.displayName).tag(scheme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Textgröße")) {
                HStack {
                    Text("Aa").font(.system(size: 12))
                    Slider(value: $settings.textSize, in: 12...30, step: 1)
                    Text("Aa").font(.system(size: 30))
                }
                HStack {
                    Spacer()
                    Text("Aktuelle Größe: \(Int(settings.textSize))")
                        .font(.system(size: settings.textSize))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            Section(header: Text("Merken-Verwaltung")) {
                Button(action: { favoritesManager.exportFavorites() }) {
                    Label("Merken exportieren", systemImage: "tray.and.arrow.up")
                }
                Button(action: { showDocumentPicker = true }) {
                    Label("Merken importieren", systemImage: "tray.and.arrow.down")
                }
            }
        }
        .navigationTitle("Einstellungen")
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                favoritesManager.importFavorites(from: url)
            }
        }
    }
}


// MARK: - Preview (for preview in Xcode)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Erstelle Instanzen der Manager, die in der Vorschau benötigt werden
        let settingsManager = SettingsManager()
        let favoritesManager = FavoritesManager()

        // Füge die Manager der Vorschau-Umgebung hinzu
        ContentView()
            .environmentObject(settingsManager)
            .environmentObject(favoritesManager)
    }
}


// MARK: - Helper extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
