import nodemailer from 'nodemailer'
import dotenv from 'dotenv'
dotenv.config()

// Configurar transporter (usa variables de entorno, con fallback a Ethereal para dev)
function crearTransporter() {
  if (process.env.EMAIL_HOST) {
    return nodemailer.createTransport({
      host:   process.env.EMAIL_HOST,
      port:   parseInt(process.env.EMAIL_PORT) || 587,
      secure: process.env.EMAIL_SECURE === 'true',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
      tls: {
        rejectUnauthorized: false,
      },
    })
  }
  // Gmail como alternativa rápida
  if (process.env.GMAIL_USER) {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS,
      },
      tls: {
        rejectUnauthorized: false,
      },
    })
  }
  // Sin configuración: log en consola (modo desarrollo)
  return null
}

const transporter = crearTransporter()

async function enviarCorreo({ to, subject, html }) {
  if (!transporter) {
    console.log(`[MAILER - DEV] Para: ${to} | Asunto: ${subject}`)
    return { messageId: 'dev-mode' }
  }
  try {
    const info = await transporter.sendMail({
      from: process.env.EMAIL_FROM || process.env.GMAIL_USER || 'noreply@plazas.com',
      to,
      subject,
      html,
    })
    console.log(`✉️  Correo enviado a ${to}: ${info.messageId}`)
    return info
  } catch (err) {
    console.error('❌ Error enviando correo:', err.message)
    // No lanzar error — el correo es secundario, no debe romper el flujo
  }
}

// ── Plantillas ───────────────────────────────────────────────

export async function enviarConfirmacionSolicitud({ solicitud, local, plaza }) {
  await enviarCorreo({
    to: solicitud.email,
    subject: `✅ Solicitud recibida — Local ${local.numero} en ${plaza.nombre}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;padding:24px;border-radius:12px">
        <h2 style="color:#7c3aed">Plaza Comercial — Solicitud Recibida</h2>
        <p>Hola <strong>${solicitud.nombre}</strong>,</p>
        <p>Hemos recibido tu solicitud para el siguiente local:</p>
        <table style="width:100%;border-collapse:collapse;margin:16px 0">
          <tr style="background:#ede9fe"><td style="padding:8px 12px;font-weight:bold">Plaza</td><td style="padding:8px 12px">${plaza.nombre}</td></tr>
          <tr><td style="padding:8px 12px;font-weight:bold">Local</td><td style="padding:8px 12px">${local.numero}</td></tr>
          <tr style="background:#ede9fe"><td style="padding:8px 12px;font-weight:bold">Área</td><td style="padding:8px 12px">${local.area} m²</td></tr>
          <tr><td style="padding:8px 12px;font-weight:bold">Giro propuesto</td><td style="padding:8px 12px">${solicitud.giro_propuesto}</td></tr>
          <tr style="background:#ede9fe"><td style="padding:8px 12px;font-weight:bold">Folio</td><td style="padding:8px 12px">#${solicitud.id}</td></tr>
        </table>
        <p>Nuestro equipo revisará tu solicitud y te contactará en un plazo de <strong>3-5 días hábiles</strong>.</p>
        <p style="color:#6b7280;font-size:13px">Si tienes dudas, responde a este correo.</p>
      </div>
    `,
  })
}

