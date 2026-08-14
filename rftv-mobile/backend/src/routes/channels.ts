import { Router } from "express";
import { ChannelsService } from "../services/firestore";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

// Public within the app: any signed-in user can read channels.
router.get("/", requireAuth, async (_req, res, next) => {
  try {
    const channels = await ChannelsService.list();
    res.json(channels);
  } catch (err) {
    next(err);
  }
});

router.get("/:id", requireAuth, async (req, res, next) => {
  try {
    const channel = await ChannelsService.get(req.params.id);
    if (!channel) return res.status(404).json({ error: "Channel not found" });
    res.json(channel);
  } catch (err) {
    next(err);
  }
});

// Admin-only writes (used by the Next.js admin panel).
router.post("/", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const channel = await ChannelsService.create(req.body);
    res.status(201).json(channel);
  } catch (err) {
    next(err);
  }
});

router.put("/:id", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await ChannelsService.update(req.params.id, req.body);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

router.delete("/:id", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await ChannelsService.remove(req.params.id);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

export default router;
