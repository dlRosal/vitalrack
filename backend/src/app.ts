// src/app.ts
import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response } from 'express';
import cors from 'cors';
import authRouter from './routes/auth';
import nutritionRouter from './routes/nutrition';
import trainingRouter from './routes/training';

const app = express();

// CORS: en prod lee FRONTEND_URL de .env, en dev permite cualquiera
const FRONTEND_URL = process.env.FRONTEND_URL ?? 'http://localhost:3000';
app.use(
  cors({
    origin: (incomingOrigin, callback) => {
      if (process.env.NODE_ENV !== 'production' || incomingOrigin === FRONTEND_URL) {
        callback(null, true);
      } else {
        callback(new Error('Origen no permitido'), false);
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
