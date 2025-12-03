import { Resend } from 'resend';

const TEST_EMAIL = 'paurbi_1101@hotmail.com';

export const sendActivationEmail = async (originalUserEmail, token) => {
  const webActivationUrl = `https://vetproapp.onrender.com/api/auth/activate?token=${encodeURIComponent(token)}`;
  const appActivationUrl = `vetproapp://activate?token=${encodeURIComponent(token)}`;

  const subject = 'Activación de cuenta - VetProApp';
  const html = `
    <h2>Bienvenido a VetProApp</h2>
    <p>Hola,</p>
    <p>Para activar tu cuenta puedes:</p>
    <ul>
      <li><a href="${webActivationUrl}">Activar cuenta desde la web</a></li>
      <li><a href="${appActivationUrl}">Abrir en la app móvil</a></li>
    </ul>
    <p><small>Correo original del usuario: ${originalUserEmail}</small></p>
  `;

  console.log('=== Activation email ===');
  console.log(`To: ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Activation link (web): ${webActivationUrl}`);
  console.log('========================');

  const { RESEND_API_KEY, RESEND_FROM_EMAIL } = process.env;
  if (!RESEND_API_KEY || !RESEND_FROM_EMAIL) {
    console.log('Resend no configurado. Necesitas RESEND_API_KEY y RESEND_FROM_EMAIL');
    return { ok: true, sent: false };
  }

  try {
    const resend = new Resend(RESEND_API_KEY);
    
    const { data, error } = await resend.emails.send({
      from: RESEND_FROM_EMAIL,
      to: TEST_EMAIL,
      subject,
      html,
    });

    if (error) {
      console.error('❌ Error enviando email de activación:', error);
      return { ok: false, sent: false, error: error.message };
    }

    console.log('✅ Email de activación enviado correctamente:', data.id);
    return { ok: true, sent: true, messageId: data.id };
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
  const html = `
    <h2>Restablecer contraseña</h2>
    <p>Hola,</p>
    <p>Para restablecer tu contraseña puedes:</p>
    <ul>
      <li><a href="${webResetUrl}">Restablecer desde la web</a></li>
      <li><a href="${appResetUrl}">Abrir en la app móvil</a></li>
    </ul>
    <p><small>Correo original del usuario: ${originalUserEmail}</small></p>
  `;

  console.log('=== Reset email ===');
  console.log(`To: ${TEST_EMAIL}`);
  console.log(`Original user email: ${originalUserEmail}`);
  console.log(`Reset link (web): ${webResetUrl}`);
  console.log('===================');

  const { RESEND_API_KEY, RESEND_FROM_EMAIL } = process.env;
  if (!RESEND_API_KEY || !RESEND_FROM_EMAIL) {
    console.log('Resend no configurado. Necesitas RESEND_API_KEY y RESEND_FROM_EMAIL');
    return { ok: true, sent: false };
  }

  try {
    const resend = new Resend(RESEND_API_KEY);
    
    const { data, error } = await resend.emails.send({
      from: RESEND_FROM_EMAIL,
      to: TEST_EMAIL,
      subject,
      html,
    });

    if (error) {
      console.error('❌ Error enviando email de reset:', error);
      return { ok: false, sent: false, error: error.message };
    }

    console.log('✅ Email de reset enviado correctamente:', data.id);
    return { ok: true, sent: true, messageId: data.id };
  } catch (err) {
    console.error('❌ Error enviando email de reset:', err.message);
    return { ok: false, sent: false, error: err.message };
  }
};
