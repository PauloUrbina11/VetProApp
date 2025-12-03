import { startReminderService } from "./appointmentReminder.service.js";
import { startPasswordReminderService } from "./passwordReminder.service.js";

console.log("Iniciando cron runner...");

startReminderService();
startPasswordReminderService();
