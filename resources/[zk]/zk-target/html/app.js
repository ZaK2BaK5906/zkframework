const panel = document.getElementById('panel');
const optionsEl = document.getElementById('options');
let options = [];

function render() {
  optionsEl.innerHTML = '';
  options.forEach((option) => {
    const row = document.createElement('div');
    row.className = `option${option.danger ? ' danger' : ''}`;
    row.innerHTML = `
      <div class="icon">${option.icon}</div>
      <div class="label">${option.label}</div>
    `;
    row.addEventListener('click', () => {
      fetch(`https://${GetParentResourceName()}/select`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ id: option.id }),
      });
    });
    optionsEl.appendChild(row);
  });
}

window.addEventListener('message', (event) => {
  const { action, options: payload } = event.data;
  if (action === 'open') {
    panel.classList.remove('hidden');
  }
  if (action === 'close') {
    panel.classList.add('hidden');
    options = [];
    render();
  }
  if (action === 'options') {
    options = payload || [];
    render();
  }
});
