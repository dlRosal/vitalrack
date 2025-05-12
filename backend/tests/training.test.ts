// tests/training.test.ts

// 1) Carga .env y asegúrate de tener un JWT_SECRET para firmar los tokens
import dotenv from 'dotenv';
dotenv.config();
// Si no viene de fuera (ej. en GH Actions), ponemos uno fijo:
process.env.JWT_SECRET = process.env.JWT_SECRET || 'testsecret';

import request from 'supertest';
import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import app from '../src/app';
import User from '../src/models/User';
import Routine from '../src/models/Routine';
import Session from '../src/models/Session';

let mongoServer: MongoMemoryServer;
let token: string;
let routineId: string;

beforeAll(async () => {
  // Arranca un MongoDB en memoria
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());

  // Vacía las colecciones
  await User.deleteMany({});
  await Routine.deleteMany({});
  await Session.deleteMany({});

  // Registra un usuario y obtén el token JWT
  const res = await request(app)
    .post('/auth/register')
    .send({ email: 'test@t.com', password: '123456' });
  token = res.body.token;
});

afterAll(async () => {
  // Cierra conexión y detén Mongo en memoria
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('Training Endpoints', () => {
  it('POST /training/generate debe crear una rutina', async () => {
    const res = await request(app)
      .post('/training/generate')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Full Body', level: 'beginner' });

    expect(res.status).toBe(201);
    expect(res.body.routine).toHaveProperty('_id');
    expect(Array.isArray(res.body.routine.exercises)).toBe(true);
    routineId = res.body.routine._id;
  });

  it('GET /training/routines debe devolver la lista de rutinas', async () => {
    const res = await request(app)
      .get('/training/routines')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.routines.length).toBeGreaterThan(0);
    expect(res.body.routines[0]).toHaveProperty('name', 'Full Body');
  });

  it('POST /training/log debe registrar una sesión', async () => {
    const payload = {
      routineId,
      duration: 45,
      entries: [{ exerciseName: 'Sentadillas', sets: 3, reps: 10, weight: 60 }],
      notes: 'Buena sesión',
    };
    const res = await request(app)
      .post('/training/log')
      .set('Authorization', `Bearer ${token}`)
      .send(payload);

    expect(res.status).toBe(201);
    expect(res.body.session).toHaveProperty('_id');
    expect(res.body.session.duration).toBe(45);
  });

  it('GET /training/sessions debe devolver la lista de sesiones', async () => {
    const res = await request(app)
      .get('/training/sessions')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.sessions.length).toBeGreaterThan(0);
    expect(res.body.sessions[0]).toHaveProperty('notes', 'Buena sesión');
  });
});
