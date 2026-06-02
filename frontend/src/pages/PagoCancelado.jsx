import { useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import axios from 'axios'
import './PagoExitoso.css'

export default function PagoCancelado() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()

  useEffect(() => {
    const cancelarTransaccion = async () => {
      const transaccionId = searchParams.get('transaccionId')
      
      if (transaccionId) {
        try {
          await axios.patch(`/api/transacciones/${transaccionId}/cancelar`)
        } catch (err) {
          console.error('Error cancelando transacción:', err)
        }
      }
    }

    cancelarTransaccion()
  }, [searchParams])

  return (
    <div className="pago-page">
      <div className="pago-card warning">
        <div className="icon">⚠️</div>
        <h2>Pago cancelado</h2>
        <p className="mensaje">Has cancelado el proceso de pago</p>
        <p>El local ha sido liberado y está disponible nuevamente</p>
        
        <button onClick={() => navigate('/')} className="btn-volver">
          Volver al inicio
        </button>
      </div>
    </div>
  )
}
