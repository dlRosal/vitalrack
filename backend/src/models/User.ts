// src/models/User.ts
import { Schema, model, Document } from 'mongoose';
import bcrypt from 'bcrypt';

export interface IUser extends Document {
  email: string;
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
    password: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

// Índice único (por si quieres más control sobre collation)
UserSchema.index({ email: 1 }, { unique: true, collation: { locale: 'en', strength: 2 } });

/**
 * Antes de guardar, sólo si la contraseña cambió,
 * la hasheamos con bcrypt.
 */
UserSchema.pre<IUser>('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    return next();
  } catch (err) {
    return next(err as Error);
  }
});

/**
 * Compara un candidato contra el hash almacenado.
 */
UserSchema.methods.comparePassword = function (this: IUser, candidate: string) {
  return bcrypt.compare(candidate, this.password);
};

export default model<IUser>('User', UserSchema);
