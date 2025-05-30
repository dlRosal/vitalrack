// src/index.ts
import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import app from './app';

const { MONGO_URI, PORT = '4000' } = process.env;

if (!MONGO_URI) {
  console.error('❌  La variable MONGO_URI no está definida en el .env');
  process.exit(1);
}

// Opciones recomendadas (aunque mongoose >=7 las aplica por defecto)
const mongooseOpts = {
  dbName: 'vitalrack-dev', // opcional, si quieres forzar un nombre distinto
  // autoIndex: true,           // crea índices automáticamente (útil en dev)
  // serverSelectionTimeoutMS: 5000,
  // socketTimeoutMS: 45000,
};

mongoose.set('strictQuery', true);

mongoose
  .connect(MONGO_URI, mongooseOpts)
  .then((conn) => {
    console.log(`✅ MongoDB conectado a: ${conn.connection.name}`);
    // Solo arrancamos el servidor cuando la DB esté lista:
    app.listen(Number(PORT), () => console.log(`🚀 Server corriendo en puerto ${PORT}`));
  })
  .catch((err) => {
    console.error('❌ Error al conectar a MongoDB:', err);
    process.exit(1);
  });
