// src/controllers/nutritionController.ts
import { Request, Response, NextFunction } from 'express';
import { Types } from 'mongoose';
import { searchFoods } from '../services/nutritionService';
import Consumption from '../models/Consumption';
import { AuthRequest } from '../middlewares/auth';

/**
 * GET /nutrition/search?q=<término>
 */
export const search = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const q = (req.query.q as string)?.trim();
    if (!q) {
      res.status(400).json({ msg: 'Debes indicar ?q=<término> en la query' });
      return;
    }

    const results = await searchFoods(q);
    res.json({ foods: results });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /nutrition/log
 * Body: { foodId: string, quantity: number }
 * Header: Authorization: Bearer <token>
 */
export const logConsumption = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    // 1) Verificar token y extraer userId desde el middleware
    if (!req.userId) {
      res.status(401).json({ msg: 'No autorizado' });
      return;
    }

    const { foodId, quantity } = req.body;

    // 2) Validación de payload
    if (
      typeof foodId !== 'string' ||
      !Types.ObjectId.isValid(foodId) ||
      typeof quantity !== 'number' ||
      quantity <= 0
    ) {
      res.status(400).json({
        msg: 'Los campos foodId (ObjectId válido) y quantity (número > 0) son obligatorios',
      });
      return;
    }

    // 3) Crear el consumo
    const consumption = await Consumption.create({
      userId: new Types.ObjectId(req.userId),
      foodId: new Types.ObjectId(foodId),
      quantity,
    });

    // 4) Responder con el objeto creado
    res.status(201).json({ consumption });
  } catch (err) {
    next(err);
  }
};
