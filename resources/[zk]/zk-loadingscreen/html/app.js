const statusEl = document.getElementById('status-text');
const progressEl = document.getElementById('progress');

const messages = [
  'Synchronisation des modules...',
  'Optimisation des assets...',
  'Chargement des outils RP...',
  'Connexion au framework...',
];

let progress = 12;
let index = 0;

function tick() {
  progress = Math.min(progress + Math.random() * 18, 98);
  progressEl.style.width = `${progress}%`;
  statusEl.textContent = messages[index % messages.length];
  index += 1;
}

setInterval(tick, 1800);
