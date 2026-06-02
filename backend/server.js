import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import plazasRoutes from './routes/plazas.js';
import localesRoutes from './routes/locales.js';
import transaccionesRoutes from './routes/transacciones.js';
import paypalRoutes from './routes/paypal.js';
import authRoutes from './routes/auth.js';
import adminRoutes from './routes/admin.js';
import usuarioRoutes from './routes/usuario.js';
import pdfRoutes from './routes/pdf.js';
import floorsRoutes from './routes/floors.js';
import solicitudesRoutes from './routes/solicitudes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.use('/api/plazas', plazasRoutes);
app.use('/api/locales', localesRoutes);
app.use('/api/transacciones', transaccionesRoutes);
app.use('/api/paypal', paypalRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/usuario', usuarioRoutes);
app.use('/api/pdf', pdfRoutes);
app.use('/api/floors', floorsRoutes);
app.use('/api/solicitudes', solicitudesRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API funcionando correctamente' });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});
