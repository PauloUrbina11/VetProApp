import nodemailer from 'nodemailer';

const TEST_EMAIL = 'paurbi_1101@hotmail.com';

export const sendActivationEmail = async (originalUserEmail, token) => {
  // Enviar ambos enlaces: HTTP clickeable y deep link para abrir la app móvil
  const webActivationUrl = `https://vetproapp.onrender.com/api/auth/activate?token=${encodeURIComponent(token)}`;
  const appActivationUrl = `vetproapp://activate?token=${encodeURIComponent(token)}`;

  const subject = 'Activación de cuenta - VetProApp (Pruebas)';
  const text = `Hola,\n\nPara activar tu cuenta visita el siguiente enlace:\n${webActivationUrl}\n\nSi estás en móvil, también puedes abrir la app con este enlace:\n${appActivationUrl}\n\nEste mensaje se envía sólo para pruebas.`;
  const html = `
    <p>Hola,</p>
    <p>Para activar tu cuenta puedes:</p>
    <ul>
      <li>Usar este enlace web (clickeable): <a href="${webActivationUrl}">Activar cuenta</a></li>
      <li>O abrir directamente la app móvil (si estás en móvil): <a href="${appActivationUrl}">Abrir en la app</a></li>
    </ul>
    <p>Si el enlace de la app no abre automáticamente, copia y pega este enlace en tu dispositivo móvil: ${appActivationUrl}</p>
    <p>Correo original del usuario: ${originalUserEmail}</p>
    <p>Este mensaje se envía sólo para pruebas.</p>
  `;

  // Siempre logueamos el link para pruebas
  console.log('=== Activation email (test) ===');
  console.log(`To (test): ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Activation link (web): ${webActivationUrl}`);
  console.log(`Activation link (app): ${appActivationUrl}`);
  console.log('===============================');

  // Si hay configuración SMTP en env, intentar enviar el correo real
  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    console.log('SMTP no configurado. No se envía correo real (usa variables SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS)');
    return { ok: true, sent: false };
  }

  try {
    const transporter = nodemailer.createTransport({
      host: SMTP_HOST,
      port: SMTP_PORT ? parseInt(SMTP_PORT, 10) : 587,
      secure: SMTP_PORT == 465, // true for 465, false for other ports
      auth: {
        user: SMTP_USER,
        pass: SMTP_PASS,
      },
      connectionTimeout: 30000, // 30 segundos
      greetingTimeout: 30000,
      socketTimeout: 30000,
    });

    // Enviar email directamente sin verificación previa
    const info = await transporter.sendMail({
      from: SMTP_USER,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log('✅ Email de activación enviado correctamente:', info.messageId);
    return { ok: true, sent: true, info };
  } catch (err) {
    console.error('❌ Error enviando email de activación:', err.message);
    return { ok: false, sent: false, error: err.message };
  }
};

export default sendActivationEmail;

export const sendResetEmail = async (originalUserEmail, token) => {
  const webResetUrl = `https://vetproapp.onrender.com/api/auth/reset?token=${encodeURIComponent(token)}`;
  const appResetUrl = `vetproapp://reset?token=${encodeURIComponent(token)}`;

  const subject = 'Restablecer contraseña - VetProApp (Pruebas)';
  const text = `Hola,\n\nPara restablecer tu contraseña visita el siguiente enlace:\n${webResetUrl}\n\nSi estás en móvil, también puedes abrir la app con este enlace:\n${appResetUrl}\n\nEste mensaje se envía sólo para pruebas.`;
  const html = `
    <p>Hola,</p>
    <p>Para restablecer tu contraseña puedes:</p>
    <ul>
      <li>Usar este enlace web (clickeable): <a href="${webResetUrl}">Restablecer contraseña</a></li>
      <li>O abrir directamente la app móvil (si estás en móvil): <a href="${appResetUrl}">Abrir en la app</a></li>
    </ul>
    <p>Si el enlace de la app no abre automáticamente, copia y pega este enlace en tu dispositivo móvil: ${appResetUrl}</p>
    <p>Correo original del usuario: ${originalUserEmail}</p>
    <p>Este mensaje se envía sólo para pruebas.</p>
  `;

  console.log('=== Reset email (test) ===');
  console.log(`To (test): ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Reset link (web): ${webResetUrl}`);
  console.log(`Reset link (app): ${appResetUrl}`);
  console.log('===========================');

  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    console.log('SMTP no configurado. No se envía correo real de reset');
    return { ok: true, sent: false };
  }

  try {
    const transporter = nodemailer.createTransport({
      host: SMTP_HOST,
      port: SMTP_PORT ? parseInt(SMTP_PORT, 10) : 587,
      secure: SMTP_PORT == 465,
      auth: {
        user: SMTP_USER,
        pass: SMTP_PASS,
      },
      connectionTimeout: 30000, // 30 segundos
      greetingTimeout: 30000,
      socketTimeout: 30000,
    });

    // Enviar email directamente sin verificación previa
    const info = await transporter.sendMail({
      from: SMTP_USER,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log('✅ Email de reset enviado correctamente:', info.messageId);
    return { ok: true, sent: true, info };
  } catch (err) {
    console.error('❌ Error enviando email de reset:', err.message);
    return { ok: false, sent: false, error: err.message };
  }
};
