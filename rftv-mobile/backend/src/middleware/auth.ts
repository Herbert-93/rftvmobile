import { Request, Response, NextFunction } from "express";
import { auth, db } from "../config/firebase";

// Extend Express's Request type with the decoded Firebase user.
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email?: string;
        isAdmin: boolean;
      };
    }
  }
}

/**
 * Verifies the Firebase ID token sent as `Authorization: Bearer <token>`.
 * Attaches `req.user` on success. Use on any route that requires a signed-in user.
 */
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;

    if (!token) {
      return res.status(401).json({ error: "Missing bearer token" });
    }

    const decoded = await auth.verifyIdToken(token);
    req.user = {
      uid: decoded.uid,
      email: decoded.email,
      isAdmin: decoded.admin === true,
    };
    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

/**
 * Use after requireAuth on routes that only admins (content managers) may call.
 * Admin status comes from a Firebase custom claim `{ admin: true }`, set via
 * the set-admin script (see src/scripts/setAdmin.ts) or the admin panel itself.
 */
export async function requireAdmin(req: Request, res: Response, next: NextFunction) {
  if (!req.user?.isAdmin) {
    return res.status(403).json({ error: "Admin access required" });
  }
  next();
}

/**
 * Ensures a Firestore `users/{uid}` document exists for the caller. Cheap to call
 * on every authenticated request; only writes when the doc is missing.
 */
export async function ensureUserDoc(req: Request, _res: Response, next: NextFunction) {
  try {
    if (req.user) {
      const ref = db.collection("users").doc(req.user.uid);
      const snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          uid: req.user.uid,
          email: req.user.email || "",
          isAdmin: false,
          createdAt: new Date().toISOString(),
        });
      }
    }
  } catch {
    // Non-fatal: don't block the request if this housekeeping write fails.
  }
  next();
}
