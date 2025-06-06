// src/routes/training.ts
import { Router } from 'express';
import {
  generateRoutine,
  listRoutines,
  logSession,
  listSessions,
  deleteRoutine,
} from '../controllers/trainingController';
import { requireAuth } from '../middlewares/auth';

const router = Router();

router.post('/generate', requireAuth, generateRoutine);
router.get('/routines', requireAuth, listRoutines);
router.post('/log', requireAuth, logSession);
router.get('/sessions', requireAuth, listSessions);
router.delete('/routines/:id', requireAuth, deleteRoutine);

export default router;
