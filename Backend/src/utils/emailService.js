import formData from 'form-data';
import Mailgun from 'mailgun.js';

const TEST_EMAIL = 'paurbi_1101@hotmail.com';

export const sendActivationEmail = async (originalUserEmail, token) => {
  const webActivationUrl = `https://vetproapp.onrender.com/api/auth/activate?token=${encodeURIComponent(token)}`;
  const appActivationUrl = `vetproapp://activate?token=${encodeURIComponent(token)}`;

  const subject = 'Activación de cuenta - VetProApp';
  const text = `Hola,\n\nPara activar tu cuenta visita el siguiente enlace:\n${webActivationUrl}\n\nSi estás en móvil, también puedes abrir la app con este enlace:\n${appActivationUrl}`;
  const html = `
    <p>Hola,</p>
    <p>Para activar tu cuenta puedes:</p>
    <ul>
      <li>Usar este enlace web: <a href="${webActivationUrl}">Activar cuenta</a></li>
      <li>O abrir la app móvil: <a href="${appActivationUrl}">Abrir en la app</a></li>
    </ul>
    <p>Correo original del usuario: ${originalUserEmail}</p>
  `;

  console.log('=== Activation email ===');
  console.log(`To: ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Activation link (web): ${webActivationUrl}`);
  console.log('========================');

  const { MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_FROM_EMAIL } = process.env;
  if (!MAILGUN_API_KEY || !MAILGUN_DOMAIN || !MAILGUN_FROM_EMAIL) {
    console.log('Mailgun no configurado. Necesitas MAILGUN_API_KEY, MAILGUN_DOMAIN y MAILGUN_FROM_EMAIL');
    return { ok: true, sent: false };
  }

  try {
    const mailgun = new Mailgun(formData);
    const mg = mailgun.client({ username: 'api', key: MAILGUN_API_KEY });
    
    await mg.messages.create(MAILGUN_DOMAIN, {
      from: MAILGUN_FROM_EMAIL,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log('✅ Email de activación enviado correctamente');
    return { ok: true, sent: true };
  } catch (err) {
    console.error('❌ Error enviando email de activación:', err.message);
    return { ok: false, sent: false, error: err.message };
  }
};

export default sendActivationEmail;

export const sendResetEmail = async (originalUserEmail, token) => {
  const webResetUrl = `https://vetproapp.onrender.com/api/auth/reset?token=${encodeURIComponent(token)}`;
  const appResetUrl = `vetproapp://reset?token=${encodeURIComponent(token)}`;

  const subject = 'Restablecer contraseña - VetProApp';
  const text = `Hola,\n\nPara restablecer tu contraseña visita el siguiente enlace:\n${webResetUrl}\n\nSi estás en móvil, también puedes abrir la app con este enlace:\n${appResetUrl}`;
  const html = `
    <p>Hola,</p>
    <p>Para restablecer tu contraseña puedes:</p>
    <ul>
      <li>Usar este enlace web: <a href="${webResetUrl}">Restablecer contraseña</a></li>
      <li>O abrir la app móvil: <a href="${appResetUrl}">Abrir en la app</a></li>
    </ul>
    <p>Correo original del usuario: ${originalUserEmail}</p>
  `;

  console.log('=== Reset email ===');
  console.log(`To: ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Reset link (web): ${webResetUrl}`);
  console.log('===================');

  const { MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_FROM_EMAIL } = process.env;
  if (!MAILGUN_API_KEY || !MAILGUN_DOMAIN || !MAILGUN_FROM_EMAIL) {
    console.log('Mailgun no configurado. Necesitas MAILGUN_API_KEY, MAILGUN_DOMAIN y MAILGUN_FROM_EMAIL');
    return { ok: true, sent: false };
  }

  try {
    const mailgun = new Mailgun(formData);
    const mg = mailgun.client({ username: 'api', key: MAILGUN_API_KEY });
    
    await mg.messages.create(MAILGUN_DOMAIN, {
      from: MAILGUN_FROM_EMAIL,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log('✅ Email de reset enviado correctamente');
    return { ok: true, sent: true };
  } catch (err) {
    console.error('❌ Error enviando email de reset:', err.message);
    return { ok: false, sent: false, error: err.message };
  }
};
