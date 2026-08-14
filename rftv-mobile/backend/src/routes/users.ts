import { Router } from "express";
import { UsersService } from "../services/firestore";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

router.get("/me", requireAuth, async (req, res, next) => {
  try {
    const me = await UsersService.get(req.user!.uid);
    res.json(me);
  } catch (err) {
    next(err);
  }
});

router.get("/", requireAuth, requireAdmin, async (_req, res, next) => {
  try {
    res.json(await UsersService.list());
  } catch (err) {
    next(err);
  }
});

export default router;
