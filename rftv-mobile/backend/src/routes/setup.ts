import { Router } from "express";
import { auth, db } from "../config/firebase";

const router = Router();

/**
 * One-time / occasional admin operations, meant to be triggered remotely
 * (e.g. with curl) once the backend is deployed — so you never have to run
 * anything on your own machine. Protected by a shared secret, NOT by a user
 * login, so keep ADMIN_SETUP_SECRET private and treat these like root
 * commands. Feel free to delete this file once you no longer need it.
 */
function checkSecret(req: any, res: any, next: any) {
  const provided = req.headers["x-setup-secret"];
  const expected = process.env.ADMIN_SETUP_SECRET;
  if (!expected) {
    return res.status(503).json({ error: "ADMIN_SETUP_SECRET is not set on the server" });
  }
  if (provided !== expected) {
    return res.status(403).json({ error: "Invalid setup secret" });
  }
  next();
}

// POST /setup/seed  -- adds sample channels/programs/radio/donation config.
// Safe to call more than once (it overwrites the same doc IDs).
router.post("/seed", checkSecret, async (_req, res, next) => {
  try {
    const channels = [
      { id: "rf-tv1", name: "RF TV1", category: "News", isLive: true, order: 1, viewerCount: 2481 },
      { id: "rf-news", name: "RF News", category: "News", isLive: false, order: 2, viewerCount: 0 },
      { id: "rf-sports", name: "RF Sports", category: "Sports", isLive: false, order: 3, viewerCount: 0 },
      { id: "rf-faith", name: "RF Faith", category: "Faith", isLive: false, order: 4, viewerCount: 0 },
    ];
    for (const c of channels) {
      const { id, ...data } = c;
      await db.collection("channels").doc(id).set(data, { merge: true });
    }

    const now = new Date();
    const programs = [
      { channelId: "rf-tv1", title: "Family Hour: Evening Devotion", startTime: now.toISOString(), endTime: new Date(now.getTime() + 60 * 60000).toISOString() },
      { channelId: "rf-tv1", title: "RF News Nightly", startTime: new Date(now.getTime() + 60 * 60000).toISOString(), endTime: new Date(now.getTime() + 90 * 60000).toISOString() },
      { channelId: "rf-tv1", title: "Family Feud Uganda", startTime: new Date(now.getTime() + 90 * 60000).toISOString(), endTime: new Date(now.getTime() + 120 * 60000).toISOString() },
    ];
    for (const p of programs) {
      await db.collection("programs").add(p);
    }

    await db.collection("settings").doc("radio").set({
      isLive: false,
      headline: "RF Radio is coming soon",
      message: "Music, talk shows and family programming, streaming live to your phone. We're putting the final touches on it.",
      launchLabel: "Launching Q4 2026",
    });

    await db.collection("settings").doc("donationConfig").set({
      presetAmounts: [5000, 10000, 20000, 50000, 100000],
      currency: "UGX",
      paymentMethods: [
        { id: "mtn", name: "MTN Mobile Money", sub: "Pay with your MTN MoMo wallet", color: "#FFC700", enabled: true },
        { id: "airtel", name: "Airtel Money", sub: "Pay with your Airtel Money wallet", color: "#E8181A", enabled: true },
      ],
    });

    res.json({ ok: true, message: "Seed complete: 4 channels, 3 programs, radio status, donation config." });
  } catch (err) {
    next(err);
  }
});

// POST /setup/set-admin  { "email": "you@example.com" }
// Grants the admin custom claim so that email can log into the admin panel.
// The Firebase Auth user must already exist (create it in the Firebase
// console under Authentication > Users, or sign up in the app first).
router.post("/set-admin", checkSecret, async (req, res, next) => {
     const { email } = req.body || {};
     try {
       if (!email) return res.status(400).json({ error: "Body must include { email }" });

    const user = await auth.getUserByEmail(email);
    await auth.setCustomUserClaims(user.uid, { admin: true });

    res.json({ ok: true, message: `Granted admin to ${email}. Sign out and back in on the admin panel for it to take effect.` });
  } catch (err: any) {
    if (err.code === "auth/user-not-found") {
      return res.status(404).json({ error: `No user with email ${email}. Create it in Firebase Console > Authentication > Users first.` });
    }
    next(err);
  }
});

export default router;
