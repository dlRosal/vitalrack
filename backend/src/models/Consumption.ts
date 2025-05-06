import { Schema, model, Document, Types } from 'mongoose';

export interface IConsumption extends Document {
  userId: Types.ObjectId;
  foodId: Types.ObjectId;
  quantity: number; // por ejemplo en gramos
  date: Date;
}

const ConsumptionSchema = new Schema<IConsumption>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    foodId: { type: Schema.Types.ObjectId, ref: 'Food', required: true },
    quantity: { type: Number, required: true },
    date: { type: Date, default: Date.now },
  },
  { timestamps: true },
);

export default model<IConsumption>('Consumption', ConsumptionSchema);
