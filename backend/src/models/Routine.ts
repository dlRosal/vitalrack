// src/models/Routine.ts
import { Schema, model, Document, Types } from 'mongoose';

export interface IExercise {
  name: string;
  sets: number;
  reps: number;
  restSec: number;
}

export interface IRoutine extends Document {
  userId: Types.ObjectId;
  name: string;
  exercises: IExercise[];
  createdAt: Date;
  updatedAt: Date;
}

const ExerciseSchema = new Schema<IExercise>(
  {
    name: { type: String, required: true },
    sets: { type: Number, required: true },
    reps: { type: Number, required: true },
    restSec: { type: Number, required: true },
  },
  { _id: false },
);

const RoutineSchema = new Schema<IRoutine>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    name: { type: String, required: true },
    exercises: { type: [ExerciseSchema], default: [] },
  },
  { timestamps: true },
);

export default model<IRoutine>('Routine', RoutineSchema);