export async function notificarAdminNuevaSolicitud({ solicitud, local, plaza }) {
  const adminEmail = process.env.ADMIN_EMAIL || process.env.GMAIL_USER
  if (!adminEmail) return

  await enviarCorreo({
    to: adminEmail,
    subject: `🔔 Nueva solicitud — Local ${local.numero} (${plaza.nombre})`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;padding:24px;border-radius:12px">
        <h2 style="color:#dc2626">Nueva Solicitud de Renta</h2>
        <table style="width:100%;border-collapse:collapse;margin:16px 0">
          <tr style="background:#fee2e2"><td style="padding:8px 12px;font-weight:bold">Solicitante</td><td style="padding:8px 12px">${solicitud.nombre}</td></tr>
          <tr><td style="padding:8px 12px;font-weight:bold">Email</td><td style="padding:8px 12px">${solicitud.email}</td></tr>
          <tr style="background:#fee2e2"><td style="padding:8px 12px;font-weight:bold">Teléfono</td><td style="padding:8px 12px">${solicitud.telefono || 'N/A'}</td></tr>
          <tr><td style="padding:8px 12px;font-weight:bold">Plaza</td><td style="padding:8px 12px">${plaza.nombre}</td></tr>
          <tr style="background:#fee2e2"><td style="padding:8px 12px;font-weight:bold">Local</td><td style="padding:8px 12px">${local.numero} (${local.area} m²)</td></tr>
          <tr><td style="padding:8px 12px;font-weight:bold">Giro</td><td style="padding:8px 12px">${solicitud.giro_propuesto}</td></tr>
          <tr style="background:#fee2e2"><td style="padding:8px 12px;font-weight:bold">Plan</td><td style="padding:8px 12px">${solicitud.plan_negocio}</td></tr>
        </table>
        <p><a href="${process.env.FRONTEND_URL || 'http://localhost:5173'}/admin-dashboard" style="background:#7c3aed;color:white;padding:10px 20px;border-radius:6px;text-decoration:none">Ver en Panel Admin</a></p>
      </div>
    `,
  })
}

export async function enviarAprobacion({ solicitud, local, plaza }) {
  await enviarCorreo({
    to: solicitud.email,
    subject: `🎉 Solicitud aprobada — Local ${local.numero} en ${plaza.nombre}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;padding:24px;border-radius:12px">
        <h2 style="color:#16a34a">¡Tu solicitud fue aprobada!</h2>
        <p>Hola <strong>${solicitud.nombre}</strong>,</p>
        <p>Nos complace informarte que tu solicitud para el <strong>Local ${local.numero}</strong> en <strong>${plaza.nombre}</strong> ha sido <strong style="color:#16a34a">aprobada</strong>.</p>
        ${solicitud.respuesta_admin ? `<div style="background:#dcfce7;padding:12px;border-radius:8px;margin:16px 0"><strong>Mensaje del administrador:</strong><br>${solicitud.respuesta_admin}</div>` : ''}
        <p><strong>Próximos pasos:</strong></p>
        <ol>
          <li>Nuestro equipo se pondrá en contacto contigo para coordinar la firma del contrato.</li>
          <li>Prepara tu documentación (identificación oficial, comprobante de domicilio, RFC).</li>
          <li>Se acordará la fecha de entrega del local.</li>
        </ol>
        <p style="color:#6b7280;font-size:13px">Folio de solicitud: #${solicitud.id}</p>
      </div>
    `,
  })
}

export async function enviarRechazo({ solicitud, local, plaza }) {
  await enviarCorreo({
    to: solicitud.email,
    subject: `Actualización de tu solicitud — Local ${local.numero} en ${plaza.nombre}`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;padding:24px;border-radius:12px">
        <h2 style="color:#dc2626">Actualización de tu solicitud</h2>
        <p>Hola <strong>${solicitud.nombre}</strong>,</p>
        <p>Lamentamos informarte que tu solicitud para el <strong>Local ${local.numero}</strong> en <strong>${plaza.nombre}</strong> no pudo ser aprobada en este momento.</p>
        ${solicitud.respuesta_admin ? `<div style="background:#fee2e2;padding:12px;border-radius:8px;margin:16px 0"><strong>Motivo:</strong><br>${solicitud.respuesta_admin}</div>` : ''}
        <p>Te invitamos a explorar otros locales disponibles en nuestras plazas.</p>
        <p><a href="${process.env.FRONTEND_URL || 'http://localhost:5173'}" style="background:#7c3aed;color:white;padding:10px 20px;border-radius:6px;text-decoration:none">Ver locales disponibles</a></p>
        <p style="color:#6b7280;font-size:13px">Folio de solicitud: #${solicitud.id}</p>
      </div>
    `,
  })
}

