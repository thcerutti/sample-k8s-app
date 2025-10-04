const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para parsing JSON
app.use(express.json());
app.use(cors());
// Rota raiz que retorna "hello from api"
app.get('/', (req, res) => {
  res.json({ message: 'hello from api' });
});

// Middleware para tratamento de erros
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Algo deu errado!' });
});

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`API rodando na porta ${PORT}`);
  console.log(`Acesse: http://localhost:${PORT}`);
});
