/**
 * Seeds Firestore with sample content so the app and admin panel aren't
 * empty on first run. Safe to re-run — it overwrites the same doc IDs.
 *
 * Usage: npm run seed
 */
import { db } from "../config/firebase";

async function main() {
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
    message:
      "Music, talk shows and family programming, streaming live to your phone. We're putting the final touches on it.",
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

  console.log("Seed complete: 4 channels, 3 programs, radio status, donation config.");
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
