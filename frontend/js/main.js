import { setupTabs } from './ui_controller.js';
import { getFinancialData, getOperationalData, getCommercialData, getProjectMarginData } from './data_provider.js';
import { createDeudaChart, createGaugeChart, createUtilizacionChart, createFunnelChart } from './chart_builder.js';

document.addEventListener('DOMContentLoaded', () => {
    lucide.createIcons();
    setupTabs();
    initDashboard();
});

function initDashboard() {
    const financialData = getFinancialData();
    const operationalData = getOperationalData();
    const commercialData = getCommercialData();
    const projectMarginData = getProjectMarginData();


    createDeudaChart('deudaChart', financialData.deuda);

    createGaugeChart(
        'interesesGauge',
        'Ratio Cobertura de Intereses',
        financialData.ratios.coberturaIntereses,
        {
            value: 2.8,
            max: 5,
            zones: { low: 1.5, mid: 3 }
        }
    );

    createGaugeChart(
        'gastosGauge',
        'Gastos Admins vs. Ingresos',
        financialData.ratios.gastosAdmins * 100,
        {
            value: 38,
            max: 50,
            zones: { low: 30, mid: 40 },
            inverted: true,
            unit: '%'
        }
    );
    populateProjectMargins(projectMarginData);



    createUtilizacionChart('utilizacionChart', operationalData.utilizacion);


    createFunnelChart('funnelChart', commercialData.funnel);
}

function populateProjectMargins(data) {
    const tableBody = document.getElementById('proyectos-table');
    if (!tableBody) return;
    tableBody.innerHTML = '';
    data.forEach(proj => {
        const marginClass = proj.margen > 0 ? 'text-green-400' : 'text-red-400';
        const row = `
            <tr class="border-b border-slate-700 hover:bg-slate-800">
                <td class="px-4 py-3 font-medium text-slate-200">${proj.nombre}</td>
                <td class="px-4 py-3 text-right font-mono ${marginClass}">${(proj.margen / 1000).toFixed(1)}K</td>
            </tr>
        `;
        tableBody.innerHTML += row;
    });
}
