export function setupTabs() {
    const tabsContainer = document.getElementById('dashboard-tabs');
    const contentPanesContainer = document.getElementById('content-panes');
    if (!tabsContainer || !contentPanesContainer) return;

    const tabs = tabsContainer.querySelectorAll('.tab-btn');
    const panes = contentPanesContainer.querySelectorAll('.tab-pane');

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const targetPaneId = tab.dataset.tab;


            tabs.forEach(t => t.classList.remove('active-tab'));
            tab.classList.add('active-tab');


            panes.forEach(pane => {
                if (pane.id === targetPaneId) {
                    pane.classList.remove('hidden');
                } else {
                    pane.classList.add('hidden');
                }
            });
        });
    });
}
