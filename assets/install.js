(function () {
  var KEY = 'tiflisi-install-once';
  var styleText = [
    '.install-sheet{position:fixed;z-index:120;left:max(12px,env(safe-area-inset-left,0px));right:max(12px,env(safe-area-inset-right,0px));bottom:calc(12px + env(safe-area-inset-bottom,0px));display:grid;grid-template-columns:48px 1fr;gap:10px 12px;max-width:440px;margin:0 auto;padding:14px;border-radius:18px;border:1px solid color-mix(in srgb,var(--ac) 42%,var(--br));background:color-mix(in srgb,var(--sf) 94%,var(--bg));box-shadow:0 16px 40px rgba(0,0,0,.28);color:var(--tx);font-family:inherit}',
    '.install-ico{width:48px;height:48px;border-radius:12px}',
    '.install-copy{min-width:0}',
    '.install-copy strong{display:block;font-size:.92rem;font-weight:800;letter-spacing:-.02em}',
    '.install-copy p{margin:3px 0 0;font-size:.75rem;line-height:1.4;color:var(--mu)}',
    '.install-actions{grid-column:1 / -1;display:flex;justify-content:flex-end;gap:8px}',
    '.install-later,.install-yes{min-height:44px;padding:0 16px;border-radius:999px;font:inherit;font-size:.8rem;font-weight:800;cursor:pointer}',
    '.install-later{background:transparent;color:var(--tx);border:1px solid var(--br)}',
    '.install-yes{background:var(--ac);color:var(--on-ac,#042f2e);border:none}',
    '.install-sheet{box-sizing:border-box}',
    '@media (max-width:719px){body:has(.vtog) .install-sheet{bottom:calc(108px + env(safe-area-inset-bottom,0px))}}',
    '@media print{.install-sheet{display:none !important}}'
  ].join('');
  var deferred = null;
  var shown = false;

  function remembered() {
    try { return localStorage.getItem(KEY) === '1'; } catch (e) { return true; }
  }
  function remember() {
    try { localStorage.setItem(KEY, '1'); } catch (e) {}
    try { sessionStorage.setItem(KEY, '1'); } catch (e) {}
  }
  function sessionSeen() {
    try { return sessionStorage.getItem(KEY) === '1'; } catch (e) { return false; }
  }
  function installed() {
    return window.matchMedia('(display-mode: standalone)').matches
      || window.matchMedia('(display-mode: minimal-ui)').matches
      || window.matchMedia('(display-mode: window-controls-overlay)').matches
      || navigator.standalone === true;
  }
  function isIOS() {
    var ua = navigator.userAgent || '';
    return /iPad|iPhone|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  }

  function hide(sheet) {
    if (!sheet) return;
    sheet.remove();
  }

  function show(kind) {
    if (shown || remembered() || sessionSeen() || installed()) return;
    shown = true;
    setTimeout(function () {
      try { sessionStorage.setItem(KEY, '1'); } catch (e) {}
    }, 1600);
    if (!document.getElementById('install-sheet-css')) {
      var css = document.createElement('style');
      css.id = 'install-sheet-css';
      css.textContent = styleText;
      document.head.appendChild(css);
    }

    var sheet = document.createElement('aside');
    sheet.className = 'install-sheet';
    sheet.setAttribute('role', 'dialog');
    sheet.setAttribute('aria-label', 'აპის დაყენება');

    var icon = document.createElement('img');
    icon.className = 'install-ico';
    icon.src = 'icon-192.png';
    icon.alt = '';
    icon.width = 48;
    icon.height = 48;

    var copy = document.createElement('div');
    copy.className = 'install-copy';
    var title = document.createElement('strong');
    var text = document.createElement('p');
    copy.appendChild(title);
    copy.appendChild(text);

    var actions = document.createElement('div');
    actions.className = 'install-actions';

    var later = document.createElement('button');
    later.type = 'button';
    later.className = 'install-later';
    later.textContent = kind === 'ios' ? 'გასაგებია' : 'ახლა არა';
    later.addEventListener('click', function () { remember(); hide(sheet); });

    if (kind === 'ios') {
      title.textContent = 'დაამატე აპი ეკრანზე';
      text.textContent = 'Safari-ში დააჭირე გაზიარებას, შემდეგ „მთავარ ეკრანზე დამატებას“.';
      actions.appendChild(later);
    } else {
      title.textContent = 'დააყენე აპი';
      text.textContent = 'განრიგი ტელეფონის მთავარ ეკრანზე გაიხსნება, აპივით.';
      var yes = document.createElement('button');
      yes.type = 'button';
      yes.className = 'install-yes';
      yes.textContent = 'დაყენება';
      yes.addEventListener('click', function () {
        if (!deferred) { hide(sheet); return; }
        var done = function () {
          remember();
          deferred = null;
          hide(sheet);
        };
        try {
          var choice = deferred.prompt();
          if (choice && choice.then) choice.then(done, done);
          else if (deferred && deferred.userChoice && deferred.userChoice.then) deferred.userChoice.then(done, done);
          else done();
        } catch (e) { done(); }
      });
      actions.appendChild(later);
      actions.appendChild(yes);
    }

    sheet.appendChild(icon);
    sheet.appendChild(copy);
    sheet.appendChild(actions);
    document.body.appendChild(sheet);
  }

  if (installed() || remembered() || sessionSeen()) return;

  window.addEventListener('beforeinstallprompt', function (e) {
    e.preventDefault();
    deferred = e;
    show('native');
  });
  window.addEventListener('appinstalled', function () {
    remember();
    var open = document.querySelector('.install-sheet');
    hide(open);
  });

  if (isIOS()) {
    window.addEventListener('load', function () {
      setTimeout(function () { show('ios'); }, 700);
    });
  }
})();
