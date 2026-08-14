/**
 * Grants (or revokes) the admin custom claim for a Firebase user, so they
 * can sign in to the Next.js admin panel and call admin-only API routes.
 *
 * Usage:
 *   npm run set-admin -- someone@example.com          (grant admin)
 *   npm run set-admin -- someone@example.com revoke    (remove admin)
 */
import { auth } from "../config/firebase";

async function main() {
  const email = process.argv[2];
  const revoke = process.argv[3] === "revoke";

  if (!email) {
    console.error("Usage: npm run set-admin -- <email> [revoke]");
    process.exit(1);
  }

  const user = await auth.getUserByEmail(email);
  await auth.setCustomUserClaims(user.uid, { admin: !revoke });

  console.log(`${revoke ? "Revoked" : "Granted"} admin for ${email} (uid: ${user.uid}).`);
  console.log("The user must sign out and sign back in for the change to take effect.");
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
