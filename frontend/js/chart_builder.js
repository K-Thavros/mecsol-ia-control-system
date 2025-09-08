import { getFinancialData, getOperationalData, getCommercialData } from './data_provider.js';

Chart.register(ChartDataLabels);

const chartDefaultOptions = {
    maintainAspectRatio: false,
    responsive: true,
    plugins: {
        legend: {
            labels: {
                color: '#94a3b8', // slate-400
                font: {
                    family: 'Roboto'
                }
            }
        },
        tooltip: {
            backgroundColor: 'rgba(30, 41, 59, 0.9)',
            titleColor: '#e2e8f0',
            bodyColor: '#cbd5e1',
            borderColor: '#475569',
            borderWidth: 1,
            padding: 10,
            cornerRadius: 6,
        }
    },
    scales: {
        x: {
            ticks: { color: '#94a3b8' },
            grid: { color: 'rgba(71, 85, 105, 0.5)' }
        },
        y: {
            ticks: { color: '#94a3b8' },
            grid: { color: 'rgba(71, 85, 105, 0.5)' }
        }
    }
};

export function createDeudaChart(canvasId, data) {
    const ctx = document.getElementById(canvasId).getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Deuda Real (Millones MXN)',
                data: data.real,
                borderColor: '#38bdf8', // sky-400
                backgroundColor: 'rgba(56, 189, 248, 0.1)',
                fill: true,
                tension: 0.3,
                pointRadius: 4,
                pointBackgroundColor: '#38bdf8',
            }, {
                label: 'Objetivo de Reducción',
                data: data.objetivo,
                borderColor: '#475569', // slate-600
                borderDash: [5, 5],
                tension: 0.3,
                pointRadius: 0,
            }]
        },
        options: { ...chartDefaultOptions }
    });
}

export function createGaugeChart(canvasId, label, data, config) {
    const { value, max, zones, inverted = false, unit = '' } = config;
    const canvas = document.getElementById(canvasId);
    const ctx = canvas.getContext('2d');

    const green = '#22c55e', yellow = '#facc15', red = '#ef4444';
    let colors = inverted ? [green, yellow, red] : [red, yellow, green];

    const gaugeData = {
        labels: ['Zona Baja', 'Zona Media', 'Zona Alta'],
        datasets: [{
            data: [zones.low, zones.mid - zones.low, max - zones.mid],
            backgroundColor: colors,
            borderColor: '#1e293b',
            borderWidth: 2,
            circumference: 180,
            rotation: -90,
            cutout: '70%',
        }]
    };

    const textCenter = {
        id: 'textCenter',
        afterDatasetsDraw(chart) {
            const { ctx } = chart;
            ctx.save();
            ctx.font = 'bold 36px Roboto';
            ctx.fillStyle = value > zones.mid ? (inverted ? red : green) : (value > zones.low ? yellow : (inverted ? green : red));
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            const x = chart.getDatasetMeta(0).data[0].x;
            const y = chart.getDatasetMeta(0).data[0].y;
            ctx.fillText(`${value}${unit}`, x, y);

            ctx.font = '14px Roboto';
            ctx.fillStyle = '#94a3b8';
            ctx.fillText(label, x, y + 30);
            ctx.restore();
        }
    }

    new Chart(ctx, {
        type: 'doughnut',
        data: gaugeData,
        options: {
            ...chartDefaultOptions,
            plugins: {
                legend: { display: false },
                tooltip: { enabled: false },
                datalabels: { display: false }
            },
            aspectRatio: 1.5,
        },
        plugins: [textCenter]
    });
}


export function createUtilizacionChart(canvasId, data) {
    const ctx = document.getElementById(canvasId).getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Utilizado',
                data: data.utilizado,
                backgroundColor: '#38bdf8', // sky-400
            }, {
                label: 'Disponible',
                data: data.disponible,
                backgroundColor: '#334155', // slate-700
            }]
        },
        options: {
            ...chartDefaultOptions,
            scales: {
                x: { stacked: true, ticks: { color: '#94a3b8' }, grid: { display: false } },
                y: { stacked: true, ticks: { color: '#94a3b8' }, grid: { color: 'rgba(71, 85, 105, 0.5)' } }
            }
        }
    });
}

export function createFunnelChart(canvasId, data) {
    const ctx = document.getElementById(canvasId).getContext('2d');
    new Chart(ctx, {
        type: 'funnel',
        data: {
            labels: data.labels,
            datasets: [{
                data: data.values,
                backgroundColor: ['#0ea5e9', '#38bdf8', '#7dd3fc', '#bae6fd'],
                borderColor: '#1e293b',
                borderWidth: 2,
            }]
        },
        options: {
            ...chartDefaultOptions,
            indexAxis: 'y',
            scales: {
                x: { display: false },
                y: { display: false }
            },
            plugins: {
                legend: { display: false },
                datalabels: {
                    color: '#082f49',
                    font: { weight: 'bold', size: 14, family: 'Roboto' },
                    formatter: (value, context) => {
                        return `${context.chart.data.labels[context.dataIndex]}\n(${value})`;
                    },
                    textAlign: 'center'
                }
            }
        }
    });
}
