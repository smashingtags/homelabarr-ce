# HomelabARR Brand Identity Package
## Version 1.0 | February 2026

---

## 1. LOGO SPECIFICATIONS

### Primary Logo: "The Container Captain"

#### SVG Code (Scalable Vector Graphics)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 120" width="400" height="120">
  <!-- Background Circle (optional, for icon use) -->
  <defs>
    <linearGradient id="primaryGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1a237e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#00bfa5;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="accentGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#ffab00;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#ff6d00;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- House/Lab Flask Icon -->
  <g transform="translate(20, 20)">
    <!-- House outline -->
    <path d="M 40 10 L 70 35 L 70 75 L 10 75 L 10 35 Z" fill="url(#primaryGradient)" stroke="#1a237e" stroke-width="2"/>
    
    <!-- Flask integrated into roof -->
    <path d="M 25 35 L 25 55 Q 25 70 40 70 Q 55 70 55 55 L 55 35 Z" fill="#ffffff" stroke="#00bfa5" stroke-width="2"/>
    
    <!-- Container blocks inside flask -->
    <rect x="30" y="42" width="8" height="8" fill="#00bfa5" rx="1"/>
    <rect x="42" y="42" width="8" height="8" fill="#ffab00" rx="1"/>
    <rect x="30" y="53" width="8" height="8" fill="#ffab00" rx="1"/>
    <rect x="42" y="53" width="8" height="8" fill="#00bfa5" rx="1"/>
    
    <!-- Flask neck -->
    <rect x="36" y="30" width="8" height="8" fill="#ffffff" stroke="#00bfa5" stroke-width="2"/>
  </g>
  
  <!-- Wordmark: HomelabARR -->
  <g transform="translate(110, 50)">
    <!-- Homelab -->
    <text x="0" y="25" font-family="Inter, -apple-system, BlinkMacSystemFont, sans-serif" 
          font-size="32" font-weight="600" fill="#1a237e">Homelab</text>
    
    <!-- ARR (bold, slightly raised, wave effect) -->
    <text x="142" y="22" font-family="Inter, -apple-system, BlinkMacSystemFont, sans-serif" 
          font-size="36" font-weight="800" fill="url(#accentGradient)">ARR</text>
    
    <!-- Wave underline on ARR -->
    <path d="M 142 30 Q 155 28, 168 30 Q 181 32, 194 30" 
          stroke="#ffab00" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Tagline -->
  <text x="110" y="85" font-family="Inter, -apple-system, BlinkMacSystemFont, sans-serif" 
        font-size="12" font-weight="400" fill="#5f6368" letter-spacing="0.5">YOUR HOMELAB. SIMPLIFIED.</text>
