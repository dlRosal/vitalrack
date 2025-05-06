// src/models/Session.ts
import { Schema, model, Document, Types } from 'mongoose';

export interface IEntry {
  exerciseName: string;
  sets: number;
  reps: number;
  weight: number; // en kg
}

export interface ISession extends Document {
  userId: Types.ObjectId;
  routineId: Types.ObjectId;
  date: Date;
  entries: IEntry[];
  duration: number; // en minutos
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const EntrySchema = new Schema<IEntry>(
  {
    exerciseName: { type: String, required: true },
    sets: { type: Number, required: true },
    reps: { type: Number, required: true },
    weight: { type: Number, required: true },
  },
  { _id: false },
);

const SessionSchema = new Schema<ISession>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    routineId: { type: Schema.Types.ObjectId, ref: 'Routine', required: true },
    date: { type: Date, default: Date.now },
    entries: { type: [EntrySchema], default: [] },
    duration: { type: Number, required: true },
    notes: { type: String },
  },
  { timestamps: true },
);

export default model<ISession>('Session', SessionSchema);
