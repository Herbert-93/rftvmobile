import { Router } from "express";
import { ProgramsService } from "../services/firestore";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

router.get("/", requireAuth, async (req, res, next) => {
  try {
    const channelId = typeof req.query.channelId === "string" ? req.query.channelId : undefined;
    const programs = await ProgramsService.list(channelId);
    res.json(programs);
  } catch (err) {
    next(err);
  }
});

router.post("/", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const program = await ProgramsService.create(req.body);
    res.status(201).json(program);
  } catch (err) {
    next(err);
  }
});

router.put("/:id", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await ProgramsService.update(req.params.id, req.body);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

router.delete("/:id", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    await ProgramsService.remove(req.params.id);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

export default router;
