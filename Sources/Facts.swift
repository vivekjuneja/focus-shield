import Foundation

struct Fact: Codable, Identifiable {
    let id: String
    let icon: String      // SF Symbol name
    let headline: String
    let body: String
    let source: String
}

enum FactLibrary {
    static let all: [Fact] = [
        Fact(id: "mark-47s", icon: "timer",
             headline: "47 seconds",
             body: "That's how long the average person now focuses on a single screen before switching to something else. In 2004 it was about two and a half minutes.",
             source: "Gloria Mark — Attention Span (2023)"),
        Fact(id: "mark-23m", icon: "arrow.uturn.backward.circle",
             headline: "23 minutes",
             body: "After an interruption, it takes on average more than 23 minutes to get fully back to the original task. A \"quick check\" costs far more than the check itself.",
             source: "Gloria Mark — research on workplace interruptions, UC Irvine"),
        Fact(id: "mark-self", icon: "person.fill.questionmark",
             headline: "You are the interruption",
             body: "Gloria Mark found that we interrupt ourselves nearly as often as other people interrupt us. The urge to \"just check\" is a habit — and habits can be retrained.",
             source: "Gloria Mark — Attention Span (2023)"),
        Fact(id: "haidt-rewiring", icon: "arrow.triangle.2.circlepath",
             headline: "The Great Rewiring",
             body: "Between 2010 and 2015, childhood shifted from play-based to phone-based. Jonathan Haidt argues this rewiring changed how an entire generation sleeps, connects and pays attention.",
             source: "Jonathan Haidt — The Anxious Generation (2024)"),
        Fact(id: "haidt-harms", icon: "square.grid.2x2",
             headline: "Four foundational harms",
             body: "Haidt names four core harms of the phone-based life: social deprivation, sleep deprivation, attention fragmentation, and addiction. You're about to invite in the third one.",
             source: "Jonathan Haidt — The Anxious Generation (2024)"),
        Fact(id: "haidt-fragment", icon: "square.split.2x2",
             headline: "Attention fragmentation",
             body: "Haidt describes how an endless stream of feeds and notifications makes it harder to stay with any one line of thought — for adults as much as for teens. Every glance splinters focus a little more.",
             source: "Jonathan Haidt — The Anxious Generation (2024)"),
        Fact(id: "haidt-opportunity", icon: "hourglass",
             headline: "The opportunity cost",
             body: "Haidt's deepest warning isn't only about what screens do — it's about what they displace: sleep, friendship, play, reading, deep thought. What will this next hour replace?",
             source: "Jonathan Haidt — The Anxious Generation (2024)"),
        Fact(id: "haidt-sleep", icon: "moon.zzz",
             headline: "Screens steal sleep",
             body: "Haidt shows how evening screen time crowds out sleep — and sleep is when the brain consolidates memory and restores its capacity to focus. Tomorrow's attention is decided tonight.",
             source: "Jonathan Haidt — The Anxious Generation (2024)"),
        Fact(id: "instagram-one-in-three", icon: "camera",
             headline: "\"We make body image issues worse for one in three teen girls.\"",
             body: "That line came from Instagram's own internal research, revealed in 2021. The company knew. Haidt uses findings like this to show that the harm is not an accident of misuse but a feature of the design.",
             source: "The Wall Street Journal, \"The Facebook Files\" (2021), cited in The Anxious Generation"),
        Fact(id: "hari-65", icon: "stopwatch",
             headline: "65 seconds",
             body: "A study Johann Hari cites found that college students stayed on a single task for an average of just 65 seconds. Office workers managed about three minutes.",
             source: "Johann Hari — Stolen Focus (2022)"),
        Fact(id: "hari-stolen", icon: "hand.raised.slash",
             headline: "Your focus was stolen",
             body: "Hari argues the attention crisis isn't a personal failing — it's the product of technology deliberately designed to capture and hold your eyes. Blocking it isn't weakness. It's self-defense.",
             source: "Johann Hari — Stolen Focus (2022)"),
        Fact(id: "hari-switch", icon: "arrow.left.arrow.right",
             headline: "The switch-cost effect",
             body: "MIT neuroscientist Earl Miller told Hari the brain can consciously hold only one or two thoughts at once. \"Multitasking\" is really rapid switching — and every switch taxes your performance.",
             source: "Johann Hari — Stolen Focus (2022)"),
        Fact(id: "newport-residue", icon: "drop.triangle",
             headline: "Attention residue",
             body: "When you switch tasks, part of your attention stays stuck on the previous one. Researcher Sophie Leroy showed this residue measurably degrades whatever you do next.",
             source: "Cal Newport — Deep Work (2016)"),
        Fact(id: "newport-rare", icon: "diamond",
             headline: "Rare and valuable",
             body: "The ability to do deep work is becoming increasingly rare at exactly the moment it is becoming increasingly valuable. Those who cultivate it will thrive.",
             source: "Cal Newport — Deep Work (2016)"),
        Fact(id: "newport-minimalism", icon: "circle.dashed",
             headline: "Less, but better",
             body: "Digital minimalists spend their online time on a few carefully chosen activities that strongly support what they value — and happily miss out on everything else.",
             source: "Cal Newport — Digital Minimalism (2019)"),
        Fact(id: "wu-1833", icon: "newspaper",
             headline: "Since 1833",
             body: "The attention business began when the New York Sun sold for a penny and made its money selling readers' attention to advertisers. Every free feed runs on the same model — you are what's being sold.",
             source: "Tim Wu — The Attention Merchants (2016)"),
        Fact(id: "simon", icon: "books.vertical",
             headline: "A poverty of attention",
             body: "\"A wealth of information creates a poverty of attention.\" Herbert Simon wrote that in 1971 — decades before the infinite scroll.",
             source: "Herbert A. Simon, Nobel laureate in economics (1971)"),
        Fact(id: "zuboff", icon: "eye",
             headline: "You are the raw material",
             body: "Shoshana Zuboff shows how platforms treat your clicks, pauses and scrolls as raw material — turned into predictions about what you'll do next, and sold.",
             source: "Shoshana Zuboff — The Age of Surveillance Capitalism (2019)"),
        Fact(id: "eyal-variable", icon: "dice",
             headline: "A slot machine in your pocket",
             body: "Feeds run on \"variable rewards\" — you never know what the next scroll will bring. It's the same unpredictable reward schedule that makes slot machines so hard to walk away from.",
             source: "Nir Eyal — Hooked (2014)"),
        Fact(id: "eyal-escape", icon: "figure.walk.departure",
             headline: "Distraction is an escape",
             body: "Nir Eyal argues most distraction starts inside us — an attempt to escape discomfort like boredom, anxiety or uncertainty. What feeling are you trying to escape right now?",
             source: "Nir Eyal — Indistractable (2019)"),
        Fact(id: "alter-stopping", icon: "stop.circle",
             headline: "No stopping cues",
             body: "Older media had natural endings — the last page, the end of an episode. Autoplay and endless feeds remove those stopping cues, so the decision to stop falls entirely on you.",
             source: "Adam Alter — Irresistible (2017)"),
        Fact(id: "hastings-sleep", icon: "bed.double",
             headline: "\"We're competing with sleep.\"",
             body: "Netflix's CEO said in 2017 that the company's real competition isn't just other streamers — it's your sleep. Your rest is literally a business rival.",
             source: "Reed Hastings, Netflix (2017)"),
        Fact(id: "youtube-70", icon: "play.rectangle.on.rectangle",
             headline: "70% of watch time",
             body: "YouTube's chief product officer said that more than 70% of time spent watching YouTube is driven by its recommendation algorithm. You rarely choose the next video — it chooses you.",
             source: "Neal Mohan, YouTube (CES 2018)"),
        Fact(id: "harris-brainstem", icon: "brain.head.profile",
             headline: "Race to the bottom of the brain stem",
             body: "Former Google design ethicist Tristan Harris describes an arms race among apps to trigger our most primitive impulses — outrage, fear, novelty — because that's what keeps us scrolling.",
             source: "Tristan Harris — Center for Humane Technology"),
        Fact(id: "carr-jetski", icon: "water.waves",
             headline: "From scuba diver to Jet Ski",
             body: "\"Once I was a scuba diver in the sea of words. Now I zip along the surface like a guy on a Jet Ski.\" Nicholas Carr on how the internet reshaped his ability to read deeply.",
             source: "Nicholas Carr — The Shallows (2010)"),
        Fact(id: "ward-braindrain", icon: "iphone.slash",
             headline: "Brain drain",
             body: "In a 2017 study, simply having a smartphone on the desk — even face-down and silent — reduced people's available working memory and fluid intelligence.",
             source: "Ward et al., Journal of the Association for Consumer Research (2017)"),
        Fact(id: "lembke", icon: "scalemass",
             headline: "The pleasure–pain balance",
             body: "Psychiatrist Anna Lembke explains that the brain offsets every hit of easy pleasure with a pull toward pain. The more we chase quick dopamine, the flatter everything else feels.",
             source: "Anna Lembke — Dopamine Nation (2021)"),
        Fact(id: "burkeman", icon: "calendar",
             headline: "About 4,000 weeks",
             body: "Live to eighty and you get roughly four thousand weeks. Oliver Burkeman argues that what you pay attention to, moment by moment, is what your life ends up being.",
             source: "Oliver Burkeman — Four Thousand Weeks (2021)"),
        Fact(id: "james", icon: "quote.opening",
             headline: "\"My experience is what I agree to attend to.\"",
             body: "William James wrote this in 1890. What you choose to look at for the next hour quite literally becomes part of your life.",
             source: "William James — The Principles of Psychology (1890)"),
        Fact(id: "weil", icon: "heart",
             headline: "The rarest form of generosity",
             body: "\"Attention is the rarest and purest form of generosity,\" wrote Simone Weil. Who in your life deserves the attention you're about to give a feed?",
             source: "Simone Weil, letter to Joë Bousquet (1942)"),
        Fact(id: "flow", icon: "wind",
             headline: "Happiness lives in flow",
             body: "Mihaly Csikszentmihalyi found people are happiest not when relaxing passively, but when fully absorbed in something challenging. The best moments of life are usually ones we create through focus.",
             source: "Mihaly Csikszentmihalyi — Flow (1990)"),
        Fact(id: "postman", icon: "tv",
             headline: "Amusing ourselves to death",
             body: "Neil Postman warned that the danger wasn't being deprived of information, but being entertained into distraction. As Huxley feared: what we love will ruin us.",
             source: "Neil Postman — Amusing Ourselves to Death (1985)"),
        Fact(id: "odell", icon: "leaf",
             headline: "Attention as resistance",
             body: "Jenny Odell argues the attention economy profits from keeping us restless. Choosing where your attention goes — and refusing to hand it over — is a quiet act of resistance.",
             source: "Jenny Odell — How to Do Nothing (2019)"),
    ]

    private static let seenKey = "seenFactIDs"

    /// Picks `count` facts that haven't been shown recently. Cycles through the whole
    /// library before any fact repeats.
    static func pickUnique(_ count: Int = 3) -> [Fact] {
        let defaults = UserDefaults.standard
        var seen = Set(defaults.stringArray(forKey: seenKey) ?? [])
        var pool = all.filter { !seen.contains($0.id) }
        if pool.count < count {
            seen.removeAll()
            pool = all
        }
        let picked = Array(pool.shuffled().prefix(count))
        seen.formUnion(picked.map(\.id))
        defaults.set(Array(seen), forKey: seenKey)
        return picked
    }
}
