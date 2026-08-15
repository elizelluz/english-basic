# English Basic

MVP de plataforma de suscripción (freemium) para un curso de inglés básico.
Valida el modelo de negocio: registro → consumo → pago → retención.

## Stack

- **Frontend**: Angular 20 (standalone, lazy loading) + PWA instalable
- **Hosting**: Cloudflare Pages (estático, HTTPS gratis)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Pagos**: Hotmart (Merchant of Record, venta internacional con tarjeta)
- **Email**: Resend
- **Video**: YouTube no listado

## Requisitos

- Node 22+, npm 10+
- Angular CLI 20

## Desarrollo

```bash
npm install
npm start        # ng serve — http://localhost:4200
npm run build    # build de producción en dist/english-basic/browser
```

## Configuración

Copia `.env.example` a `.env` y rellena las variables de Supabase (URL + anon key).
Los secretos (service role, credenciales Hotmart/Resend) viven SOLO en Edge Functions,
nunca en el frontend.