import { Router } from "express";
import { RadioService } from "../services/firestore";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

router.get("/", requireAuth, async (_req, res, next) => {
  try {
    res.json(await RadioService.get());
  } catch (err) {
    next(err);
  }
});

router.put("/", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await RadioService.update(req.body);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

export default router;
