import axios from 'axios'
import https from 'https'
import dotenv from 'dotenv'
dotenv.config()

const PAYPAL_API = process.env.PAYPAL_MODE === 'live'
  ? 'https://api-m.paypal.com'
  : 'https://api-m.sandbox.paypal.com'

// En sandbox/desarrollo deshabilitamos verificación SSL
// (problema común en Windows con certificados de PayPal sandbox)
const httpsAgent = process.env.PAYPAL_MODE !== 'live'
  ? new https.Agent({ rejectUnauthorized: false })
  : undefined

export async function getPayPalAccessToken() {
  const auth = Buffer.from(
    `${process.env.PAYPAL_CLIENT_ID}:${process.env.PAYPAL_CLIENT_SECRET}`
  ).toString('base64')

  const response = await axios.post(
    `${PAYPAL_API}/v1/oauth2/token`,
    'grant_type=client_credentials',
    {
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      httpsAgent,
    }
  )

  return response.data.access_token
}

export { PAYPAL_API, httpsAgent }
