// backend/src/routes/auth.ts
import express, { Request, Response, NextFunction } from 'express';
import UserModel from '../models/User';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET as string;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET no está definido en .env');
}

/**
 * Helper para crear JWT
 */
function signToken(userId: string) {
  return jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '1h' });
}

/**
 * POST /auth/register
 */
router.post(
  '/register',
  // Validación de campos
  body('email').isEmail().withMessage('Email inválido'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('La contraseña debe tener al menos 6 caracteres'),
  async (req: Request, res: Response, next: NextFunction) => {
    // Resultado de validación
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;

      // 1) Revisar existencia
      const exists = await UserModel.findOne({ email });
      if (exists) {
        return res.status(409).json({ msg: 'Ese email ya está en uso' });
      }

      // 2) Crear y guardar
      const hash = await bcrypt.hash(password, 10);
      const user = new UserModel({ email, password: hash });
      await user.save();

      // 3) Devolver token
      const token = signToken(user._id.toString());
      res.status(201).json({ token });
    } catch (err) {
      next(err);
    }
  },
);

/**
 * POST /auth/login
 */
router.post(
  '/login',
  body('email').isEmail(),
  body('password').notEmpty(),
  async (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }

    try {
      const { email, password } = req.body;
      const user = await UserModel.findOne({ email });
      if (!user) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      const match = await bcrypt.compare(password, user.password);
      if (!match) {
        return res.status(401).json({ msg: 'Email o contraseña incorrectos' });
      }

      const token = signToken(user._id.toString());
      res.json({ token }); // status 200 por defecto
    } catch (err) {
      next(err);
    }
  },
);

/**
 * GET /auth/me
 * Obtiene los datos del usuario autenticado
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

    const userId = payload.id as string;
    const user = await UserModel.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({ msg: 'Usuario no encontrado' });
    }

    res.json({ user });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /auth/logout
 * (Opcional, sólo para simular un logout en el cliente)
 */
router.post('/logout', (_req: Request, res: Response) => {
  res.json({ msg: 'Has cerrado sesión' });
});

export default router;
