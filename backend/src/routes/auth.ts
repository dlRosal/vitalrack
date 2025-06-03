// backend/src/routes/auth.ts
import express, { Request, Response, NextFunction } from 'express';
import UserModel from '../models/User';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import mongoose from 'mongoose';

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
    // 1) Revisar errores de validación
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;

      // 2) Normalizar email (minusculas y sin espacios)
      const normalizedEmail = (email as string).trim().toLowerCase();

      // 3) Comprobar si ya existe un usuario con ese email
      const exists = await UserModel.findOne({ email: normalizedEmail });
      if (exists) {
        return res.status(409).json({ msg: 'Ese email ya está en uso' });
      }

      // 4) Crear el usuario (el hashing de la contraseña se hace en el pre-save del esquema)
      const user = new UserModel({
        email: normalizedEmail,
        password: password.trim(),
      });
      await user.save();

      console.log('Usuario registrado:', user._id, 'en base', mongoose.connection.name);

      // 5) Firmar y devolver JWT
      const token = signToken(user._id.toString());
      return res.status(201).json({ token });
    } catch (err: unknown) {
      // Si ocurre un error de índice único (duplicate key), capturarlo:
      // p.ej. si dos peticiones simultáneas intentan registrar el mismo email
      // y salta un E11000 duplicate key error.
      if (
        err &&
        typeof err === 'object' &&
        'code' in err &&
        (err as { code: number }).code === 11000
      ) {
        return res.status(409).json({ msg: 'Ese email ya está en uso' });
      }
      next(err);
    }
  },
);

/**
 * ─── POST /auth/login ───────────────────────────────────────────────────────────
 * Valida que `email` sea un email y que `password` no esté vacío.
 */
router.post(
  '/login',
  body('email').isEmail().withMessage('Email inválido'),
  body('password').notEmpty().withMessage('La contraseña no puede estar vacía'),
  async (req: Request, res: Response, next: NextFunction) => {
    // 1) Revisar errores de validación
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;
      const normalizedEmail = (email as string).trim().toLowerCase();

      // 2) Buscar el usuario por email
      const user = await UserModel.findOne({ email: normalizedEmail });
      if (!user) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      // 3) Comparar contraseña usando comparePassword (método del esquema)
      const match = await user.comparePassword(password.trim());
      if (!match) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      // 4) Firmar y devolver JWT
      const token = signToken(user._id.toString());
      return res.json({ token });
    } catch (err) {
      next(err);
    }
  },
);

/**
 * ─── GET /auth/me ───────────────────────────────────────────────────────────────
 * Requiere cabecera Authorization: Bearer <token>
 * Devuelve los datos del usuario (sin la contraseña).
 */
router.get('/me', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ msg: 'No estás autenticado' });
    }

    const token = authHeader.split(' ')[1];
    let payload: { id: string };
    try {
      payload = jwt.verify(token, JWT_SECRET) as { id: string };
    } catch {
      return res.status(401).json({ msg: 'Token inválido' });
    }

    // 1) Obtener el usuario de la base de datos (sin la contraseña)
    const userId = payload.id;
    const user = await UserModel.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({ msg: 'Usuario no encontrado' });
    }

    return res.json({ user });
  } catch (err) {
    next(err);
  }
});

/**
 * ─── POST /auth/logout ────────────────────────────────────────────────────────────
 * (Opcional, solo para que el cliente simule el logout)
 */
router.post('/logout', (_req: Request, res: Response) => {
  // En muchos backends no hace nada, porque el cliente se encarga de descartar el JWT.
  return res.json({ msg: 'Has cerrado sesión' });
});

export default router;
