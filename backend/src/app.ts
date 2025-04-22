// src/app.ts
import express from 'express';
import dotenv from 'dotenv';
import authRouter from './routes/auth';

dotenv.config();
const app = express();
app.use(express.json());

// Rutas públicas
app.use('/auth', authRouter);

export default app;
