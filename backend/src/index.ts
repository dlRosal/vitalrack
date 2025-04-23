// src/index.ts
import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import app from './app';

mongoose.set('strictQuery', true);

const PORT = process.env.PORT || 4000;
mongoose
  .connect(process.env.MONGO_URI!)
  .then(() => {
    console.log('MongoDB conectado');
    app.listen(PORT, () => console.log(`Server en puerto ${PORT}`));
  })
  .catch((err) => {
    console.error('Error MongoDB:', err);
    process.exit(1);
  });
