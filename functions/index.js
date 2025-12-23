const { onRequest } = require("firebase-functions/v2/https");
const fetch = require("node-fetch");

exports.extractResumeData = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 120,
    cors: true,
  },
  async (req, res) => {
    try {
      console.log("📥 Request received");

      const resumeText = req.body.resumeText;

      if (!resumeText || resumeText.length < 100) {
        return res.status(400).json({
          error: "Invalid resume text",
        });
      }

      const GROQ_API_KEY = process.env.GROQ_API_KEY;
      if (!GROQ_API_KEY) {
        return res.status(500).json({
          error: "Missing GROQ_API_KEY",
        });
      }

      console.log("🚀 Calling Groq API");

      const groqResponse = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${GROQ_API_KEY}`,
          },
          body: JSON.stringify({
            model: "llama-3.1-8b-instant",
            temperature: 0.35,
            messages: [
              {
                role: "system",
                content: `
You are a senior mobile UI engineer.

You generate MOBILE-ONLY portfolio websites.

ABSOLUTE RULES (DO NOT BREAK):
- Return ONLY valid HTML
- NO markdown
- NO \`\`\`
- NO explanations
- Mobile-first ONLY
- Max width: 420px
- Center layout horizontally
- Use flexbox only
- NO absolute positioning
- NO fixed heights
- Use <style> for CSS
- Clean spacing, elegant colors
- Smooth CSS animations (fade / slide)
`,
              },
              {
                role: "user",
                content: `
Generate a clean, elegant, MOBILE-ONLY personal portfolio website.

HTML STRUCTURE (MUST FOLLOW EXACTLY):

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Portfolio</title>

<style>
:root {
  --primary: #6A11CB;
  --background: #f6f7fb;
  --card: #ffffff;
  --text: #222;
  --muted: #666;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  background: var(--background);
  color: var(--text);
  display: flex;
  justify-content: center;
}

.app {
  width: 100%;
  max-width: 420px;
}

.hero {
  padding: 32px 24px;
  background: linear-gradient(135deg, #6A11CB, #2575FC);
  color: white;
  text-align: center;
}

.hero h1 {
  margin: 0;
  font-size: 26px;
}

.hero p {
  margin-top: 8px;
  opacity: 0.9;
}

.content {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.card {
  background: var(--card);
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.06);
  animation: fadeUp 0.6s ease forwards;
}

.card h2 {
  margin-top: 0;
  font-size: 18px;
}

.card p, .card li {
  color: var(--muted);
  font-size: 14px;
  line-height: 1.6;
}

ul {
  padding-left: 18px;
}

@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
</head>

<body>
<div class="app">
  <header class="hero"></header>

  <main class="content">
    <section class="card about"></section>
    <section class="card skills"></section>
    <section class="card experience"></section>
    <section class="card projects"></section>
    <section class="card education"></section>
    <section class="card contact"></section>
  </main>
</div>
</body>
</html>

CONTENT RULES:
- Fill each section using resume data
- Keep text concise
- Do NOT overflow cards
- Maintain clean spacing
- Looks premium on MOBILE

Resume Content:
${resumeText}
`,
              },
            ],
          }),
        }
      );

      const data = await groqResponse.json();
      let rawHtml = data?.choices?.[0]?.message?.content || "";

      console.log("🧹 Cleaning AI response");

      const cleanedHtml = rawHtml
        .replace(/```html/gi, "")
        .replace(/```/g, "")
        .trim();

      if (!cleanedHtml.startsWith("<!DOCTYPE html")) {
        console.error("❌ Invalid HTML received");
        return res.status(500).json({
          error: "AI did not return valid HTML",
          raw: rawHtml,
        });
      }

      console.log("✅ HTML generated successfully");

      return res.status(200).json({
        html: cleanedHtml,
      });
    } catch (err) {
      console.error("🔥 Function error:", err);
      return res.status(500).json({
        error: err.message,
      });
    }
  }
);
