// src/controllers/trainingController.ts
import { Response, NextFunction } from 'express';
import { Types } from 'mongoose';
import Routine, { IRoutine, IExercise } from '../models/Routine';
import Session, { ISession, IEntry } from '../models/Session';
import { AuthRequest } from '../middlewares/auth';

/**
 * POST /training/generate
 * Body: { name: string, level: 'push'|'pull'|'leg' }
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
    if (typeof name !== 'string' || !['push', 'pull', 'leg'].includes(level)) {
      res.status(400).json({ msg: 'name y level válidos son obligatorios' });
      return;
    }

    let exercises: IExercise[] = [];

    switch (level) {
      case 'push':
        exercises = [
          { name: 'Press de banca plano', sets: 4, reps: 8, restSec: 90 },
          { name: 'Press militar con barra', sets: 4, reps: 8, restSec: 90 },
          { name: 'Fondos en paralelas', sets: 3, reps: 10, restSec: 60 },
          { name: 'Press inclinado con mancuernas', sets: 3, reps: 10, restSec: 60 },
          { name: 'Elevaciones laterales con mancuernas', sets: 3, reps: 15, restSec: 45 },
          { name: 'Press Arnold', sets: 3, reps: 12, restSec: 60 },
          { name: 'Extensiones de tríceps en polea alta', sets: 3, reps: 15, restSec: 45 },
          { name: 'Patada de tríceps con mancuerna', sets: 3, reps: 12, restSec: 45 },
        ];
        break;
      case 'pull':
        exercises = [
          { name: 'Peso muerto convencional', sets: 4, reps: 6, restSec: 120 },
          { name: 'Dominadas pronadas', sets: 3, reps: 10, restSec: 60 },
          { name: 'Remo con barra', sets: 3, reps: 10, restSec: 60 },
          { name: 'Remo en máquina', sets: 3, reps: 12, restSec: 60 },
          { name: 'Curl de bíceps con barra', sets: 3, reps: 12, restSec: 45 },
          { name: 'Curl martillo con mancuernas', sets: 3, reps: 12, restSec: 45 },
          { name: 'Face pulls (jalones a la cara)', sets: 3, reps: 15, restSec: 45 },
          { name: 'Encogimientos de trapecio con barra', sets: 3, reps: 15, restSec: 30 },
        ];
        break;
      case 'leg':
        exercises = [
          { name: 'Sentadillas traseras', sets: 4, reps: 8, restSec: 90 },
          { name: 'Prensa de piernas', sets: 4, reps: 10, restSec: 90 },
          { name: 'Zancadas con mancuernas', sets: 3, reps: 12, restSec: 60 },
          { name: 'Peso muerto rumano', sets: 3, reps: 10, restSec: 60 },
          { name: 'Elevaciones de talones (gemelos)', sets: 4, reps: 20, restSec: 30 },
          { name: 'Curl femoral en máquina', sets: 3, reps: 12, restSec: 45 },
          { name: 'Extensión de piernas en máquina', sets: 3, reps: 12, restSec: 45 },
          { name: 'Hip thrust con barra', sets: 3, reps: 10, restSec: 60 },
        ];
        break;
    }

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

/**
 * DELETE /training/routines/:id
 */
export const deleteRoutine = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }

    const { id } = req.params;
    if (!Types.ObjectId.isValid(id)) {
      res.status(400).json({ msg: 'ID inválido' });
      return;
    }

    await Routine.deleteOne({ _id: id, userId: req.userId });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};