const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

let db = {
  productos: [{ id: 1, nombre: 'Laptop', precio: 1200 }, { id: 2, nombre: 'Mouse', precio: 50 }],
  carrito: []
};

app.get('/api/productos', (req, res) => res.json(db.productos));
app.post('/api/carrito', (req, res) => {
  db.carrito.push(req.body);
  res.status(201).json({ status: 'ok', total: db.carrito.length });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date(), node: process.version });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => console.log(`Servidor en puerto ${PORT}`));
}
module.exports = app;