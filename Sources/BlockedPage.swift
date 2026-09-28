import Foundation

/// A local HTML page that blocked tabs are redirected to. It shows a random fact.
enum BlockedPage {
    static let fileURL: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("FocusShield/blocked.html")
    }()

    static func url(for site: String) -> URL {
        var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "site", value: site)]
        return components.url!
    }

    static func install() {
        let data = (try? JSONEncoder().encode(FactLibrary.all)) ?? Data("[]".utf8)
        let json = String(decoding: data, as: UTF8.self).replacingOccurrences(of: "</", with: "<\\/")
        let html = template.replacingOccurrences(of: "__FACTS__", with: json)
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? html.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private static let template = """
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Focus Shield is on</title>
    <style>
      :root { color-scheme: dark; }
      * { box-sizing: border-box; margin: 0; }
      body {
        min-height: 100vh; display: grid; place-items: center; padding: 32px 16px;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
        color: #f5f3ff; background: #0b0a1a; overflow-x: hidden;
      }
      .glow { position: fixed; border-radius: 50%; filter: blur(90px); opacity: .55; z-index: 0; }
      .g1 { width: 520px; height: 520px; background: #6d28d9; top: -140px; left: -120px; animation: drift 18s ease-in-out infinite alternate; }
      .g2 { width: 460px; height: 460px; background: #0ea5e9; bottom: -160px; right: -100px; animation: drift 22s ease-in-out infinite alternate-reverse; }
      @keyframes drift { to { transform: translate(60px, 40px) scale(1.1); } }
      main { position: relative; z-index: 1; max-width: 640px; text-align: center; animation: rise .8s ease-out both; }
      @keyframes rise { from { opacity: 0; transform: translateY(16px); } }
      .badge { display: inline-flex; gap: 8px; align-items: center; padding: 8px 16px; border-radius: 999px;
               background: rgba(255,255,255,.08); border: 1px solid rgba(255,255,255,.14);
               font-size: 13px; letter-spacing: .08em; text-transform: uppercase; }
      h1 { margin-top: 24px; font-size: clamp(28px, 5vw, 44px); font-weight: 700; letter-spacing: -.02em; }
      .sub { margin-top: 10px; color: #c4c1e0; font-size: 17px; }
      .card { margin-top: 40px; padding: 32px; border-radius: 24px; text-align: left;
              background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.12);
              backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); }
      .card h2 { font-family: "New York", ui-serif, Georgia, serif; font-size: 28px; font-weight: 600; line-height: 1.2; }
      .card p { margin-top: 14px; font-size: 17px; line-height: 1.6; color: #e4e2f5; }
      .card cite { display: block; margin-top: 18px; font-size: 14px; color: #a5a1c9; font-style: italic; }
      .hint { margin-top: 28px; font-size: 13px; color: #8f8bb5; }
      button { margin-top: 18px; background: none; border: 1px solid rgba(255,255,255,.2); color: #e4e2f5;
               padding: 10px 18px; border-radius: 999px; font: inherit; font-size: 14px; cursor: pointer; }
      button:hover { background: rgba(255,255,255,.08); }
    </style>
    </head>
    <body>
    <div class="glow g1"></div><div class="glow g2"></div>
    <main>
      <div class="badge">🛡️ Focus Shield is on</div>
      <h1 id="title">This site is blocked</h1>
      <p class="sub">Your attention is worth more than the feed.</p>
      <div class="card">
        <h2 id="headline"></h2>
        <p id="body"></p>
        <cite id="source"></cite>
      </div>
      <button id="next">Another thought →</button>
      <p class="hint">To pause the shield, use the shield icon in your menu bar.</p>
    </main>
    <script>
      const facts = __FACTS__;
      const site = new URLSearchParams(location.search).get("site");
      if (site) document.getElementById("title").textContent = site + " is blocked";
      let i = Math.floor(Math.random() * facts.length);
      function show() {
        const f = facts[i % facts.length];
        document.getElementById("headline").textContent = f.headline;
        document.getElementById("body").textContent = f.body;
        document.getElementById("source").textContent = "— " + f.source;
      }
      document.getElementById("next").onclick = () => { i++; show(); };
      show();
    </script>
    </body>
    </html>
    """
}
