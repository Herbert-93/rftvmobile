import { Router } from "express";
import { DonationConfigService, DonationsService } from "../services/firestore";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

router.get("/config", requireAuth, async (_req, res, next) => {
  try {
    res.json(await DonationConfigService.get());
  } catch (err) {
    next(err);
  }
});

router.put("/config", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await DonationConfigService.update(req.body);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

// Records a donation intent from the mobile app. This does NOT move money —
// wire this up to MTN/Airtel's collection APIs before going live; for now it
// just logs the attempt so the admin panel and user's "Donation history" have
// something real to show.
router.post("/", requireAuth, async (req, res, next) => {
  try {
    const { amount, currency, paymentMethod, phoneNumber } = req.body;
    const record = await DonationsService.create({
      userId: req.user!.uid,
      amount,
      currency: currency || "UGX",
      paymentMethod,
      phoneNumber,
      status: "pending",
      createdAt: new Date().toISOString(),
    });
    res.status(201).json(record);
  } catch (err) {
    next(err);
  }
});

router.get("/mine", requireAuth, async (req, res, next) => {
  try {
    res.json(await DonationsService.listForUser(req.user!.uid));
  } catch (err) {
    next(err);
  }
});

router.get("/", requireAuth, requireAdmin, async (_req, res, next) => {
  try {
    res.json(await DonationsService.listAll());
  } catch (err) {
    next(err);
  }
});

export default router;
