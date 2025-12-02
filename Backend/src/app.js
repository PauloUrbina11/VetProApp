import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth.routes.js";
import locationRoutes from "./routes/location.routes.js";
import petsRoutes from "./routes/pets.routes.js";
import appointmentsRoutes from "./routes/appointments.routes.js";
import servicesRoutes from "./routes/services.routes.js";
import veterinariasRoutes from "./routes/veterinarias.routes.js";
import horariosRoutes from "./routes/horarios.routes.js";
import veterinariaServicesRoutes from "./routes/veterinaria_services.routes.js";
import recommendationsRoutes from "./routes/recommendations.routes.js";
import adminRoutes from "./routes/admin.routes.js";
import statsRoutes from "./routes/stats.routes.js";
import userRoutes from "./routes/user.routes.js";
import medicalRecordsRoutes from "./routes/medical_records.routes.js";
import notificationsRoutes from "./routes/notifications.routes.js";
import { initRoles } from "./models/role.model.js";
import { startReminderService } from "./services/reminders.service.js";
import { startPasswordReminderService } from "./services/password_reminder.service.js";

const app = express();

// Iniciar servicios de recordatorios
startReminderService();
startPasswordReminderService();

app.use(cors());
app.use(express.json());

// Ruta base
app.get("/", (req, res) => {
    res.json({ message: "API VetProApp funcionando correctamente 🎉" });
});

// Rutas
app.use("/api/auth", authRoutes);
app.use("/api/location", locationRoutes);
app.use("/api/pets", petsRoutes);
app.use("/api/appointments", appointmentsRoutes);
app.use("/api/services", servicesRoutes);
app.use("/api/veterinarias", veterinariasRoutes);
app.use("/api/veterinarias", horariosRoutes);
app.use("/api/veterinarias", veterinariaServicesRoutes);
app.use("/api/recommendations", recommendationsRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/stats", statsRoutes);
app.use("/api/users", userRoutes);
app.use("/api/medical-records", medicalRecordsRoutes);
app.use("/api/notifications", notificationsRoutes);

export default app;
