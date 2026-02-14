# Copywriting Advanced Patterns

## Headline Formulas

### Benefit-Driven

Lead with what the reader gains:

```
"Build Your Website in Days, Not Months"
"Get More Clients Without Cold Calling"
"Save 10 Hours a Week on Manual Reporting"
```

Pattern: **[Desired outcome]** + **[Without pain point / In timeframe]**

### Problem-Solution

Name the problem, then hint at the solution:

```
"Tired of Losing Leads? Automate Your Follow-Ups."
"Your Website Loads in 8 Seconds. Visitors Leave in 3."
"Still Managing Projects in Spreadsheets?"
```

Pattern: **[Pain point as question or statement]** + **[Solution or implication]**

### Number-Based

Specifics build credibility:

```
"5 Ways to Reduce Cart Abandonment by 30%"
"The 3-Step Process Behind Our 98% Client Retention"
"147 Businesses Switched This Quarter. Here's Why."
```

Use odd numbers (they feel more specific), real metrics (not rounded), and keep the number under 10 for readability.

## Social Proof Patterns

### Testimonial Structure

Effective testimonials follow this format:

```
Before state → Discovery → After state → Specific result

"We were spending 20 hours a week on manual invoicing. After switching to
[Product], our billing is fully automated. We've saved $4,000/month in
staff time." — Jane Smith, CFO at Acme Corp
```

Rules:
- Include full name and title (anonymous quotes have low trust)
- Lead with the transformation, not praise ("Great product!" is useless)
- Include a specific metric when possible

### Stat Presentation

```html
<!-- Grid of proof points -->
<div class="stats-grid">
  <div class="stat">
    <span class="stat-number">98%</span>
    <span class="stat-label">Client retention rate</span>
  </div>
  <div class="stat">
    <span class="stat-number">2.5x</span>
    <span class="stat-label">Average revenue increase</span>
  </div>
  <div class="stat">
    <span class="stat-number">500+</span>
    <span class="stat-label">Projects delivered</span>
  </div>
</div>
```

Use 3–4 stats maximum. Mix percentages, multipliers, and counts for variety.

## Onboarding Copy

### Welcome Flows

```
Step 1: "Welcome aboard! Let's set up your workspace."
Step 2: "Add your team members (you can always do this later)"
Step 3: "Connect your first data source"
Step 4: "You're all set! Here's what to explore first."
```

Principles:
- Celebrate progress ("Step 2 of 4 — you're halfway there!")
- Offer escape hatches ("Skip for now", "Do this later")
- Explain why each step matters, not just what to do

### Progressive Disclosure

Reveal complexity gradually:

```
First visit:   "Create your first project"
After project:  "Invite a collaborator" (tooltip)
After 3 days:   "Try advanced filters" (subtle banner)
After 1 week:   "Unlock automations" (feature spotlight)
```

### Tooltip Copy

```
Bad:  "Click here to configure settings"
Good: "Set your notification preferences — choose email, push, or both"
```

Pattern: **[Action]** + **[What it controls]** + **[Available options]**

## Pricing Page Copy

### Plan Comparison

```
Starter — "For individuals getting started"
Pro     — "For growing teams" [MOST POPULAR badge]
Enterprise — "For organizations at scale"
```

Rules:
- Name plans by audience, not features
- Badge the recommended plan ("Most Popular" or "Best Value")
- List features as benefits, not specs ("Unlimited projects" not "100GB storage")

### Feature Framing

```
Bad:  "10 GB storage"
Good: "Store up to 10,000 documents"

Bad:  "API access"
Good: "Connect to 50+ tools with our API"

Bad:  "Priority support"
Good: "Get answers within 2 hours from our team"
```

Translate specs into outcomes. Users don't buy features — they buy capabilities.

### FAQ Objection Handling

Address top buying objections:

```
Q: "Can I cancel anytime?"
A: "Yes — no contracts, no cancellation fees. Cancel from your dashboard in one click."

Q: "Is my data safe?"
A: "Your data is encrypted at rest and in transit. We're SOC 2 Type II certified."

Q: "What if it doesn't work for us?"
A: "Try it free for 14 days. No credit card required."
```

Pattern: **[Objection as question]** → **[Direct answer]** + **[Proof or reassurance]**

## Email Sequences

### Subject Lines

```
Good: "Your project report is ready"       — specific
Good: "3 tips from this week's data"       — numbered, value-driven
Good: "Quick question about your workflow"  — personal, curiosity

Bad:  "Newsletter #47"                     — no value proposition
Bad:  "HUGE ANNOUNCEMENT!!!"              — spam trigger
Bad:  "Don't miss this!"                  — vague
```

Keep under 50 characters. Front-load key words (mobile truncates at ~35 chars).

### Preview Text

The line after the subject in inbox view. Use it deliberately:

```
Subject: "Your weekly report is ready"
Preview: "Traffic up 12% — here's what drove it"
```

Don't let it default to "View in browser" or navigation links.

### CTA Placement

- One primary CTA per email
- Place above the fold (first 300px)
- Repeat at the bottom for long emails
- Button text: action verb + object ("Download Report", "View Dashboard")

## Accessibility in Copy

### Plain Language

- Target 8th-grade reading level for public-facing content
- Use short sentences (under 25 words)
- Prefer common words ("use" not "utilize", "help" not "facilitate")
- Break complex ideas into bullet points

### Reading Level Check

Test with Hemingway Editor or readability formulas. Aim for:
- Flesch Reading Ease: 60+ (higher is easier)
- Flesch-Kincaid Grade: 8 or below

### Alt Text Guidance

```html
<!-- Decorative image — empty alt -->
<img src="divider.svg" alt="" />

<!-- Informative image — describe content -->
<img src="chart.png" alt="Bar chart showing 40% increase in signups from Q1 to Q2" />

<!-- Functional image (link/button) — describe action -->
<a href="/home"><img src="logo.svg" alt="Go to homepage" /></a>
```

Rules:
- Describe what the image communicates, not what it looks like
- Keep under 125 characters
- Don't start with "Image of..." or "Picture of..."
