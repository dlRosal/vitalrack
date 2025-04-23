// src/routes/nutrition.ts
import { Router } from 'express';
import { search, logConsumption } from '../controllers/nutritionController';
import { requireAuth } from '../middlewares/auth';

const router = Router();

router.get('/search', search);
router.post('/log', requireAuth, logConsumption);

export default router;
