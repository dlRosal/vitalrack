# 🧠 VitalRack

**VitalRack** es una plataforma integral de seguimiento de **nutrición** y **entrenamiento físico**. Permite a los usuarios registrar sus hábitos alimenticios, rutinas de ejercicio y progreso general con una interfaz moderna y fluida. Su diseño modular y enfoque API-first facilitan la integración y el despliegue.

---

## 📁 Estructura del Proyecto

```
vitalrack-main/
├── backend/              # API REST en Node.js + TypeScript
│   ├── src/
│   │   ├── controllers/  # Lógica de control para nutrición, entrenos, auth
│   │   ├── models/       # Modelos de datos (Mongoose)
│   │   ├── routes/       # Endpoints organizados
│   │   ├── services/     # Lógica de negocio
│   │   └── middlewares/  # Middlewares como auth
│   ├── package.json
│   └── tsconfig.json
├── .github/              # Workflows de CI/CD con GitHub Actions
├── netlify.toml          # Configuración de despliegue
└── README.md             # Este archivo
```

---

## ⚙️ Tecnologías Utilizadas

### 🔧 Backend
- Node.js + Express
- TypeScript
- MongoDB + Mongoose
- JWT (JSON Web Tokens)
- Jest (testing)
- ESLint + Prettier (estilo y formato)

### 🚀 DevOps & Deploy
- GitHub Actions (CI/CD)
- Netlify

---

## 🧩 Funcionalidades

- 🔐 Registro y login de usuarios
- 🔑 Autenticación y autorización con JWT
- 🥗 Gestión de alimentos y consumos diarios
- 🏋️‍♂️ Registro de sesiones de entrenamiento
- 📊 Historial personalizado del progreso
- 🔄 Migraciones iniciales para índices y configuraciones

---

## 🚀 Cómo ejecutar el proyecto

### ✅ Requisitos previos

- Node.js 18+
- MongoDB local o MongoDB Atlas
- Git

### 🔄 Clonar repositorio

```bash
git clone https://github.com/tu-usuario/vitalrack.git
cd vitalrack/backend
```

### 📦 Instalar dependencias

```bash
npm install
```

### 🛠️ Crear archivo `.env`

Dentro de la carpeta `backend`, crea un archivo `.env` con el siguiente contenido:

```
PORT=3000
MONGO_URI=mongodb://localhost:27017/vitalrack
JWT_SECRET=clave_super_secreta
```

### ▶️ Ejecutar el servidor en desarrollo

```bash
npm run dev
```

La API estará disponible en: [http://localhost:3000](http://localhost:3000)

---

## 🧪 Ejecutar Tests

```bash
npm run test
```

---

## 🔁 Integración Continua (CI)

El proyecto incluye Workflows para:

- Linting con ESLint
- Tests automáticos con Jest
- CI para el frontend Flutter (si está disponible)
- Despliegue a Netlify

> Los workflows están ubicados en `.github/workflows`.

---

## 👤 Autor

Desarrollado con ❤️ por dlRosal (https://github.com/dlRosal)

---

## 📝 Licencia

Distribuido bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

## 🤝 Contribuciones

¡Toda ayuda es bienvenida! Puedes colaborar abriendo issues, haciendo pull requests o proponiendo nuevas funcionalidades.
