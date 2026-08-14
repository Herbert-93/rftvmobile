import { Router } from "express";
import { db } from "../config/firebase";
import { requireAuth } from "../middleware/auth";

const router = Router();

// Called by the mobile app right after sign-up (or first sign-in) to create
// the user's Firestore profile document. `ensureUserDoc` middleware in
// index.ts already does this on every request, but this endpoint lets the
// client pass in a display name / phone captured at sign-up time.
router.post("/session", requireAuth, async (req, res, next) => {
  try {
    const { name, phone } = req.body || {};
    const ref = db.collection("users").doc(req.user!.uid);
    await ref.set(
      {
        uid: req.user!.uid,
        email: req.user!.email || "",
        name: name || "",
        phone: phone || "",
        isAdmin: req.user!.isAdmin,
        createdAt: new Date().toISOString(),
      },
      { merge: true }
    );
    const snap = await ref.get();
    res.json(snap.data());
  } catch (err) {
    next(err);
  }
});

export default router;
