// backend/src/models/History.ts
import mongoose, { Schema, Document, Types } from 'mongoose';

/**
 * Interfaz que describe un documento de historial de consumo.
 */
export interface HistoryDocument extends Document {
  user: Types.ObjectId; // Referencia al usuario que registró el consumo
  food: Types.ObjectId; // Referencia al alimento consumido
  quantity: number; // Cantidad consumida
  consumedAt: Date; // Fecha y hora del consumo
}

/**
 * Esquema de Mongoose para el historial de consumos.
 */
const HistorySchema = new Schema<HistoryDocument>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User', // Asegúrate de que tu modelo de usuario se llame 'User'
      required: true,
    },
    food: {
      type: Schema.Types.ObjectId,
      ref: 'Food', // Referencia al modelo de alimentos
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: [1, 'La cantidad debe ser al menos 1'],
    },
    consumedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true, // Crea createdAt y updatedAt automáticamente
    collection: 'histories', // Nombre explícito de la colección (opcional)
  },
);

/**
 * Modelo de Mongoose para el historial de consumos.
 */
const HistoryModel = mongoose.model<HistoryDocument>('History', HistorySchema);
export default HistoryModel;
