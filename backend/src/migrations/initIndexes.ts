// src/migrations/initIndexes.ts
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Food from '../models/Food';

dotenv.config();
mongoose
  .connect(process.env.MONGO_URI!)
  .then(async () => {
    console.log('Conectado a Mongo, creando índices...');
    await Food.init(); // fuerza creación de índices definidos en el esquema
    console.log('Índices de Food creados');
    process.exit(0);
  })
  .catch((err) => {
    console.error('Error migraciones:', err);
    process.exit(1);
  });
