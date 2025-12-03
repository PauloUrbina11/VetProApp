import nodemailer from "nodemailer";

const TEST_EMAIL = "paurbi_1101@hotmail.com";

// Creamos el transporter UNA sola vez para evitar timeouts
let transporter = null;

const getTransporter = () => {
  if (transporter) return transporter;

  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS } = process.env;

  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: SMTP_PORT ? parseInt(SMTP_PORT, 10) : 587,
    secure: false, // SendGrid NO usa conexión secure por 587
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
    pool: true,            // Reutiliza conexiones
    maxConnections: 1,     // Ideal para Render free tier
    maxMessages: 5,
    socketTimeout: 10000,  // 10 segundos → evita cuelgues
  });

  return transporter;
};


export const sendActivationEmail = async (originalUserEmail, token) => {
  // Enlaces
  const webActivationUrl = `https://vetproapp.onrender.com/api/auth/activate?token=${encodeURIComponent(token)}`;
  const appActivationUrl = `vetproapp://activate?token=${encodeURIComponent(token)}`;

  const subject = "Activación de cuenta - VetProApp (Pruebas)";
  const text = `Hola,\n\nActiva tu cuenta aquí:\n${webActivationUrl}\n\nO desde la app:\n${appActivationUrl}`;
  const html = `
    <p>Hola,</p>
    <p>Activa tu cuenta:</p>
    <ul>
      <li><a href="${webActivationUrl}">Activar cuenta (web)</a></li>
      <li><a href="${appActivationUrl}">Abrir en la app</a></li>
    </ul>
    <p>Correo original: ${originalUserEmail}</p>
  `;

  console.log("=== Activation email (test) ===");
  console.log("To:", TEST_EMAIL);
  console.log("Activation web:", webActivationUrl);
  console.log("Activation app:", appActivationUrl);

  const { SMTP_HOST, SMTP_USER, SMTP_PASS } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    console.log("⚠ SMTP no configurado — no se envía correo real.");
    return { ok: true, sent: false };
  }

  try {
    const transporter = getTransporter();

    const info = await transporter.sendMail({
      from: process.env.EMAIL_FROM || SMTP_USER,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log("Email enviado (activation):", info.messageId);
    return { ok: true, sent: true };
  } catch (err) {
    console.error("❌ Error enviando email de activación:", err.message);
    return { ok: false, sent: false, error: err.message };
  }
};



export const sendResetEmail = async (originalUserEmail, token) => {
  const webResetUrl = `https://vetproapp.onrender.com/api/auth/reset?token=${encodeURIComponent(token)}`;
  const appResetUrl = `vetproapp://reset?token=${encodeURIComponent(token)}`;

  const subject = "Restablecer contraseña - VetProApp (Pruebas)";
  const text = `Hola,\n\nRestablece tu contraseña:\n${webResetUrl}\n\nO desde la app:\n${appResetUrl}`;
  const html = `
    <p>Hola,</p>
    <p>Puedes restablecer tu contraseña:</p>
    <ul>
      <li><a href="${webResetUrl}">Restablecer (web)</a></li>
      <li><a href="${appResetUrl}">Abrir en la app</a></li>
    </ul>
    <p>Correo original: ${originalUserEmail}</p>
  `;

  console.log("=== Reset email (test) ===");
  console.log("To:", TEST_EMAIL);
  console.log("Reset web:", webResetUrl);
  console.log("Reset app:", appResetUrl);

  const { SMTP_HOST, SMTP_USER, SMTP_PASS } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    console.log("⚠ SMTP no configurado — no se envía correo real.");
    return { ok: true, sent: false };
  }

  try {
    const transporter = getTransporter();

    const info = await transporter.sendMail({
      from: process.env.EMAIL_FROM || SMTP_USER,
      to: TEST_EMAIL,
      subject,
      text,
      html,
    });

    console.log("Email enviado (reset):", info.messageId);
    return { ok: true, sent: true };
  } catch (err) {
    console.error("❌ Error enviando email de reset:", err.message);
    return { ok: false, sent: false, error: err.message };
  }
};


export default sendActivationEmail;
