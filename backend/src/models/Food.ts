// src/models/Food.ts
import { Schema, model, Document } from 'mongoose';

export interface IFood extends Document {
  externalId: string; // ID en la API externa (p.ej. USDA)
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  createdAt: Date;
  updatedAt: Date;
}

const FoodSchema = new Schema<IFood>(
  {
    externalId: { type: String, required: true, unique: true },
    name: { type: String, required: true, index: true },
    calories: { type: Number, required: true },
    protein: { type: Number, required: true },
    carbs: { type: Number, required: true },
    fat: { type: Number, required: true },
  },
  { timestamps: true },
);

// Índices para búsquedas por nombre
FoodSchema.index({ name: 'text' });

export default model<IFood>('Food', FoodSchema);
