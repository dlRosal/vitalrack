// src/app.ts
import express, { Request, Response, NextFunction } from 'express';
import authRouter from './routes/auth';
import nutritionRouter from './routes/nutrition';
import trainingRouter from './routes/training';

const app = express();

// Parse JSON bodies
app.use(express.json());

// Rutas públicas de autenticación
app.use('/auth', authRouter);

// Rutas de nutrición (search público, /log protegido por requireAuth dentro de nutritionRouter)
app.use('/nutrition', nutritionRouter);

// Middleware global de manejo de errores
app.use(
  (err: any, req: Request, res: Response, next: NextFunction) => {
    console.error(err);
    res.status(500).json({ msg: 'Error interno del servidor' });
  }
);

app.use('/training', trainingRouter);

export default app;
