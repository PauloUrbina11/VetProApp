import {
    getHorariosByVeterinaria,
    createHorario,
    updateHorario,
    deleteHorario,
    deleteAllHorariosByVeterinaria,
    getCitasByVeterinariaAndDate
} from '../models/horarios.model.js';

export const getHorariosService = async (veterinariaId) => {
    return await getHorariosByVeterinaria(veterinariaId);
};

export const createHorarioService = async (data) => {
    // Validar que dia_semana esté entre 0 (domingo) y 6 (sábado)
    if (data.dia_semana < 0 || data.dia_semana > 6) {
        throw new Error('El día de la semana debe estar entre 0 (domingo) y 6 (sábado)');
    }
    
    // Validar formato de horas (opcional, PostgreSQL lo validará también)
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/;
    if (!timeRegex.test(data.hora_inicio) || !timeRegex.test(data.hora_fin)) {
        throw new Error('Formato de hora inválido. Use HH:MM o HH:MM:SS');
    }
    
    return await createHorario(data);
};

export const updateHorarioService = async (id, data) => {
    // Validaciones similares
    if (data.dia_semana !== undefined && (data.dia_semana < 0 || data.dia_semana > 6)) {
        throw new Error('El día de la semana debe estar entre 0 (domingo) y 6 (sábado)');
    }
    
    return await updateHorario(id, data);
};

export const deleteHorarioService = async (id) => {
    const result = await deleteHorario(id);
    if (!result) {
        throw new Error('Horario no encontrado');
    }
    return result;
};

export const replaceAllHorariosService = async (veterinariaId, horarios) => {
    // Eliminar todos los horarios existentes
    await deleteAllHorariosByVeterinaria(veterinariaId);
    
    // Crear los nuevos horarios
    const promises = horarios.map(horario => createHorario({
        ...horario,
        veterinaria_id: veterinariaId
    }));
    
    return await Promise.all(promises);
};

export const getHorariosDisponiblesService = async (veterinariaId, fecha) => {
    // Obtener el día de la semana de la fecha (0=domingo, 6=sábado)
    const date = new Date(fecha + 'T00:00:00');
    const diaSemana = date.getDay();
    
    // Obtener horarios de trabajo de ese día
    const horariosTrabajoQuery = await getHorariosByVeterinaria(veterinariaId);
    const horariosDelDia = horariosTrabajoQuery.filter(h => h.dia_semana === diaSemana && h.disponible);
    
    if (horariosDelDia.length === 0) {
        return []; // No hay horarios de trabajo este día
    }
    
    // Obtener citas ya agendadas para ese día
    const citasAgendadas = await getCitasByVeterinariaAndDate(veterinariaId, fecha);
    
    // Generar slots de 30 minutos entre los horarios de trabajo
    const slotsDisponibles = [];
    
    for (const horario of horariosDelDia) {
        const [horaInicio, minInicio] = horario.hora_inicio.split(':').map(Number);
        const [horaFin, minFin] = horario.hora_fin.split(':').map(Number);
        
        let currentHora = horaInicio;
        let currentMin = minInicio;
        
        while (currentHora < horaFin || (currentHora === horaFin && currentMin < minFin)) {
            const slotTime = `${String(currentHora).padStart(2, '0')}:${String(currentMin).padStart(2, '0')}`;
            
            // Verificar si el slot está ocupado por una cita
            const estaOcupado = citasAgendadas.some(cita => {
                const citaTime = new Date(cita.fecha_hora);
                const citaHora = citaTime.getHours();
                const citaMin = citaTime.getMinutes();
                return citaHora === currentHora && citaMin === currentMin;
            });
            
            if (!estaOcupado) {
                slotsDisponibles.push({
                    hora: slotTime,
                    disponible: true
                });
            }
            
            // Avanzar 30 minutos
            currentMin += 30;
            if (currentMin >= 60) {
                currentMin -= 60;
                currentHora += 1;
            }
        }
    }
    
    return slotsDisponibles;
};
