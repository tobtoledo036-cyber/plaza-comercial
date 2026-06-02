import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import axios from 'axios'
import './PagoExitoso.css'

export default function PagoExitoso() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [procesando, setProcesando] = useState(true)
  const [error, setError] = useState(null)
  const [datos, setDatos] = useState(null)

  useEffect(() => {
    const capturarPago = async () => {
      const token = searchParams.get('token')
      const transaccionId = searchParams.get('transaccionId')

      if (!token || !transaccionId) {
        setError('Parámetros inválidos')
        setProcesando(false)
        return
      }

      try {
        const response = await axios.post('/api/paypal/capture-order', {
          orderID: token,
          transaccionId
        })

        setDatos(response.data)
        setProcesando(false)

        // Redirigir al inicio después de 5 segundos
        setTimeout(() => {
          navigate('/')
        }, 5000)
      } catch (err) {
        console.error('Error capturando pago:', err)
        setError(err.response?.data?.error || 'Error al procesar el pago')
        setProcesando(false)
      }
    }

    capturarPago()
  }, [searchParams, navigate])

  if (procesando) {
    return (
      <div className="pago-page">
        <div className="pago-card">
          <div className="spinner"></div>
          <h2>Procesando tu pago...</h2>
          <p>Por favor espera un momento</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="pago-page">
        <div className="pago-card error">
          <div className="icon">❌</div>
          <h2>Error en el pago</h2>
          <p>{error}</p>
          <button onClick={() => navigate('/')} className="btn-volver">
            Volver al inicio
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="pago-page">
      <div className="pago-card success">
        <div className="icon">✅</div>
        <h2>¡Pago completado!</h2>
        <p className="mensaje">Tu {datos?.estado === 'vendido' ? 'compra' : 'apartado'} se ha procesado exitosamente</p>
        
        <div className="detalles">
          <div className="detalle-item">
            <span>ID de pago:</span>
            <strong>{datos?.paymentId}</strong>
          </div>
          <div className="detalle-item">
            <span>Estado del local:</span>
            <strong className={datos?.estado}>{datos?.estado}</strong>
          </div>
        </div>

        <p className="redireccion">Serás redirigido al inicio en 5 segundos...</p>
        
        <button onClick={() => navigate('/')} className="btn-volver">
          Volver ahora
        </button>
      </div>
    </div>
  )
}
