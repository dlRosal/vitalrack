// src/app.ts
import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response, NextFunction } from 'express';
import authRouter from './routes/auth';
import nutritionRouter from './routes/nutrition';
import trainingRouter from './routes/training';

const app = express();

// Parse JSON bodies
app.use(express.json());

// Routes
app.use('/auth', authRouter);
app.use('/nutrition', nutritionRouter);
app.use('/training', trainingRouter);

// Global error handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  console.error(err);
  res.status(500).json({ msg: 'Error interno del servidor' });
});

export default app;

