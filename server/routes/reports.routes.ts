import { Router } from "express";

const router = Router();

router.get("/", (req, res) => {
  res.status(501).json({
    success: false,
    message: "Reports functionality not yet implemented"
  });
});

export default router;