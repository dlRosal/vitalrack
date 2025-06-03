// backend/src/models/User.ts
import { Schema, model, Document } from 'mongoose';
import bcrypt from 'bcrypt';

export interface IUser extends Document {
  email: string;
  username?: string;
  gender?: 'male' | 'female' | 'other';
  age?: number;
  height?: number; // en centímetros, p. ej.
  weight?: number; // en kilogramos, p. ej.
  password: string;
  comparePassword(candidate: string): Promise<boolean>;
}

const UserSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    username: {
      type: String,
      required: false,
      trim: true,
      default: '',
    },
    gender: {
      type: String,
      required: false,
      enum: ['male', 'female', 'other'],
    },
    age: {
      type: Number,
      required: false,
      min: 0,
    },
    height: {
      type: Number,
      required: false,
      min: 0,
    },
    weight: {
      type: Number,
      required: false,
      min: 0,
    },
    password: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

// Índice único en email
UserSchema.index({ email: 1 }, { unique: true, collation: { locale: 'en', strength: 2 } });

// Antes de guardar, hashear la contraseña si cambió
UserSchema.pre<IUser>('save', async function (next) {
  if (!this.isModified('password')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    return next();
  } catch (err) {
    return next(err as Error);
  }
});

// Método para comparar contraseñas
UserSchema.methods.comparePassword = function (this: IUser, candidate: string) {
  return bcrypt.compare(candidate, this.password);
};

export default model<IUser>('User', UserSchema);
