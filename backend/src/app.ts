// src/app.ts
import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response } from 'express';
import cors from 'cors';
import authRouter from './routes/auth';
import nutritionRouter from './routes/nutrition';
import trainingRouter from './routes/training';

const app = express();

const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:3000';

app.use(
  cors({
    origin: (origin, cb) => {
      // 1) permitir si es sin Origin (ej: curl o server‐to‐server)
      // 2) o si coincide exactamente con tu frontend
      if (!origin || origin === FRONTEND_URL) {
        cb(null, true);
      } else {
        cb(new Error(`Origen ${origin} no permitido`), false);
      }
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  }),
);

// Responder preflight para **todas** las rutas
app.options('*', cors());

// Parse JSON bodies
app.use(express.json());

// Rutas
app.use('/auth', authRouter);
app.use('/nutrition', nutritionRouter);
app.use('/training', trainingRouter);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ msg: 'Ruta no encontrada' });
});

// Error handler
interface HttpError extends Error {
  status?: number;
}
app.use((err: HttpError, req: Request, res: Response) => {
  console.error(err);
  const status = err.status ?? 500;
  const message = err.message || 'Error interno del servidor';
  res.status(status).json({ msg: message });
});

export default app;
