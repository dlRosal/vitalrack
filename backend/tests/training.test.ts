// tests/training.test.ts
import request from 'supertest';
import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import app from '../src/app';
import User from '../src/models/User';
import Routine from '../src/models/Routine';
import Session from '../src/models/Session';

let mongoServer: MongoMemoryServer | null = null;
let token: string;
let routineId: string;

beforeAll(async () => {
  // Usa la URI de CI si existe, sino levanta un in‐memory server:
  const mongoUri = process.env.MONGO_URI
    ? process.env.MONGO_URI
    : (await (mongoServer = await MongoMemoryServer.create())).getUri();

  await mongoose.connect(mongoUri);

  // Limpia colecciones
  await User.deleteMany({});
  await Routine.deleteMany({});
  await Session.deleteMany({});

  // Registra user y obtén token
  const res = await request(app)
    .post('/auth/register')
    .send({ email: 'test@t.com', password: '123456' });
  token = res.body.token;
});

afterAll(async () => {
  await mongoose.disconnect();
  // Sólo detén el in‐memory server si lo levantaste
  if (mongoServer) {
    await mongoServer.stop();
  }
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
