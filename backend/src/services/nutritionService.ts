// src/services/nutritionService.ts
import Food, { IFood } from '../models/Food';

// Datos de ejemplo mientras no tengas una API accesible
const MOCK_DATA: IFood[] = [
  new Food({
    externalId: 'mock-1',
    name: 'Manzana (mock)',
    calories: 52,
    protein: 0.3,
    carbs: 14,
    fat: 0.2
  }),
  new Food({
    externalId: 'mock-2',
    name: 'Plátano (mock)',
    calories: 89,
    protein: 1.1,
    carbs: 23,
    fat: 0.3
  })
];

export const searchFoods = async (query: string): Promise<IFood[]> => {
  // 1) Comprueba cache local
  const cached = await Food.find({ $text: { $search: query } }).limit(10);
  if (cached.length) {
    console.log(`Devolviendo ${cached.length} items desde cache`);
    return cached;
  }

  // 2) Fallback: devuelve datos mock y los guarda en cache
  console.warn('Usando datos de prueba para búsqueda de nutrición');
  const docs = [];
  for (const f of MOCK_DATA) {
    const doc = await Food.findOneAndUpdate(
      { externalId: f.externalId },
      { ...f.toObject() },
      { upsert: true, new: true }
    );
    docs.push(doc);
  }
  return docs;
};
