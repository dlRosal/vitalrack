// backend/src/routes/auth.ts
import express, { Request, Response, NextFunction } from 'express';
import UserModel from '../models/User';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import mongoose from 'mongoose';
import { requireAuth, AuthRequest } from '../middlewares/auth'; // <-- asegúrate de tener este middleware

const router = express.Router();

// ─── 1) Comprobamos que exista la variable JWT_SECRET ───────────────────────
const JWT_SECRET = process.env.JWT_SECRET as string;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET no está definido en .env');
}

/**
 * Helper para crear un JWT firmado.
 */
function signToken(userId: string) {
  return jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '1h' });
}

/**
 * ─── POST /auth/register ────────────────────────────────────────────────────────
 * Valida que `email` sea un email válido y que `password` tenga al menos 6 caracteres.
 */
router.post(
  '/register',
  body('email').isEmail().withMessage('Email inválido'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('La contraseña debe tener al menos 6 caracteres'),
  async (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;
      const normalizedEmail = (email as string).trim().toLowerCase();

      const exists = await UserModel.findOne({ email: normalizedEmail });
      if (exists) {
        return res.status(409).json({ msg: 'Ese email ya está en uso' });
      }

      const user = new UserModel({
        email: normalizedEmail,
        password: password.trim(),
      });
      await user.save();

      console.log('Usuario registrado:', user._id, 'en base', mongoose.connection.name);

      const token = signToken(user._id.toString());
      return res.status(201).json({ token });
    } catch (err) {
      if (
        typeof err === 'object' &&
        err !== null &&
        'code' in err &&
        (err as { code?: number }).code === 11000
      ) {
        // Duplicate key (email ya registrado simultáneamente)
        return res.status(409).json({ msg: 'Ese email ya está en uso' });
      }
      next(err);
    }
  },
);

/**
 * ─── POST /auth/login ───────────────────────────────────────────────────────────
 */
router.post(
  '/login',
  body('email').isEmail().withMessage('Email inválido'),
  body('password').notEmpty().withMessage('La contraseña no puede estar vacía'),
  async (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;
      const normalizedEmail = (email as string).trim().toLowerCase();

      const user = await UserModel.findOne({ email: normalizedEmail });
      if (!user) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      const match = await user.comparePassword(password.trim());
      if (!match) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      const token = signToken(user._id.toString());
      return res.json({ token });
    } catch (err) {
      next(err);
    }
  },
);

/**
 * ─── GET /auth/me ───────────────────────────────────────────────────────────────
 */
router.get(
  '/me',
  requireAuth, // middleware que extrae req.userId basado en el JWT
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.userId!;
      const user = await UserModel.findById(userId).select('-password');
      if (!user) {
        return res.status(404).json({ msg: 'Usuario no encontrado' });
      }
      return res.json({ user });
    } catch (err) {
      next(err);
    }
  },
);

/**
 * ─── PUT /auth/me ───────────────────────────────────────────────────────────────
 * Permite al usuario autenticado actualizar username, gender, age, height, weight.
 */
router.put(
  '/me',
  requireAuth,
  body('username').optional().isString(),
  body('gender').optional().isString(),
  body('age').optional().isInt({ min: 0 }),
  body('height').optional().isFloat({ min: 0 }),
  body('weight').optional().isFloat({ min: 0 }),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const userId = req.userId!;
      const { username, gender, age, height, weight } = req.body;
      const updateData: Partial<{
        username: string;
        gender: string;
        age: number;
        height: number;
        weight: number;
      }> = {};

      if (username !== undefined) updateData.username = username.trim();
      if (gender !== undefined) updateData.gender = gender.trim();
      if (age !== undefined) updateData.age = age;
      if (height !== undefined) updateData.height = height;
      if (weight !== undefined) updateData.weight = weight;

      const updatedUser = await UserModel.findByIdAndUpdate(
        userId,
        { $set: updateData },
        { new: true, runValidators: true },
      ).select('-password');

      if (!updatedUser) {
        return res.status(404).json({ msg: 'Usuario no encontrado' });
      }

      return res.json({ user: updatedUser });
    } catch (err) {
      next(err);
    }
  },
);

/**
 * ─── POST /auth/logout ────────────────────────────────────────────────────────────
 */
router.post('/logout', (_req: Request, res: Response) => {
  return res.json({ msg: 'Has cerrado sesión' });
});

export default router;
export { router as authRouter };