</svg>
```

#### Logo Variations

**1. Icon Only (favicon, app icon)**
- 16x16, 32x32, 64x64, 128x128, 256x256 PNG
- 180x180 Apple touch icon
- SVG for scalability

**2. Wordmark Only (text-only contexts)**
- "HomelabARR" with wave underline
- No house/flask icon

**3. Horizontal Layout (headers, navbars)**
- Icon left, text right
- Compact spacing

**4. Stacked Layout (square formats)**
- Icon top, text bottom
- Centered alignment

**5. Monochrome Version**
- Single color for printing, embossing
- Navy or white depending on background

---

## 2. COLOR PALETTE

### Primary Colors

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **Deep Navy** | #1a237e | rgb(26, 35, 126) | Primary brand color, headers, text |
| **Electric Teal** | #00bfa5 | rgb(0, 191, 165) | Secondary, success states, links |
| **Warm Amber** | #ffab00 | rgb(255, 171, 0) | Accents, CTAs, highlights |

### Secondary Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Coral Alert** | #ff6d00 | Warnings, alerts, important actions |
| **Cloud Gray** | #f5f5f5 | Backgrounds, cards |
| **Charcoal** | #212121 | Body text |
| **Soft White** | #ffffff | Clean backgrounds |

### Gradient Preset
```css
--primary-gradient: linear-gradient(135deg, #1a237e 0%, #00bfa5 100%);
--accent-gradient: linear-gradient(90deg, #ffab00 0%, #ff6d00 100%);
```

---

## 3. TYPOGRAPHY

### Primary Font: Inter
- **Weights**: 400 (Regular), 600 (Semi-Bold), 800 (Extra-Bold)
- **Usage**: UI text, headings, body copy
- **Fallback**: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif

### Display/Logo Font: Inter (same family)
- **ARR portion**: Extra-Bold (800) with slight letter-spacing

### Monospace Font: JetBrains Mono or Fira Code
- **Usage**: Code blocks, terminal output, technical data

---

## 4. MASCOT: CAP'N CACHE

### Character Design Specification

**Name:** Cap'n Cache  
**Species:** Cyber-Octopus (Octopus vulgaris digitalis)  
**Role:** Chief Operations Officer of Your Homelab

#### Visual Description

**Body:**
- Shape: Rounded, friendly octopus body, slightly squashed (not elongated)
- Size: Proportioned like a cute cartoon character, not realistic
- Color: Gradient from Deep Navy (#1a237e) at top to Electric Teal (#00bfa5) at bottom
- Texture: Subtle digital/circuit pattern overlay (very faint, almost subliminal)

**Face:**
- Eyes: Two large, expressive eyes
  - Left eye: Standard friendly circle with white sclera and teal iris
  - Right eye: LED-style "status indicator" (green dot with glow effect when healthy, amber when warning, red when error)
- Expression: Slight confident smirk, approachable but competent
- Eyebrows: Simple lines that can animate for expressions

**Tentacles (8 total):**
Each tentacle ends in a different service icon:

1. **Docker Container** - Three stacked squares icon
2. **Database** - Cylinder icon
3. **Security/Shield** - Shield with checkmark
4. **Monitoring** - Lightning bolt or pulse line
5. **Network** - Globe or connection nodes
6. **Storage** - Hard drive or folder
7. **Settings** - Gear/wrench
8. **Free/Pointing** - Used for gestures (pointing, thumbs up, waving)

**Accessories:**
- Small captain's hat: Navy blue with gold trim and HomelabARR "ARR" on front
- Optional: Tiny telescope or clipboard in one tentacle (when in "monitoring" mode)

#### SVG Base Template

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="200" height="200">
  <defs>
    <linearGradient id="captainGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#1a237e"/>
      <stop offset="100%" style="stop-color:#00bfa5"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  
  <!-- Tentacles (simplified, would be 8 distinct curves) -->
  <path d="M 60 120 Q 40 150 30 180" stroke="url(#captainGradient)" stroke-width="12" fill="none" stroke-linecap="round"/>
  <path d="M 80 125 Q 70 160 75 190" stroke="url(#captainGradient)" stroke-width="12" fill="none" stroke-linecap="round"/>
  <path d="M 100 130 Q 100 165 105 195" stroke="url(#captainGradient)" stroke-width="12" fill="none" stroke-linecap="round"/>
  <path d="M 120 125 Q 130 160 125 190" stroke="url(#captainGradient)" stroke-width="12" fill="none" stroke-linecap="round"/>
  <path d="M 140 120 Q 160 150 170 180" stroke="url(#captainGradient)" stroke-width="12" fill="none" stroke-linecap="round"/>
  
  <!-- Body -->
  <ellipse cx="100" cy="90" rx="55" ry="50" fill="url(#captainGradient)"/>
  
  <!-- Eyes -->
  <circle cx="80" cy="80" r="12" fill="white"/>
  <circle cx="80" cy="80" r="6" fill="#00bfa5"/>
  <circle cx="120" cy="80" r="12" fill="#1a237e" stroke="#00bfa5" stroke-width="2"/>
  <circle cx="120" cy="80" r="4" fill="#00ff00" filter="url(#glow)"/>
  
  <!-- Mouth -->
  <path d="M 85 105 Q 100 115 115 105" stroke="white" stroke-width="3" fill="none" stroke-linecap="round"/>
  
  <!-- Captain's Hat -->
  <path d="M 70 50 L 130 50 L 120 35 L 80 35 Z" fill="#1a237e" stroke="#ffab00" stroke-width="2"/>
  <rect x="75" y="45" width="50" height="8" fill="#ffab00"/>
  <text x="100" y="52" font-family="Arial" font-size="8" font-weight="bold" fill="#1a237e" text-anchor="middle">ARR</text>
</svg>
```

#### Mascot Poses/States

**1. Default/Idle**
- All tentacles relaxed, slight bobbing animation
- Status eye: Steady green glow
- Expression: Friendly, attentive

**2. Loading/Working**
- Tentacles actively moving (typing, connecting)
- Status eye: Pulsing amber
- Expression: Focused concentration

**3. Success**
- Thumbs-up tentacle prominent
- Status eye: Bright green with sparkle
- Expression: Confident smile
- Optional: Confetti or checkmark particles

**4. Error/Warning**
- Tentacles raised in "alert" posture
- Status eye: Red pulse
- Expression: Concerned but helpful
- Holding clipboard or wrench

**5. Help/Info**
- One tentacle pointing (like a tour guide)
- Status eye: Blue/teal inquiry glow
- Expression: Eager to assist
- Holding telescope or magnifying glass

**6. Celebration (achievements)**
- All tentacles raised high
- Status eye: Rainbow/colorful shimmer
- Wearing party hat instead of captain hat
- Confetti and container icons floating

---

## 5. MISSION STATEMENTS

### Primary (Long Form)

**HomelabARR** is the complete command center for your digital home. We turn complexity into clarity—giving everyone the power to build, deploy, and manage a professional-grade homelab without the enterprise headache. From your first container to your full NAS, we're your crew.

### Short Form (Tagline)

**"Your homelab. Simplified."**

### Technical/Detailed

The open-source platform that brings enterprise infrastructure to your living room. One-click deployments, intelligent monitoring, and complete data control—because your digital life deserves a proper home.

### CE-Specific

Deploy anything. Manage everything. The free, open-source way to run your homelab like a pro.

### PE-Specific

The NAS OS built for enthusiasts. Professional storage, simple setup, zero compromises.

### Brand Promise

**For everyone who ever said "there has to be a better way to manage my home server."**

There is. It's HomelabARR.

---

## 6. VOICE & TONE GUIDELINES

### Brand Personality: "The Knowledgeable First Mate"

**Traits:**
- Competent but approachable
- Enthusiastic about technology, never condescending
- Helpful and encouraging
- Slightly nautical (subtle pirate/maritime references)
- Clear and jargon-free when possible

**Do:**
- Use "we" and "us" (we're in this together)
- Explain the "why" not just the "how"
- Celebrate user wins
- Be honest about limitations
- Use nautical metaphors sparingly and naturally

**Don't:**
- Talk down to users
- Overuse technical jargon
- Use aggressive pirate speak ("yarrr!" every sentence)
- Promise features that don't exist
- Compare negatively to competitors (focus on strengths)

### Sample Copy

**Error Message:**  
"Ahoy! Looks like that container ran aground. Here's what happened and how to get sailing again..."

**Success Message:**  
"All hands on deck! Your deployment is live and running smooth waters."

**Loading State:**  
"Steady as she goes... preparing your containers for launch."

**Help Documentation:**  
"Charting your course: This guide walks you through setting up your first reverse proxy. No previous experience required—we'll navigate together."

---

## 7. USAGE EXAMPLES

### Website Header
- Logo left (horizontal layout)
- Nav items center: Products (CE, PE), Docs, Community, Pricing
- "Get Started" CTA button (amber accent)
- Cap'n Cache peeking from corner on scroll

### GitHub README
- Centered logo (stacked layout)
- Mission statement as tagline
- Quick-start code block
- Cap'n Cache "success" pose as header image

### Documentation
- Cap'n Cache as guide/guidepost
- Navy sidebar, white content area
- Teal for links and highlights
- Amber for warnings and CTAs

### Social Media/Discord
- Profile: Icon-only logo
- Header: Logo + mascot
- Post templates with mascot reactions
- Branded hashtag: #HomelabARR

---

## 8. FILE DELIVERABLES CHECKLIST

### Logo Files
- [ ] logo-primary.svg
- [ ] logo-horizontal.svg
- [ ] logo-stacked.svg
- [ ] logo-icon-only.svg
- [ ] logo-monochrome.svg
- [ ] favicon-16x16.png
- [ ] favicon-32x32.png
- [ ] apple-touch-icon.png
- [ ] logo-social-1200x630.png (OpenGraph)

### Mascot Files
- [ ] mascot-default.svg
- [ ] mascot-loading.svg
- [ ] mascot-success.svg
- [ ] mascot-error.svg
- [ ] mascot-help.svg
- [ ] mascot-celebration.svg
- [ ] mascot-avatar-set.png (Discord, GitHub, etc.)

### Brand Guidelines
- [ ] brand-guidelines.pdf
- [ ] color-palette.ase (for designers)
- [ ] font-files-or-links.txt
- [ ] voice-tone-guide.md

### Mission Statement
- [ ] mission-statements.txt (all variations)
- [ ] tagline-lockups.svg

---

## 9. NEXT STEPS FOR IMPLEMENTATION

1. **Designer Review**: Share SVG specs with designer for polish
2. **Asset Generation**: Export all PNG/SVG sizes from source files
3. **Website Integration**: Implement logo in header, mascot in UI
4. **Documentation Update**: Add branding to style guide
5. **Marketing Materials**: Create social templates with mascot
6. **Merch/Stickers**: Prepare mascot designs for print

---

**Prepared by:** Imogen for HomelabARR  
**Date:** February 22, 2026  
**Version:** 1.0
