// src/controllers/trainingController.ts
import { Response, NextFunction } from 'express';
import { Types } from 'mongoose';
import Routine, { IRoutine, IExercise } from '../models/Routine';
import Session, { ISession, IEntry } from '../models/Session';
import { AuthRequest } from '../middlewares/auth';

/**
 * POST /training/generate
 * Body: { name: string, level: 'beginner'|'intermediate'|'advanced' }
 */
export const generateRoutine = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }

    const { name, level } = req.body as { name: string; level: string };
    if (typeof name !== 'string' || !['beginner', 'intermediate', 'advanced'].includes(level)) {
      res.status(400).json({ msg: 'name y level válidos son obligatorios' });
      return;
    }

    // Lógica simple de ejemplo: full-body con 3 ejercicios
    const exercises: IExercise[] = [
      
      { name: 'Sentadillas', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Press de banca', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Remo con mancuerna', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Peso muerto', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Press militar', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Dominadas', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Fondos', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Curl de bíceps', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Extensiones de tríceps', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Elevaciones laterales', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Abdominales', sets: 3, reps: level === 'beginner' ? 8 : 12, restSec: 60 },
      { name: 'Plancha', sets: 3, reps: level === 'beginner' ? 30 : 60, restSec: 60 },
      { name: 'Cardio', sets: 1, reps: level === 'beginner' ? 20 : 30, restSec: 60 },
    ];

    const routine = await Routine.create({
      userId: new Types.ObjectId(req.userId),
      name,
      exercises,
    } as IRoutine);

    res.status(201).json({ routine });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /training/routines
 */
export const listRoutines = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }
    const routines = await Routine.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json({ routines });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /training/log
 * Body: { routineId: string, duration: number, entries: IEntry[], notes?: string }
 */
export const logSession = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }

    const { routineId, duration, entries, notes } = req.body as {
      routineId: string;
      duration: number;
      entries: IEntry[];
      notes?: string;
    };

    if (
      !Types.ObjectId.isValid(routineId) ||
      typeof duration !== 'number' ||
      duration <= 0 ||
      !Array.isArray(entries) ||
      entries.some(
        (e) =>
          typeof e.exerciseName !== 'string' ||
          typeof e.sets !== 'number' ||
          typeof e.reps !== 'number' ||
          typeof e.weight !== 'number',
      )
    ) {
      res.status(400).json({ msg: 'Payload inválido para logSession' });
      return;
    }

    const session = await Session.create({
      userId: new Types.ObjectId(req.userId),
      routineId: new Types.ObjectId(routineId),
      date: new Date(),
      entries,
      duration,
      notes,
    } as ISession);

    res.status(201).json({ session });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /training/sessions
 */
export const listSessions = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }
    const sessions = await Session.find({ userId: req.userId }).sort({ date: -1 });
    res.json({ sessions });
  } catch (err) {
    next(err);
  }
};
