// A página está em inglês no HTML, e sem JavaScript fica assim. O português mora aqui:
// cada [data-t] recebe o texto da chave, e [data-t-alt] o da descrição da imagem.
const LATEST = 'https://github.com/francisceioseph/psito-solitaire/releases/latest';
const SOURCE = 'https://github.com/francisceioseph/psito-solitaire#install';

const STRINGS = {
  en: { copied: 'Copied' },
  pt: {
    heroTitle: 'A paciência clássica, com calopsitas.',
    heroLead: 'A paciência clássica, para Windows e Linux, com calopsitas ilustradas nas cartas. Sem anúncios, sem telemetria e sem conta: só joguinho e felicidade.',
    install: 'Instalar',
    sourceCode: 'Código-fonte',
    lookInside: 'Por dentro',
    shotTable: 'A mesa, com o monte, os ninhos e sete colunas de cartas',
    shotFigures: 'As doze figuras: reis, damas e valetes como calopsitas de cores diferentes',
    shotNote: 'O jogo segue o idioma do sistema, em português ou inglês.',
    whatItDoes: 'O que ele faz',
    feature1: 'Regras clássicas, com sete colunas, um monte e quatro ninhos',
    feature2: 'A pontuação clássica e um placar com as suas melhores partidas',
    feature3: 'Jogos numerados: o mesmo número sempre dá a mesma distribuição',
    feature4: 'Cartas que viram, pulam, balançam dizendo não na jogada errada e quicam quando você vence',
    feature5: 'Uma calopsita curiosa que espia a mesa quando você para para pensar',
    feature6: 'Funciona sem internet. Não envia nada para lugar nenhum',
    windowsIntro: 'No Windows 10 (1809 ou mais novo) ou no Windows 11, em x64. Não pede administrador.',
    windowsDownload: 'Baixar o instalador',
    windowsNote: 'O SmartScreen pode avisar que o editor é desconhecido, porque o instalador não tem um certificado pago. Escolha Mais informações e depois Executar assim mesmo.',
    debIntro: 'No Debian 13, Ubuntu 24.04, Mint 22 ou mais novos, em amd64. Ele atualiza junto com o sistema.',
    fedoraIntro: 'Em x86_64. Ele atualiza junto com o sistema. A primeira instalação pede para aceitar a chave de assinatura.',
    removeIntro: 'Para remover o jogo e o repositório',
    copy: 'Copiar',
    copied: 'Copiado',
    otherNote: `Outro sistema? Você pode <a href="${LATEST}">baixar o pacote</a> ou <a href="${SOURCE}">compilar do código-fonte</a>.`,
    links: 'Links',
    issues: 'Issues',
    issuesNote: 'Relatar um problema',
    releases: 'Versões',
    releasesNote: 'O que mudou em cada versão',
    githubNote: 'O código-fonte',
    footer: 'Código sob a licença Apache 2.0, arte das cartas sob CC0. Desenvolvido com o auxílio do Claude Code. Cartas ilustradas com o Google Gemini.',
  },
};

const KEY = 'psito-solitaire-lang';
const texts = new Map();
const alts = new Map();
for (const el of document.querySelectorAll('[data-t]')) texts.set(el, el.innerHTML);
for (const el of document.querySelectorAll('[data-t-alt]')) alts.set(el, el.alt);

function saved() {
  try { return localStorage.getItem(KEY); } catch { return null; }
}

function setLang(lang, remember) {
  const strings = STRINGS[lang];
  document.documentElement.lang = lang;
  document.getElementById('lang').value = lang;
  for (const [el, english] of texts) el.innerHTML = strings[el.dataset.t] ?? english;
  for (const [el, english] of alts) el.alt = strings[el.dataset.tAlt] ?? english;
  if (remember) {
    try { localStorage.setItem(KEY, lang); } catch {}
  }
}

const system = navigator.language.slice(0, 2).toLowerCase();
const start = saved() ?? system;
setLang(start in STRINGS ? start : 'en', false);
document.getElementById('lang').addEventListener('change', (event) => setLang(event.target.value, true));

for (const button of document.querySelectorAll('[data-copy]')) {
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(document.getElementById(button.dataset.copy).textContent);
      button.textContent = STRINGS[document.documentElement.lang].copied;
      setTimeout(() => {
        const strings = STRINGS[document.documentElement.lang];
        button.innerHTML = strings.copy ?? texts.get(button);
      }, 1500);
    } catch {
      // Sem acesso à área de transferência, o texto continua selecionável
    }
  });
}
