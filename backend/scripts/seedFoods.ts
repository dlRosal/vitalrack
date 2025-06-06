import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Food, { IFood } from '../src/models/Food';

dotenv.config();

const foods = [
  // Proteinas magras
  { externalId: 'pechuga-pollo', name: 'Pechuga de pollo (sin piel)', calories: 110, protein: 23, carbs: 0, fat: 1.5 },
  { externalId: 'pavo-pechuga', name: 'Pavo (pechuga sin piel)', calories: 105, protein: 22, carbs: 0, fat: 1.2 },
  { externalId: 'ternera-magra', name: 'Carne magra de ternera', calories: 140, protein: 21, carbs: 0, fat: 5 },
  { externalId: 'solomillo-cerdo-magra', name: 'Solomillo de cerdo magro', calories: 142, protein: 20, carbs: 0, fat: 6 },
  { externalId: 'salmon-filete', name: 'Filete de salm\u00f3n', calories: 208, protein: 20, carbs: 0, fat: 13 },
  { externalId: 'atun-lata-natural', name: 'At\u00fan en lata (al natural)', calories: 116, protein: 26, carbs: 0, fat: 1 },
  { externalId: 'bacalao-fresco', name: 'Bacalao fresco', calories: 82, protein: 18, carbs: 0, fat: 0.7 },
  { externalId: 'claras-huevo', name: 'Claras de huevo', calories: 52, protein: 11, carbs: 0.7, fat: 0.2 },
  { externalId: 'huevo-entero', name: 'Huevo entero', calories: 72, protein: 6.3, carbs: 0.4, fat: 4.8 },
  { externalId: 'requeson-bajo-grasa', name: 'Reques\u00f3n bajo en grasa', calories: 98, protein: 11.1, carbs: 3.4, fat: 4.3 },
  { externalId: 'queso-fresco-batido', name: 'Queso fresco batido 0 % M.G.', calories: 65, protein: 8.5, carbs: 3.0, fat: 0.3 },
  { externalId: 'yogur-griego-0', name: 'Yogur griego 0 % M.G.', calories: 59, protein: 10.2, carbs: 3.6, fat: 0.4 },
  { externalId: 'pechuga-pavo-loncheada', name: 'Pechuga de pavo loncheada', calories: 104, protein: 17.8, carbs: 1.6, fat: 3.0 },
  { externalId: 'carne-picada-pollo', name: 'Carne picada de pollo (magro)', calories: 120, protein: 22, carbs: 0, fat: 3 },
  { externalId: 'lomo-cerdo-magra', name: 'Lomo de cerdo magro', calories: 142, protein: 21.7, carbs: 0, fat: 5 },
  { externalId: 'merluza', name: 'Pescado blanco (merluza)', calories: 75, protein: 16.5, carbs: 0, fat: 0.7 },
  { externalId: 'pechuga-pato', name: 'Pechuga de pato sin piel', calories: 151, protein: 23.7, carbs: 0, fat: 5.4 },
  { externalId: 'whey', name: 'Prote\u00edna de suero (whey)', calories: 120, protein: 24, carbs: 2, fat: 1.5 },
  { externalId: 'tofu-firme', name: 'Tofu firme', calories: 76, protein: 8, carbs: 1.9, fat: 4.8 },
  { externalId: 'tempeh', name: 'Tempeh', calories: 193, protein: 19, carbs: 9.4, fat: 10.8 },
  // Hidratos de carbono
  { externalId: 'arroz-integral-cocido', name: 'Arroz integral cocido', calories: 111, protein: 2.6, carbs: 23, fat: 0.9 },
  { externalId: 'arroz-blanco-cocido', name: 'Arroz blanco cocido', calories: 130, protein: 2.4, carbs: 28.2, fat: 0.3 },
  { externalId: 'avena-cruda', name: 'Avena (cruda)', calories: 389, protein: 16.9, carbs: 66.3, fat: 6.9 },
  { externalId: 'avena-cocida', name: 'Avena cocida', calories: 72, protein: 2.5, carbs: 12, fat: 1.4 },
  { externalId: 'quinoa-cocida', name: 'Quinoa cocida', calories: 120, protein: 4.4, carbs: 21.3, fat: 1.9 },
  { externalId: 'patata-cocida', name: 'Patata cocida', calories: 87, protein: 2, carbs: 20.1, fat: 0.1 },
  { externalId: 'boniato-cocido', name: 'Boniato cocido', calories: 86, protein: 1.6, carbs: 20.1, fat: 0.1 },
  { externalId: 'pan-integral', name: 'Pan integral', calories: 75, protein: 3, carbs: 12.5, fat: 1.0 },
  { externalId: 'pan-centeno', name: 'Pan de centeno integral', calories: 69, protein: 2.5, carbs: 12.0, fat: 0.8 },
  { externalId: 'pasta-integral-cocida', name: 'Pasta integral cocida', calories: 124, protein: 5, carbs: 25, fat: 1.0 },
  { externalId: 'cuscus-integral-cocido', name: 'Cusc\u00fas integral cocido', calories: 112, protein: 3.8, carbs: 23.2, fat: 0.2 },
  { externalId: 'pan-espelta-integral', name: 'Pan de espelta integral', calories: 80, protein: 3.2, carbs: 13, fat: 1.2 },
  { externalId: 'tortillas-maiz', name: 'Tortillas de ma\u00edz', calories: 56, protein: 1.6, carbs: 12, fat: 0.7 },
  { externalId: 'platano', name: 'Pl\u00e1tano', calories: 105, protein: 1.3, carbs: 27, fat: 0.3 },
  { externalId: 'manzana', name: 'Manzana', calories: 95, protein: 0.5, carbs: 25.1, fat: 0.3 },
  { externalId: 'pera', name: 'Pera', calories: 101, protein: 0.6, carbs: 27, fat: 0.3 },
  { externalId: 'fresas', name: 'Fresas', calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3 },
  { externalId: 'arandanos', name: 'Ar\u00e1ndanos', calories: 57, protein: 0.7, carbs: 14.5, fat: 0.3 },
  { externalId: 'mango', name: 'Mango', calories: 60, protein: 0.8, carbs: 15, fat: 0.4 },
  { externalId: 'pina-fresca', name: 'Pi\u00f1a fresca', calories: 50, protein: 0.5, carbs: 13, fat: 0.1 },
  { externalId: 'avena-copos', name: 'Avena en copos', calories: 379, protein: 16.7, carbs: 66.3, fat: 6.5 },
  { externalId: 'trigo-sarraceno', name: 'Trigo sarraceno cocido', calories: 92, protein: 3.4, carbs: 19.9, fat: 0.6 },
  { externalId: 'harina-avena', name: 'Harina de avena', calories: 389, protein: 16.9, carbs: 66.3, fat: 6.9 },
  { externalId: 'harina-almendra', name: 'Harina de almendra', calories: 579, protein: 21.2, carbs: 21.7, fat: 50.6 },
  // Verduras y hortalizas
  { externalId: 'brocoli', name: 'Br\u00f3coli', calories: 34, protein: 2.8, carbs: 6.6, fat: 0.4 },
  { externalId: 'espinacas', name: 'Espinacas', calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4 },
  { externalId: 'calabacin', name: 'Calabac\u00edn', calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3 },
  { externalId: 'pimiento-rojo', name: 'Pimiento rojo', calories: 31, protein: 1.0, carbs: 6.0, fat: 0.3 },
  { externalId: 'pimiento-verde', name: 'Pimiento verde', calories: 20, protein: 0.9, carbs: 4.6, fat: 0.2 },
  { externalId: 'lechuga-romana', name: 'Lechuga romana', calories: 17, protein: 1.2, carbs: 3.3, fat: 0.3 },
  { externalId: 'pepino', name: 'Pepino', calories: 16, protein: 0.7, carbs: 3.6, fat: 0.1 },
  { externalId: 'champinones', name: 'Champi\u00f1ones blancos', calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3 },
  { externalId: 'berenjena', name: 'Berenjena', calories: 25, protein: 1.0, carbs: 5.9, fat: 0.2 },
  { externalId: 'tomate', name: 'Tomate', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2 },
  { externalId: 'zanahoria', name: 'Zanahoria', calories: 41, protein: 0.9, carbs: 9.6, fat: 0.2 },
  { externalId: 'esparragos', name: 'Esp\u00e1rragos', calories: 20, protein: 2.2, carbs: 3.9, fat: 0.1 },
  { externalId: 'coliflor', name: 'Coliflor', calories: 25, protein: 1.9, carbs: 4.9, fat: 0.3 },
  { externalId: 'kale', name: 'Kale (col rizada)', calories: 49, protein: 4.3, carbs: 8.8, fat: 0.9 },
  { externalId: 'judias-verdes', name: 'Jud\u00edas verdes', calories: 31, protein: 1.8, carbs: 7.1, fat: 0.1 },
  { externalId: 'apio', name: 'Apio', calories: 16, protein: 0.7, carbs: 3.0, fat: 0.2 },
  // Grasas saludables
  { externalId: 'aceite-oliva', name: 'Aceite de oliva virgen extra', calories: 119, protein: 0, carbs: 0, fat: 13.5 },
  { externalId: 'aceite-coco', name: 'Aceite de coco', calories: 121, protein: 0, carbs: 0, fat: 13.5 },
  { externalId: 'aguacate', name: 'Aguacate', calories: 160, protein: 2, carbs: 8.5, fat: 15 },
  { externalId: 'almendras', name: 'Almendras', calories: 579, protein: 21.2, carbs: 21.6, fat: 49.4 },
  { externalId: 'nueces', name: 'Nueces', calories: 654, protein: 15.2, carbs: 13.7, fat: 65.2 },
  { externalId: 'anacardos', name: 'Anacardos', calories: 553, protein: 18.2, carbs: 30.2, fat: 43.9 },
  { externalId: 'semillas-chia', name: 'Semillas de ch\u00eda', calories: 486, protein: 16.5, carbs: 42.1, fat: 30.7 },
  { externalId: 'semillas-lino', name: 'Semillas de lino', calories: 534, protein: 18.3, carbs: 28.9, fat: 42.2 },
  { externalId: 'mantequilla-mani', name: 'Mantequilla de man\u00ed', calories: 94, protein: 3.6, carbs: 3.2, fat: 8.1 },
  { externalId: 'mantequilla-almendra', name: 'Mantequilla de almendra', calories: 98, protein: 2.1, carbs: 3.1, fat: 8.5 },
  { externalId: 'pipas-girasol', name: 'Pipas de girasol', calories: 584, protein: 20.8, carbs: 20, fat: 51.5 },
  { externalId: 'aceite-lino', name: 'Aceite de lino', calories: 126, protein: 0, carbs: 0, fat: 14 },
  // Frutas adicionales
  { externalId: 'naranja', name: 'Naranja', calories: 62, protein: 1.2, carbs: 15.4, fat: 0.2 },
  { externalId: 'mandarina', name: 'Mandarina', calories: 47, protein: 0.7, carbs: 12, fat: 0.3 },
  { externalId: 'melon', name: 'Mel\u00f3n', calories: 34, protein: 0.8, carbs: 8.2, fat: 0.2 },
  { externalId: 'sandia', name: 'Sand\u00eda', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2 },
  { externalId: 'kiwi', name: 'Kiwi', calories: 61, protein: 1.1, carbs: 14.7, fat: 0.5 },
  { externalId: 'uvas', name: 'Uvas', calories: 69, protein: 0.7, carbs: 18.1, fat: 0.2 },
  // Snacks y aperitivos
  { externalId: 'yogur-griego-natural', name: 'Yogur griego natural 0 % M.G.', calories: 89, protein: 15.3, carbs: 4.5, fat: 0.6 },
  { externalId: 'requeson-0', name: 'Reques\u00f3n 0 % M.G.', calories: 98, protein: 11.1, carbs: 3.4, fat: 4.3 },
  { externalId: 'queso-fresco-batido-snack', name: 'Queso fresco batido 0 % M.G.', calories: 65, protein: 8.5, carbs: 3.0, fat: 0.3 },
  { externalId: 'tostadas-integrales', name: 'Tostadas integrales', calories: 155, protein: 6, carbs: 27, fat: 3 },
  { externalId: 'tortitas-arroz', name: 'Tortitas de arroz integral', calories: 70, protein: 1.4, carbs: 14.6, fat: 0.5 },
  { externalId: 'barrita-proteina', name: 'Barrita de prote\u00edna baja en az\u00facar', calories: 200, protein: 20, carbs: 18, fat: 7 },
  { externalId: 'tortitas-maiz-salvado', name: 'Tortitas de ma\u00edz (salvado)', calories: 65, protein: 1.3, carbs: 14.2, fat: 0.7 },
  { externalId: 'galletas-integrales', name: 'Galletas integrales sin az\u00facar', calories: 120, protein: 2, carbs: 20, fat: 4 },
  { externalId: 'hummus-casero', name: 'Hummus casero', calories: 166, protein: 8, carbs: 14.3, fat: 9.6 },
  { externalId: 'zanahoria-hummus', name: 'Palitos de zanahoria + hummus', calories: 95, protein: 2.9, carbs: 10.4, fat: 4.1 },
  { externalId: 'edamame-cocido', name: 'Edamame cocido', calories: 121, protein: 11.9, carbs: 8.9, fat: 5.2 },
  { externalId: 'yogur-proteico-frutos-rojos', name: 'Yogur proteico con frutos del bosque', calories: 100, protein: 16, carbs: 8, fat: 0.5 },
  { externalId: 'mix-frutos-secos', name: 'Mix de frutos secos', calories: 180, protein: 4.5, carbs: 4, fat: 16 },
  { externalId: 'crackers-integrales', name: 'Crackers integrales', calories: 130, protein: 3, carbs: 18, fat: 4.5 },
  { externalId: 'tostada-aguacate', name: 'Tostada integral con aguacate', calories: 140, protein: 2.5, carbs: 12.7, fat: 9 },
  { externalId: 'batido-proteina', name: 'Batido de prote\u00edna (whey + agua)', calories: 120, protein: 24, carbs: 2, fat: 1.5 },
];

(async () => {
  const uri = process.env.MONGO_URI;
  if (!uri) {
    console.error('MONGO_URI no definido en .env');
    process.exit(1);
  }

  try {
    const conn = await mongoose.connect(uri);
    console.log(`Conectado a ${conn.connection.name}`);

    for (const food of foods) {
      await Food.findOneAndUpdate({ externalId: food.externalId }, food, { upsert: true });
    }

    console.log(`Se insertaron/actualizaron ${foods.length} alimentos`);
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();