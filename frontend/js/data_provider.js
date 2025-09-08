export function getFinancialData() {
    return {
        deuda: {
            labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago'],
            real: [8.0, 7.9, 7.85, 7.7, 7.6, 7.55, 7.4, 7.3], // en Millones MXN
            objetivo: [8.0, 7.9, 7.8, 7.7, 7.6, 7.5, 7.4, 7.3],
        },
        ratios: {
            coberturaIntereses: 2.8,
            gastosAdmins: 0.38,
        }
    };
}

export function getProjectMarginData() {
    return [
        { nombre: 'Proyecto Alfa', ingresos: 850000, costos: 600000, margen: 250000 },
        { nombre: 'Automatización Z', ingresos: 1200000, costos: 950000, margen: 250000 },
        { nombre: 'Mantenimiento Beta', ingresos: 450000, costos: 300000, margen: 150000 },
        { nombre: 'Ingeniería Delta', ingresos: 2100000, costos: 1500000, margen: 600000 },
        { nombre: 'Consultoría Gamma', ingresos: 300000, costos: 200000, margen: 100000 },
    ].sort((a,b) => b.margen - a.margen);
}

export function getOperationalData() {
    return {
        utilizacion: {
            labels: ['Ingeniería', 'Técnicos', 'Equipo A', 'Equipo B', 'Software'],
            utilizado: [75, 85, 60, 90, 80],
            disponible: [25, 15, 40, 10, 20],
        },
        cumplimiento: 0.92,
        retrabajo: 0.047
    };
}

export function getCommercialData() {
    return {
        conversion: 0.28,
        vpp: 750000,
        funnel: {
            labels: ['Prospectos Calificados (MQL)', 'Cotizaciones Enviadas', 'Negociación', 'Proyectos Ganados'],
            values: [150, 80, 45, 22]
        }
    };
}