// ── Validación básica de email ───────────────────────────────
export function emailValido(email) {
  if (!email) return false
  // Formato básico
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return false
  // Dominios claramente falsos
  const dominiosFalsos = ['test.com', 'example.com', 'fake.com', 'correo.com',
    'mail.com', 'prueba.com', 'noemail.com', 'nomail.com', 'sinmail.com']
  const dominio = email.split('@')[1]?.toLowerCase()
  if (dominiosFalsos.includes(dominio)) {
    console.log(`[MAILER] Email con dominio no confiable omitido: ${email}`)
    return false
  }
  return true
}

// ── Enviar comprobante de pago con PDF adjunto ───────────────
export async function enviarComprobantePago(transaccion) {
  if (!emailValido(transaccion.cliente_email)) {
    console.log(`[MAILER] Email inválido o no confiable, no se envía comprobante: ${transaccion.cliente_email}`)
    return
  }

  if (!transporter) {
    console.log(`[MAILER - DEV] Comprobante PDF para: ${transaccion.cliente_email} (sin transporter configurado)`)
    return
  }

  try {
    const { generarPDFTransaccion } = await import('./generarPDF.js')
    const { PassThrough } = await import('stream')

    // Generar PDF en buffer
    const pdfBuffer = await new Promise((resolve, reject) => {
      const chunks = []
      const stream = new PassThrough()
      stream.on('data', chunk => chunks.push(chunk))
      stream.on('end', () => resolve(Buffer.concat(chunks)))
      stream.on('error', reject)
      generarPDFTransaccion(transaccion, stream)
    })

    const tipo = transaccion.tipo === 'compra' ? 'compra' : 'apartado'
    const folio = String(transaccion.id).padStart(6, '0')

    await transporter.sendMail({
      from: process.env.EMAIL_FROM || process.env.GMAIL_USER || 'noreply@plazas.com',
      to: transaccion.cliente_email,
      subject: `🧾 Comprobante de pago — Local ${transaccion.local_numero} en ${transaccion.plaza_nombre}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#f9f9f9;padding:24px;border-radius:12px">
          <h2 style="color:#16a34a">✅ Pago completado exitosamente</h2>
          <p>Hola <strong>${transaccion.cliente_nombre}</strong>,</p>
          <p>Tu pago ha sido procesado correctamente. Adjunto encontrarás tu comprobante oficial.</p>
          <table style="width:100%;border-collapse:collapse;margin:16px 0">
            <tr style="background:#dcfce7"><td style="padding:8px 12px;font-weight:bold">Plaza</td><td style="padding:8px 12px">${transaccion.plaza_nombre}</td></tr>
            <tr><td style="padding:8px 12px;font-weight:bold">Local</td><td style="padding:8px 12px">${transaccion.local_numero}</td></tr>
            <tr style="background:#dcfce7"><td style="padding:8px 12px;font-weight:bold">Área</td><td style="padding:8px 12px">${transaccion.area} m²</td></tr>
            <tr><td style="padding:8px 12px;font-weight:bold">Tipo</td><td style="padding:8px 12px">${transaccion.tipo === 'compra' ? 'Compra' : 'Apartado'}</td></tr>
            <tr style="background:#dcfce7"><td style="padding:8px 12px;font-weight:bold">Monto pagado</td><td style="padding:8px 12px"><strong>$${Number(transaccion.monto).toLocaleString('es-MX')} MXN</strong></td></tr>
            <tr><td style="padding:8px 12px;font-weight:bold">Folio</td><td style="padding:8px 12px">#${folio}</td></tr>
          </table>
          <p style="color:#6b7280;font-size:13px">Conserva este comprobante para cualquier aclaración futura.</p>
        </div>
      `,
      attachments: [{
        filename: `comprobante-${tipo}-${folio}.pdf`,
        content: pdfBuffer,
        contentType: 'application/pdf',
      }],
    })

    console.log(`✉️  Comprobante PDF enviado a ${transaccion.cliente_email}`)
  } catch (err) {
    console.error('❌ Error enviando comprobante PDF:', err.message)
  }
}
