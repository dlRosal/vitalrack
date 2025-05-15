// src/app.ts
import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import authRouter from './routes/auth';
import nutritionRouter from './routes/nutrition';
import trainingRouter from './routes/training';

const app = express();

app.use(
  cors({
    origin: 'https://vitalrack.netlify.app', // o '*' durante desarrollo
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  }),
);

// Parse JSON bodies
app.use(express.json());

// Routes
app.use('/auth', authRouter);
app.use('/nutrition', nutritionRouter);
app.use('/training', trainingRouter);

// 404 handler — firma de 3 parámetros
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((req: Request, res: Response, _next: NextFunction) => {
  res.status(404).json({ msg: 'Ruta no encontrada' });
});

interface HttpError extends Error {
  status?: number;
}

// Error handler — firma de 4 parámetros
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: HttpError, req: Request, res: Response, _next: NextFunction) => {
  console.error(err);
  const status = err.status ?? 500;
  const message = err.message || 'Error interno del servidor';
  res.status(status).json({ msg: message });
});

export default app;
