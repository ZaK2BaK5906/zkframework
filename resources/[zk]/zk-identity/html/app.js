const app = document.getElementById('app');
const form = document.getElementById('identity-form');

window.addEventListener('message', (event) => {
  if (event.data.action === 'open') {
    app.classList.remove('hidden');
  }
  if (event.data.action === 'close') {
    app.classList.add('hidden');
    form.reset();
  }
});

form.addEventListener('submit', (event) => {
  event.preventDefault();
  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());

  fetch(`https://${GetParentResourceName()}/createCharacter`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload),
  });
});
