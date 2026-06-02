import express from 'express'
import axios from 'axios'
import pool from '../db/connection.js'
import { getPayPalAccessToken, PAYPAL_API, httpsAgent } from '../config/paypal.js'
import { generarPDFTransaccion } from '../utils/generarPDF.js'
import { enviarComprobantePago } from '../utils/mailer.js'

const router = express.Router()

// POST /api/paypal/create-order — crear orden de pago en PayPal
router.post('/create-order', async (req, res) => {
  try {
    const { transaccionId } = req.body

    // Obtener datos de la transacción
    const result = await pool.query(`
      SELECT t.*, l.numero, l.precio, p.nombre as plaza_nombre
      FROM transacciones t
      JOIN locales l ON t.local_id = l.id
      JOIN plazas p ON l.plaza_id = p.id
      WHERE t.id = $1
    `, [transaccionId])

    if (!result.rows.length) {
      return res.status(404).json({ error: 'Transacción no encontrada' })
    }

    const transaccion = result.rows[0]
    const accessToken = await getPayPalAccessToken()

    // Crear orden en PayPal
    const orderData = {
      intent: 'CAPTURE',
      purchase_units: [{
        reference_id: `TRANS-${transaccionId}`,
        description: `${transaccion.tipo === 'compra' ? 'Compra' : 'Apartado'} de local ${transaccion.numero} en ${transaccion.plaza_nombre}`,
        amount: {
          currency_code: 'USD',
          value: (parseFloat(transaccion.precio) / 20).toFixed(2) // Convertir MXN a USD aproximadamente
        }
      }],
      application_context: {
        brand_name: 'Plazas Comerciales',
        landing_page: 'NO_PREFERENCE',
        user_action: 'PAY_NOW',
        return_url: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/pago-exitoso?transaccionId=${transaccionId}`,
        cancel_url: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/pago-cancelado?transaccionId=${transaccionId}`
      }
    }

    const response = await axios.post(
      `${PAYPAL_API}/v2/checkout/orders`,
      orderData,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        httpsAgent,
      }
    )

    // Guardar order ID en la transacción
    await pool.query(
      'UPDATE transacciones SET paypal_order_id = $1 WHERE id = $2',
      [response.data.id, transaccionId]
    )

    const approveLink = response.data.links.find(link => link.rel === 'approve').href

    res.json({
      orderID: response.data.id,
      approveLink
    })
  } catch (err) {
    console.error('Error creando orden PayPal:', err.response?.data || err.message)
    res.status(500).json({ error: err.message })
  }
})

// POST /api/paypal/capture-order — capturar pago después de aprobación
router.post('/capture-order', async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { orderID, transaccionId } = req.body

    if (!orderID || !transaccionId) {
      return res.status(400).json({ error: 'Faltan parámetros requeridos' })
    }

    const accessToken = await getPayPalAccessToken()

    // Capturar el pago en PayPal
    const response = await axios.post(
      `${PAYPAL_API}/v2/checkout/orders/${orderID}/capture`,
      {},
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        httpsAgent,
      }
    )

    console.log('PayPal capture response:', JSON.stringify(response.data, null, 2))

    if (response.data.status === 'COMPLETED') {
      const paymentId = response.data.purchase_units[0].payments.captures[0].id

      // Obtener la transacción
      const trans = await client.query(
        'SELECT * FROM transacciones WHERE id = $1',
        [transaccionId]
      )

      if (!trans.rows.length) {
        throw new Error('Transacción no encontrada')
      }

      const t = trans.rows[0]

      // Verificar si ya fue procesada
      if (t.estado_pago === 'completado') {
        await client.query('COMMIT')
        return res.json({
          success: true,
          message: 'Pago ya fue procesado anteriormente',
          paymentId: t.paypal_payment_id,
          estado: t.tipo === 'compra' ? 'vendido' : 'apartado'
        })
      }

      // Actualizar transacción a completada
      await client.query(`
        UPDATE transacciones
        SET estado_pago='completado',
            paypal_payment_id=$1,
            completed_at=CURRENT_TIMESTAMP
        WHERE id=$2
      `, [paymentId, transaccionId])

      // Actualizar estado del local
      const nuevoEstado = t.tipo === 'compra' ? 'vendido' : 'apartado'
      await client.query(
        'UPDATE locales SET estado=$1, updated_at=CURRENT_TIMESTAMP WHERE id=$2',
        [nuevoEstado, t.local_id]
      )

      await client.query('COMMIT')

      // Enviar correo con PDF adjunto (no bloqueante)
      pool.query(`
        SELECT t.id, t.tipo, t.monto, t.estado_pago, t.paypal_payment_id,
               t.duracion_apartado_dias, t.porcentaje_apartado, t.fecha_vencimiento_apartado,
               t.created_at, t.completed_at,
               l.numero AS local_numero, l.area, l.precio AS precio_compra,
               p.nombre AS plaza_nombre, p.ubicacion AS plaza_ubicacion,
               c.nombre AS cliente_nombre, c.email AS cliente_email, c.telefono AS cliente_telefono
        FROM transacciones t
        JOIN locales l ON l.id = t.local_id
        JOIN plazas p ON p.id = l.plaza_id
        JOIN clientes c ON c.id = t.cliente_id
        WHERE t.id = $1
      `, [transaccionId]).then(r => {
        if (r.rows.length) {
          enviarComprobantePago(r.rows[0]).catch(console.error)
        }
      }).catch(console.error)

      res.json({
        success: true,
        message: 'Pago completado exitosamente',
        paymentId,
        estado: nuevoEstado
      })
    } else {
      throw new Error(`El pago no se completó. Estado: ${response.data.status}`)
    }
  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Error capturando orden PayPal:', err.response?.data || err.message)
    
    // Manejar errores específicos de PayPal
    if (err.response?.status === 422) {
      const paypalError = err.response.data
      console.error('PayPal 422 Error:', JSON.stringify(paypalError, null, 2))
      
      // Si la orden ya fue capturada, verificar en la BD
      if (paypalError.details?.[0]?.issue === 'ORDER_ALREADY_CAPTURED') {
        const trans = await client.query(
          'SELECT * FROM transacciones WHERE id = $1 AND estado_pago = $2',
          [req.body.transaccionId, 'completado']
        )
        
        if (trans.rows.length) {
          await client.query('COMMIT')
          return res.json({
            success: true,
            message: 'Pago ya fue procesado',
            paymentId: trans.rows[0].paypal_payment_id,
            estado: trans.rows[0].tipo === 'compra' ? 'vendido' : 'apartado'
          })
        }
      }
      
      return res.status(422).json({ 
        error: 'Error de PayPal: ' + (paypalError.message || 'Orden inválida o ya procesada'),
        details: paypalError.details
      })
    }
    
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

export default router
