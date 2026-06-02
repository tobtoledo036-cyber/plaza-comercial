import PDFDocument from 'pdfkit'

const POLITICAS_COMPRA = `
POLÍTICAS DE COMPRA Y APARTADO

1. COMPRA
   • El pago total del precio de compra es requerido para formalizar la adquisición del local.
   • Una vez completado el pago, el local queda registrado a nombre del comprador.
   • No se aceptan devoluciones una vez firmado el contrato de compraventa.
   • El comprador recibirá escrituras en un plazo máximo de 30 días hábiles.

2. APARTADO
   • El apartado garantiza la reserva exclusiva del local por el tiempo acordado.
   • El porcentaje pagado en el apartado se descuenta del precio final de compra.
   • Si el cliente no formaliza la compra antes del vencimiento, el apartado se cancela
     y el monto pagado no es reembolsable.
   • El local regresa a disponible al vencimiento del apartado sin compra formalizada.

3. PAGOS
   • Todos los pagos se procesan a través de PayPal de forma segura.
   • Los precios están expresados en MXN (Pesos Mexicanos).
   • Se emite comprobante de pago por cada transacción completada.

4. CONTACTO
   • Para dudas o aclaraciones comuníquese al correo: contacto@plazascomerciales.mx
   • Horario de atención: Lunes a Viernes de 9:00 a 18:00 hrs.
`

export function generarPDFTransaccion(transaccion, stream) {
  const doc = new PDFDocument({ margin: 50, size: 'A4' })
  doc.pipe(stream)

  const PURPLE = '#7c3aed'
  const DARK   = '#1a1a2e'
  const GRAY   = '#6b7280'

  // ── Encabezado ──────────────────────────────────────────────
  doc.rect(0, 0, doc.page.width, 100).fill(DARK)

  doc.fillColor('#ffffff')
     .fontSize(22)
     .font('Helvetica-Bold')
     .text('PLAZAS COMERCIALES', 50, 30)

  doc.fontSize(11)
     .font('Helvetica')
     .text('Estado de México', 50, 58)
     .text('contacto@plazascomerciales.mx', 50, 72)

  // Tipo de documento
  const tipoDoc = transaccion.tipo === 'compra' ? 'COMPROBANTE DE COMPRA' : 'COMPROBANTE DE APARTADO'
  doc.fillColor(PURPLE)
     .fontSize(13)
     .font('Helvetica-Bold')
     .text(tipoDoc, 0, 35, { align: 'right', width: doc.page.width - 50 })

  doc.fillColor('#ffffff')
     .fontSize(10)
     .font('Helvetica')
     .text(`Folio: #${String(transaccion.id).padStart(6, '0')}`, 0, 55, { align: 'right', width: doc.page.width - 50 })
     .text(`Fecha: ${new Date(transaccion.created_at || Date.now()).toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' })}`, 0, 70, { align: 'right', width: doc.page.width - 50 })

  doc.moveDown(4)

  // ── Estado del pago ─────────────────────────────────────────
  const estadoColor = transaccion.estado_pago === 'completado' ? '#16a34a' : '#dc2626'
  const estadoTexto = transaccion.estado_pago === 'completado' ? '✓ PAGO COMPLETADO' : '✗ PAGO PENDIENTE'

  doc.roundedRect(50, doc.y, doc.page.width - 100, 30, 5)
     .fill(estadoColor)

  doc.fillColor('#ffffff')
     .fontSize(12)
     .font('Helvetica-Bold')
     .text(estadoTexto, 50, doc.y - 22, { align: 'center', width: doc.page.width - 100 })

  doc.moveDown(2)

  // ── Sección: Datos del cliente ──────────────────────────────
  seccion(doc, PURPLE, 'DATOS DEL CLIENTE')

  fila(doc, GRAY, 'Nombre',    transaccion.cliente_nombre || '-')
  fila(doc, GRAY, 'Email',     transaccion.cliente_email  || '-')
  fila(doc, GRAY, 'Teléfono',  transaccion.cliente_telefono || '-')

  doc.moveDown(0.5)

  // ── Sección: Datos del local ────────────────────────────────
  seccion(doc, PURPLE, 'DATOS DEL LOCAL')

  fila(doc, GRAY, 'Plaza',     transaccion.plaza_nombre   || '-')
  fila(doc, GRAY, 'Ubicación', transaccion.plaza_ubicacion || '-')
  fila(doc, GRAY, 'Local',     transaccion.local_numero   || '-')
  fila(doc, GRAY, 'Área',      `${transaccion.area || '-'} m²`)
  fila(doc, GRAY, 'Precio de compra', `$${Number(transaccion.precio_compra || 0).toLocaleString('es-MX')} MXN`)

  doc.moveDown(0.5)

  // ── Sección: Detalles de la transacción ────────────────────
  seccion(doc, PURPLE, 'DETALLES DE LA TRANSACCIÓN')

  fila(doc, GRAY, 'Tipo',         transaccion.tipo === 'compra' ? 'Compra' : 'Apartado')
  fila(doc, GRAY, 'Monto pagado', `$${Number(transaccion.monto || 0).toLocaleString('es-MX')} MXN`)

  if (transaccion.tipo === 'apartado') {
    fila(doc, GRAY, 'Porcentaje del total', `${transaccion.porcentaje_apartado || 30}%`)
    fila(doc, GRAY, 'Duración del apartado', `${transaccion.duracion_apartado_dias || '-'} días`)
    if (transaccion.fecha_vencimiento_apartado) {
      fila(doc, GRAY, 'Vence el', new Date(transaccion.fecha_vencimiento_apartado).toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' }))
    }
    const restante = Number(transaccion.precio_compra || 0) - Number(transaccion.monto || 0)
    fila(doc, GRAY, 'Saldo restante para compra', `$${restante.toLocaleString('es-MX')} MXN`)
  }

  if (transaccion.paypal_payment_id) {
    fila(doc, GRAY, 'ID de pago PayPal', transaccion.paypal_payment_id)
  }

  doc.moveDown(0.5)

  // ── Sección: Políticas ──────────────────────────────────────
  seccion(doc, PURPLE, 'POLÍTICAS')

  doc.fillColor(DARK)
     .fontSize(8.5)
     .font('Helvetica')
     .text(POLITICAS_COMPRA.trim(), { lineGap: 3 })

  // ── Pie de página ───────────────────────────────────────────
  const bottom = doc.page.height - 60
  doc.moveTo(50, bottom).lineTo(doc.page.width - 50, bottom).strokeColor(PURPLE).lineWidth(1).stroke()

  doc.fillColor(GRAY)
     .fontSize(8)
     .text('Este documento es un comprobante oficial de Plazas Comerciales Estado de México.', 50, bottom + 10, { align: 'center', width: doc.page.width - 100 })
     .text('Conserve este documento para cualquier aclaración futura.', 50, bottom + 22, { align: 'center', width: doc.page.width - 100 })

  doc.end()
}

// ── Helpers ─────────────────────────────────────────────────
function seccion(doc, color, titulo) {
  doc.rect(50, doc.y, doc.page.width - 100, 22).fill(color)
  doc.fillColor('#ffffff')
     .fontSize(10)
     .font('Helvetica-Bold')
     .text(titulo, 58, doc.y - 16)
  doc.moveDown(0.8)
}

function fila(doc, grayColor, label, value) {
  const y = doc.y
  doc.fillColor(grayColor).fontSize(9).font('Helvetica').text(label + ':', 58, y, { continued: false, width: 160 })
  doc.fillColor('#1a1a2e').fontSize(9).font('Helvetica-Bold').text(String(value), 220, y)
  doc.moveDown(0.4)
}
