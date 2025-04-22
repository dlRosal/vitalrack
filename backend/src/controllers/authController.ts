// src/controllers/authController.ts
import { RequestHandler, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User, { IUser } from '../models/User';

const JWT_SECRET = process.env.JWT_SECRET!;

export const register: RequestHandler = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      res.status(400).json({ msg: 'Faltan datos' });
      return;
    }
    if (await User.findOne({ email })) {
      res.status(409).json({ msg: 'Usuario ya existe' });
      return;
    }
    const user = await User.create({ email, password });
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.status(201).json({ token });
    return;
  } catch (err) {
    next(err);
  }
};

export const login: RequestHandler = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      res.status(400).json({ msg: 'Faltan datos' });
      return;
    }
    const user = (await User.findOne({ email })) as IUser;
    if (!user || !(await user.comparePassword(password))) {
      res.status(401).json({ msg: 'Credenciales inválidas' });
      return;
    }
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
    return;
  } catch (err) {
    next(err);
  }
};
