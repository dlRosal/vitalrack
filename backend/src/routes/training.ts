// src/routes/training.ts
import { Router } from 'express';
import {
  generateRoutine,
  listRoutines,
  logSession,
  listSessions
} from '../controllers/trainingController';
import { requireAuth } from '../middlewares/auth';

const router = Router();

router.post('/generate', requireAuth, generateRoutine);
router.get('/routines', requireAuth, listRoutines);
router.post('/log', requireAuth, logSession);
router.get('/sessions', requireAuth, listSessions);

export default router;
