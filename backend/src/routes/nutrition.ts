// backend/src/routes/nutrition.ts
import express, { Response, NextFunction } from 'express';
import { requireAuth, AuthRequest } from '../middlewares/auth';
import FoodModel from '../models/Food';
import HistoryModel from '../models/History';

const router = express.Router();

// GET /nutrition/search?q=manzana
// Busca alimentos cuyo nombre contenga el texto (case-insensitive)
router.get('/search', requireAuth, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const q = (req.query.q as string) || '';
    const foods = await FoodModel.find({
      name: { $regex: q, $options: 'i' },
    }).lean();
    res.json({ foods });
  } catch (err) {
    next(err);
  }
});

// POST /nutrition/log
// Registra un consumo del usuario autenticado
router.post('/log', requireAuth, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { foodId, quantity } = req.body;
    const entry = await HistoryModel.create({
      user: req.userId,
      food: foodId,
      quantity,
      consumedAt: new Date(),
    });
    res.status(201).json({ entry });
  } catch (err) {
    next(err);
  }
});

// GET /nutrition/history
// Obtiene el historial de consumo del usuario autenticado
router.get('/history', requireAuth, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const history = await HistoryModel.find({ user: req.userId })
      .populate('food')
      .sort({ consumedAt: -1 })
      .lean();
    res.json({ history });
  } catch (err) {
    next(err);
  }
});

export default router;
