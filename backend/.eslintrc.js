export default {
  root: true,
  parser: '@typescript-eslint/parser',
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended', 'prettier'],
  plugins: ['@typescript-eslint', 'prettier'],
  parserOptions: { ecmaVersion: 2020, sourceType: 'module' },
  rules: {
    'prettier/prettier': ['error', { endOfLine: 'auto' }],
  },
};
