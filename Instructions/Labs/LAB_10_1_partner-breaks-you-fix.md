---
title: 'Lab 10.1 – Partner breaks, you fix'
lab:
    title: 'Lab 10.1 – Partner breaks, you fix'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 10.1 – Partner breaks, you fix

**Estimated time:** 30 minutes

> **Draft:** This lab is new and its scenarios are still being tested. If a step behaves differently, tell the trainer.

**Goal:** Find a fault you do not know – with the method of this course: scope first, five layers, compare with your known-good CL3.

**Starting point:** You work in pairs, A and B. Each of you draws a scenario card from the trainer. Your card describes one Intune object with exactly one wrong setting. You build it for your partner's CL3 – your partner builds one for yours. You do not tell your partner what is on your card.

**Exception for this lab:** You assign an object to your partner's device group. That is the only time in this course you touch another participant's group.

1. Build the object exactly as your card says. Name it `etcX-Case` (your own number), assign it to your partner's `studentYdevices`.
2. Give your partner only the helpdesk ticket from your card – not the settings.
3. Read the ticket you got from your partner and sync your CL3.
4. Find the cause on your own CL3 and in the Intune admin center. Work through the five layers and compare with what CL3 logged in Lab 5.1 and Lab 6.1.
5. Write down the root cause, the evidence (log line, registry value or portal status) and the fix.
6. Check your result with your partner's card, then with the trainer.
7. Clean up: delete your `etcX-Case`.

### Checkpoint

- [ ] Root cause named
- [ ] Evidence found on CL3 or in the portal: log file and line, registry key or status
- [ ] Fix named and confirmed by your partner's card
- [ ] `etcX-Case` deleted

<details markdown="1">
<summary>Hint 1 – where to start</summary>

Find `etcX-Case` of your partner in the Intune admin center (you can read every object). The object type tells you which IME log to open – see the log map in the [Appendix](../Appendix.html#log-map).

</details>

<details markdown="1">
<summary>Hint 2 – compare</summary>

Open the same log for your own object from Lab 5.1 or Lab 6.1. Find the first line where `etcX-Case` behaves differently.

</details>

<details markdown="1">
<summary>Hint 3 – the settings</summary>

Compare every setting of `etcX-Case` with your own working object from Lab 5.1 or Lab 6.1. Exactly one setting differs.

</details>

**Note:** Your partner's object reaches CL3 like every other assignment – after a sync, an app within minutes. A remediation runs on its schedule; restart the IME if nothing shows up in `HealthScripts.log` after 5 minutes.

**Why:** In the real world nobody tells you the cause. You know what healthy looks like – the first deviation shows you where to look.
