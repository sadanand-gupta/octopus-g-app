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
      const resumeText = req.body.resumeText;
      const primaryColor = req.body.primaryColor || "#1F5EFF";
      const accentColor = req.body.accentColor || "#3B82F6";
      const darkColor = req.body.darkColor || "#0F172A";

      if (!resumeText || resumeText.length < 100) {
        return res.status(400).json({ error: "Invalid resume text" });
      }

      const GROQ_API_KEY = process.env.GROQ_API_KEY;
      if (!GROQ_API_KEY) {
        return res.status(500).json({ error: "Missing GROQ_API_KEY" });
      }

      const response = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${GROQ_API_KEY}`,
          },
          body: JSON.stringify({
            model: "llama-3.1-8b-instant",
            temperature: 0.2,
            max_tokens: 5000,
            messages: [
              {
                role: "system",
                content: `
You are a senior UI engineer.
You ONLY output clean, valid, production-ready HTML.

ABSOLUTE RULES:
- Single HTML file only
- Inline <style> only
- No JS
- No external assets
- No markdown
- No comments
- Mobile-first
- WebView safe
- Minimal, professional, premium SaaS design
                `,
              },
              {
                role: "user",
                content: `
Generate a SINGLE premium HTML portfolio website.

OUTPUT FORMAT (STRICT):
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Portfolio</title>
<style>ALL CSS HERE</style>
</head>
<body>
<div class="container">CONTENT</div>
</body>
</html>

COLOR PALETTE (USE THESE EXACT COLORS):
- Primary: ${primaryColor}
- Accent: ${accentColor}
- Dark (hero/footer bg): ${darkColor}
- Text dark: #1E293B
- Text muted: #64748B
- Light bg: #F8FAFC
- White: #FFFFFF
- Border: #E5E7EB

DESIGN SYSTEM:
- Max width: 420px
- Border radius: 14px
- Shadow: 0 8px 24px rgba(0,0,0,0.06)

TYPOGRAPHY:
- Font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
- Name: 26px bold
- Section title: 13px uppercase, letter-spacing
- Card title: 16px semibold
- Body text: 14px
- Meta text: 12px

LAYOUT RULES:
- Every section inside a card
- Clear spacing (24px)
- No long paragraphs
- Max 4 bullets per job
- Skills as pills with primary color
- Clean vertical rhythm

SECTIONS:
1. Hero (dark bg with ${darkColor}, name in white, role in muted)
2. About (summary with left border in ${primaryColor})
3. Experience (cards with ${primaryColor} accents)
4. Skills (pills with ${primaryColor} background at 10% opacity)
5. Education
6. Projects
7. Contact (dark bg matching hero)
8. Footer (dark, "Built with Octopus G")

BASE CSS (must include):
*{box-sizing:border-box;margin:0;padding:0}
body{
  font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
  background:#F8FAFC;
  color:#1E293B;
}
.container{
  max-width:420px;
  margin:0 auto;
  padding:0;
}
.hero{
  background:${darkColor};
  padding:48px 24px;
  text-align:center;
}
.hero h1{color:#FFFFFF;font-size:26px;font-weight:700;}
.hero p{color:#94A3B8;font-size:14px;margin-top:8px;}
.section{padding:24px;}
.card{
  background:#FFFFFF;
  border:1px solid #E5E7EB;
  border-radius:14px;
  padding:20px;
  margin-bottom:16px;
  box-shadow:0 8px 24px rgba(0,0,0,0.06);
}
.section-title{
  font-size:12px;
  letter-spacing:1.5px;
  color:#64748B;
  font-weight:600;
  margin-bottom:16px;
  text-transform:uppercase;
}
.skill-tag{
  display:inline-block;
  background:${primaryColor}15;
  color:${primaryColor};
  padding:8px 14px;
  border-radius:20px;
  font-size:13px;
  font-weight:500;
  margin:4px;
}
.footer{
  background:${darkColor};
  padding:24px;
  text-align:center;
}
.footer p{color:#64748B;font-size:12px;}

RESUME DATA:
${resumeText}

IMPORTANT:
- Use the exact colors provided
- Rewrite content for readability
- Remove repetition
- Make it look like a real SaaS product site
- Output ONLY HTML
                `,
              },
            ],
          }),
        }
      );

      const data = await response.json();
      let html = data?.choices?.[0]?.message?.content || "";

      html = html
        .replace(/```html/gi, "")
        .replace(/```/g, "")
        .trim();

      if (!html.toLowerCase().includes("<!doctype html")) {
        return res.status(500).json({ error: "Invalid HTML output" });
      }

      return res.status(200).json({ html });
    } catch (e) {
      return res.status(500).json({ error: e.message });
    }
  }
);
