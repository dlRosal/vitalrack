import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  userId?: string;
}

export const requireAuth = (req: AuthRequest, res: Response, next: NextFunction) => {
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) {
    return res.status(401).json({ msg: 'No autorizado' });
  }
  const token = auth.split(' ')[1];
  try {
    interface JwtPayload {
      id: string;
    }
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;
    req.userId = payload.id;
    next();
  } catch {
    return res.status(401).json({ msg: 'Token inválido' });
  }
};
