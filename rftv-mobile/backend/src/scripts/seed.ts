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

  // Helper: returns a Date at the same time of day as `now`, but on the next
  // occurrence of `targetWeekday` (1 = Monday ... 7 = Sunday, ISO weekday).
  function nextWeekday(targetWeekday: number, hour: number, minute = 0) {
    const d = new Date(now);
    const diff = (targetWeekday - d.getDay() + 7) % 7; // 0..6 days ahead; today counts as 0
    d.setDate(d.getDate() + diff);
    d.setHours(hour, minute, 0, 0);
    return d;
  }

  const programs = [
    {
      channelId: "rf-tv1",
      title: "Family Hour: Evening Devotion",
      startTime: now.toISOString(),
      endTime: new Date(now.getTime() + 60 * 60000).toISOString(),
      description: "A recorded evening devotion session with worship and reflection for the whole family.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      thumbnailUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
      durationMinutes: 10,
      category: "Documentaries",
    },
    {
      channelId: "rf-tv1",
      title: "RF News Nightly",
      startTime: new Date(now.getTime() + 60 * 60000).toISOString(),
      endTime: new Date(now.getTime() + 90 * 60000).toISOString(),
      description: "The day's top stories from around Uganda and the world.",
      category: "News",
    },
    {
      channelId: "rf-tv1",
      title: "Family Feud Uganda",
      startTime: new Date(now.getTime() + 90 * 60000).toISOString(),
      endTime: new Date(now.getTime() + 120 * 60000).toISOString(),
      description: "A recorded episode of the family game show, full of laughs for everyone.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      thumbnailUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
      durationMinutes: 11,
      category: "Shows",
    },
    // Spread across the week (Monday–Sunday) so the Home screen's weekly
    // lineup has something to show on every day, across every category.
    {
      channelId: "rf-tv1",
      title: "Morning News Bulletin",
      startTime: nextWeekday(1, 7, 0).toISOString(),
      endTime: nextWeekday(1, 7, 30).toISOString(),
      description: "A quick roundup of the top headlines to start your Monday.",
      category: "News",
      durationMinutes: 30,
    },
    {
      channelId: "rf-sports",
      title: "Uganda Premier League Highlights",
      startTime: nextWeekday(2, 19, 0).toISOString(),
      endTime: nextWeekday(2, 20, 0).toISOString(),
      description: "The best goals and moments from this week's league fixtures.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      thumbnailUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
      durationMinutes: 60,
      category: "Sports",
    },
    {
      channelId: "rf-tv1",
      title: "Movie Night: The Journey Home",
      startTime: nextWeekday(3, 20, 0).toISOString(),
      endTime: nextWeekday(3, 22, 0).toISOString(),
      description: "A heartwarming feature film about family and finding your way back.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      thumbnailUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
      durationMinutes: 120,
      category: "Movies",
    },
    {
      channelId: "rf-faith",
      title: "Sunday Church Service",
      startTime: nextWeekday(7, 9, 0).toISOString(),
      endTime: nextWeekday(7, 11, 0).toISOString(),
      description: "Join us live for worship, the sermon, and fellowship.",
      videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      thumbnailUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
      durationMinutes: 120,
      category: "Documentaries",
    },
    {
      channelId: "rf-tv1",
      title: "Talk of the Town",
      startTime: nextWeekday(5, 18, 0).toISOString(),
      endTime: nextWeekday(5, 19, 0).toISOString(),
      description: "A weekly talk show covering culture, entertainment and community stories.",
      category: "Shows",
      durationMinutes: 60,
    },
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

  // Dummy donation records so the admin panel's Donations table and
  // Overview stats aren't empty for a demo. Safe to re-run — uses fixed
  // doc IDs "demo-donation-1".."demo-donation-9" and overwrites each time.
  const demoDonations = [
    { amount: 20000, paymentMethod: "mtn", phoneNumber: "0772 445 210", status: "completed", hoursAgo: 2 },
    { amount: 10000, paymentMethod: "airtel", phoneNumber: "0754 908 331", status: "completed", hoursAgo: 5 },
    { amount: 50000, paymentMethod: "mtn", phoneNumber: "0781 223 764", status: "completed", hoursAgo: 9 },
    { amount: 5000, paymentMethod: "airtel", phoneNumber: "0700 156 482", status: "pending", hoursAgo: 14 },
    { amount: 100000, paymentMethod: "mtn", phoneNumber: "0776 812 093", status: "completed", hoursAgo: 22 },
    { amount: 20000, paymentMethod: "airtel", phoneNumber: "0752 340 617", status: "completed", hoursAgo: 30 },
    { amount: 10000, paymentMethod: "mtn", phoneNumber: "0783 991 205", status: "failed", hoursAgo: 40 },
    { amount: 50000, paymentMethod: "airtel", phoneNumber: "0701 674 328", status: "completed", hoursAgo: 55 },
    { amount: 5000, paymentMethod: "mtn", phoneNumber: "0774 502 869", status: "completed", hoursAgo: 70 },
  ];

  for (let i = 0; i < demoDonations.length; i++) {
    const { hoursAgo, ...rest } = demoDonations[i];
    await db
      .collection("donations")
      .doc(`demo-donation-${i + 1}`)
      .set(
        {
          ...rest,
          userId: "demo-user",
          currency: "UGX",
          createdAt: new Date(now.getTime() - hoursAgo * 60 * 60000).toISOString(),
        },
        { merge: true }
      );
  }

  console.log("Seed complete: 4 channels, 8 programs across the week (4 with video, all categorized), radio status, donation config, 9 donation records.");
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});