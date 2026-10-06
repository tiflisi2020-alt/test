(function () {
  var DEPTS = [
    { file: 'waiters.html', label: 'მიმტანი' },
    { file: 'chefs.html', label: 'მზარეული' },
    { file: 'cleaning.html', label: 'დალაგება' },
    { file: 'cashier.html', label: 'მოლარე' },
    { file: 'hostess.html', label: 'ჰოსტესი' }
  ];
  var WEEKDAYS = ['კვირა', 'ორშაბათი', 'სამშაბათი', 'ოთხშაბათი', 'ხუთშაბათი', 'პარასკევი', 'შაბათი'];
  var MONTHS = ['იანვარი', 'თებერვალი', 'მარტი', 'აპრილი', 'მაისი', 'ივნისი', 'ივლისი', 'აგვისტო', 'სექტემბერი', 'ოქტომბერი', 'ნოემბერი', 'დეკემბერი'];

  var current = (location.pathname.split('/').pop() || '').toLowerCase();
  var didInitialScroll = false;
  var raf = 0;

  function mountDeptNav() {
    var hdr = document.querySelector('.hdr');
    if (!hdr || hdr.querySelector('.dept-nav')) return;
    var nav = document.createElement('nav');
    nav.className = 'dept-nav';
    nav.setAttribute('aria-label', 'განყოფილებები');
    DEPTS.forEach(function (d) {
      var a = document.createElement('a');
      a.className = 'dept-link' + (current === d.file ? ' is-current' : '');
      a.href = d.file;
      a.textContent = d.label;
      if (current === d.file) a.setAttribute('aria-current', 'page');
      nav.appendChild(a);
    });
    var top = hdr.querySelector('.hdr-top');
    if (top) top.insertAdjacentElement('afterend', nav);
    else hdr.appendChild(nav);
    var here = nav.querySelector('.is-current');
    if (here) {
      var navBox = nav.getBoundingClientRect();
      var chipBox = here.getBoundingClientRect();
      if (chipBox.right > navBox.right - 6) nav.scrollLeft += chipBox.right - navBox.right + 8;
      else if (chipBox.left < navBox.left + 6) nav.scrollLeft -= navBox.left - chipBox.left + 8;
    }
  }

  function mountTodayBtn() {
    var label = document.getElementById('wkLabel');
    if (!label || document.getElementById('wkTodayBtn')) return;
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.id = 'wkTodayBtn';
    btn.className = 'wk-nav-btn wk-today-btn';
    btn.textContent = 'დღეს';
    btn.addEventListener('click', goToday);
    label.insertAdjacentElement('afterend', btn);
    syncTodayBtn();
  }

  function mountTodayBoard() {
    var section = document.querySelector('.wk-section');
    if (!section || document.getElementById('todayBoard')) return;
    var board = document.createElement('section');
    board.id = 'todayBoard';
    board.className = 'today-board';
    board.hidden = true;
    board.setAttribute('aria-label', 'დღევანდელი ცვლა');
    var nav = section.querySelector('.wk-nav');
    if (nav) section.insertBefore(board, nav);
    else section.prepend(board);
  }

  function polishChrome() {
    document.querySelectorAll('.abtn').forEach(function (btn) {
      btn.childNodes.forEach(function (node) {
        if (node.nodeType === 3 && node.textContent.indexOf('Admin') !== -1) {
          node.textContent = node.textContent.replace('Admin', 'ადმინი');
        }
      });
    });
    var home = document.querySelector('.hdr a.abtn');
    if (home) home.setAttribute('aria-label', 'მთავარი');
    var theme = document.getElementById('themeBtn');
    if (theme) theme.setAttribute('aria-label', 'თემის შეცვლა');
    document.querySelectorAll('.hdr button.abtn[onclick*="doPrint"]').forEach(function (btn) {
      btn.setAttribute('aria-label', 'ბეჭდვა');
    });
  }

  function goToday() {
    if (typeof wkOff === 'undefined' || typeof shiftWeek !== 'function') return;
    if (wkOff !== 0) shiftWeek(-wkOff);
    requestAnimationFrame(function () { scrollTodayCol(true); });
  }

  function syncTodayBtn() {
    var btn = document.getElementById('wkTodayBtn');
    if (!btn || typeof wkOff === 'undefined') return;
    var here = wkOff === 0;
    btn.classList.toggle('is-current', here);
    btn.setAttribute('aria-pressed', here ? 'true' : 'false');
    btn.title = here ? 'ნაჩვენებია მიმდინარე კვირა' : 'მიმდინარე კვირაზე დაბრუნება';
  }

  function polishSync() {
    var sd = document.getElementById('sd');
    var st = document.getElementById('st');
    if (!sd || !st) return;
    st.classList.toggle('is-quiet', sd.classList.contains('ok'));
  }

  function scrollTodayCol(force) {
    if (!force && didInitialScroll) return;
    var grid = document.getElementById('wkGrid');
    var col = grid && grid.querySelector('.wk-col.today');
    if (!grid || !col || grid.clientWidth < 40) return;
    if (grid.scrollWidth <= grid.clientWidth + 8) {
      didInitialScroll = true;
      return;
    }
    didInitialScroll = true;
    var left = col.offsetLeft - (grid.clientWidth - col.offsetWidth) / 2;
    grid.scrollTo({ left: Math.max(0, left), behavior: force ? 'smooth' : 'auto' });
  }

  function shiftClass(el) {
    return ['m', 'a', 'e', 'o'].filter(function (c) { return el.classList.contains(c); }).join(' ');
  }

  function todayChip(card) {
    var today = String(new Date().getDate());
    var found = null;
    card.querySelectorAll('.chip').forEach(function (chip) {
      var num = chip.querySelector('.cn');
      if (num && num.textContent.trim() === today) found = chip;
    });
    return found;
  }

  function chipShift(chip) {
    return (chip && chip.querySelector('.ct') && chip.querySelector('.ct').textContent.trim()) || '';
  }

  function chipPos(chip) {
    return (chip && chip.querySelector('.cp') && chip.querySelector('.cp').textContent.trim()) || '';
  }

  function formatPhone(digits) {
    if (digits.length === 9) {
      return digits.slice(0, 3) + ' ' + digits.slice(3, 5) + ' ' + digits.slice(5, 7) + ' ' + digits.slice(7);
    }
    return digits;
  }

  function pinToday() {
    var cards = document.querySelectorAll('#vw .wcard');
    if (!cards.length) return;
    var show = typeof wkOff === 'undefined' || wkOff === 0;
    cards.forEach(function (card) {
      var existing = card.querySelector('.today-pin');
      var chip = show ? todayChip(card) : null;
      var shift = chipShift(chip);
      var off = !shift || shift === 'OFF';
      card.classList.toggle('is-off-today', show && !!chip && off);
      if (!show || !chip || off) {
        if (existing) existing.remove();
        return;
      }
      var pos = chipPos(chip);
      var text = pos ? (shift + ' · ' + pos) : shift;
      var cls = 'today-pin ' + shiftClass(chip);
      var wi = card.querySelector('.wi');
      if (!wi) return;
      if (existing && existing.textContent === text && existing.className === cls) return;
      if (!existing) {
        existing = document.createElement('div');
        wi.appendChild(existing);
      }
      existing.className = cls;
      existing.textContent = text;
    });
  }

  function linkPhones() {
    document.querySelectorAll('#vw .wp').forEach(function (el) {
      if (el.querySelector('a')) return;
      var raw = (el.textContent || '').trim();
      var digits = raw.replace(/\D/g, '');
      if (digits.length < 6) return;
      var a = document.createElement('a');
      a.className = 'phone-link';
      a.href = 'tel:' + digits;
      a.textContent = formatPhone(digits);
      a.addEventListener('click', function (e) { e.stopPropagation(); });
      el.textContent = '';
      el.appendChild(a);
    });
  }

  function renderTodayBoard() {
    var board = document.getElementById('todayBoard');
    if (!board) return;
    var show = typeof wkOff === 'undefined' || wkOff === 0;
    var cards = document.querySelectorAll('#vw .wcard');
    if (!show || !cards.length) {
      if (!board.hidden) board.hidden = true;
      board.dataset.sig = '';
      return;
    }
    var people = [];
    cards.forEach(function (card) {
      var nameEl = card.querySelector('.wn');
      var name = nameEl ? nameEl.textContent.trim() : '';
      var chip = todayChip(card);
      var shift = chipShift(chip);
      if (!name || !shift || shift === 'OFF') return;
      var pos = chipPos(chip);
      var tel = card.querySelector('.phone-link');
      people.push({
        name: name,
        shift: pos ? (shift + ' · ' + pos) : shift,
        href: tel ? tel.getAttribute('href') : ''
      });
    });
    people.sort(function (a, b) {
      if (a.shift < b.shift) return -1;
      if (a.shift > b.shift) return 1;
      return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
    });
    var now = new Date();
    var dateLine = WEEKDAYS[now.getDay()] + ', ' + now.getDate() + ' ' + MONTHS[now.getMonth()];
    var sig = dateLine + '|' + people.map(function (p) { return p.name + '=' + p.shift; }).join(';');
    if (board.dataset.sig === sig && !board.hidden) return;
    board.dataset.sig = sig;
    board.hidden = false;
    board.classList.toggle('is-dense', people.length > 3);
    var head = '<div class="today-head"><div><div class="today-kicker">დღეს სამსახურში</div><div class="today-date">' + dateLine + '</div></div><div class="today-count">' + people.length + '</div></div>';
    if (!people.length) {
      board.innerHTML = head + '<p class="today-empty">დღეს სამუშაო ცვლა არავის აქვს.</p>';
      return;
    }
    board.innerHTML = head + '<div class="today-list">' + people.map(function (p) {
      var shift = p.shift.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      var name = p.name.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      if (p.href) {
        return '<a class="today-person" href="' + p.href + '"><span class="today-name">' + name + '</span><span class="today-shift">' + shift + '</span></a>';
      }
      return '<div class="today-person"><span class="today-name">' + name + '</span><span class="today-shift">' + shift + '</span></div>';
    }).join('') + '</div>';
  }

  function markTodayColumn() {
    document.querySelectorAll('.is-today').forEach(function (el) { el.classList.remove('is-today'); });
    if (typeof wkOff !== 'undefined' && wkOff !== 0) return;
    var day = String(new Date().getDate());
    document.querySelectorAll('#dth th').forEach(function (th, i) {
      var n = th.querySelector('.thn');
      if (!n || n.textContent.trim() !== day) return;
      th.classList.add('is-today');
      document.querySelectorAll('#dtb tr').forEach(function (tr) {
        if (tr.children[i]) tr.children[i].classList.add('is-today');
      });
    });
  }

  function refresh() {
    syncTodayBtn();
    polishSync();
    pinToday();
    linkPhones();
    renderTodayBoard();
    markTodayColumn();
    scrollTodayCol(false);
  }

  function scheduleRefresh() {
    if (raf) return;
    raf = requestAnimationFrame(function () {
      raf = 0;
      refresh();
    });
  }

  function watch(el, options) {
    if (!el || typeof MutationObserver === 'undefined') return;
    new MutationObserver(scheduleRefresh).observe(el, options);
  }

  function tabKey(btn) {
    var match = (btn.getAttribute('onclick') || '').match(/aTab\('([^']+)'/);
    return match ? match[1] : '';
  }

  function mountAdmin() {
    var modal = document.querySelector('#adminOv .modal');
    var tabs = modal && modal.querySelector('.atabs');
    var body = modal && modal.querySelector('.mbody');
    if (!modal || !tabs || !body || modal.querySelector('.admin-shell')) return;

    var known = {
      grid: 'ცხრილი',
      cal: 'კალენდარი',
      copy: 'კოპირება',
      shifts: 'ცვლები',
      positions: 'პოზიციები',
      stats: 'სტატისტიკა',
      notif: 'შეტყობინება',
      password: 'პაროლი'
    };
    var groups = [
      { label: 'განრიგი', keys: ['grid', 'cal', 'copy'] },
      { label: 'გუნდი', keys: ['staff', 'shifts', 'positions'] },
      { label: 'პარამეტრები', keys: ['stats', 'notif', 'password'] }
    ];
    var buttons = Array.prototype.slice.call(tabs.querySelectorAll('.atab'));
    var byKey = {};
    var staffBtn = null;
    buttons.forEach(function (btn) {
      var key = tabKey(btn);
      btn.classList.add('admin-item');
      if (known[key]) {
        byKey[key] = btn;
        btn.textContent = known[key];
      } else {
        staffBtn = btn;
        btn.textContent = 'თანამშრომლები';
      }
    });

    var nav = document.createElement('nav');
    nav.className = 'admin-nav';
    nav.setAttribute('aria-label', 'ადმინის სექციები');
    groups.forEach(function (group) {
      var label = document.createElement('p');
      label.className = 'admin-nav-label';
      label.textContent = group.label;
      nav.appendChild(label);
      group.keys.forEach(function (key) {
        var btn = key === 'staff' ? staffBtn : byKey[key];
        if (btn) nav.appendChild(btn);
      });
    });

    var main = document.createElement('div');
    main.className = 'admin-main';
    tabs.remove();
    while (body.firstChild) main.appendChild(body.firstChild);

    var shell = document.createElement('div');
    shell.className = 'admin-shell';
    shell.appendChild(nav);
    shell.appendChild(main);
    body.appendChild(shell);

    var title = document.querySelector('.hdr h1');
    var heading = modal.querySelector('.mhdr h2');
    if (heading) heading.textContent = title ? title.textContent.replace(/\s+/g, ' ').trim() : 'ადმინი';
    var loginHeading = document.querySelector('#loginOv .mhdr h2');
    if (loginHeading) loginHeading.textContent = 'ადმინში შესვლა';
    document.querySelectorAll('.xbtn').forEach(function (btn) {
      btn.setAttribute('aria-label', 'დახურვა');
    });
    ['cashiersList', 'chefsList', 'waitersList', 'cleanersList', 'hostessesList'].forEach(function (id) {
      var list = document.getElementById(id);
      if (list) list.classList.add('team-list');
    });
    document.querySelectorAll('.flt-clear').forEach(function (btn) {
      if ((btn.getAttribute('onclick') || '').indexOf('delete') !== -1) btn.classList.add('is-danger');
    });
  }

  function unifyViews() {
    var buttons = document.querySelectorAll('.vtog .vbtn');
    if (buttons[0]) buttons[0].textContent = 'სიით';
    if (buttons[1]) buttons[1].textContent = 'დღით';
  }

  mountDeptNav();
  mountTodayBtn();
  mountTodayBoard();
  mountAdmin();
  unifyViews();
  polishChrome();
  if (typeof shiftWeek === 'function' && !shiftWeek.__comfort) {
    var orig = shiftWeek;
    var wrapped = function (d) {
      var out = orig(d);
      scheduleRefresh();
      return out;
    };
    wrapped.__comfort = true;
    window.shiftWeek = wrapped;
  }
  watch(document.getElementById('wkGrid'), { childList: true, subtree: true });
  watch(document.getElementById('vw'), { childList: true, subtree: true });
  watch(document.getElementById('dtb'), { childList: true, subtree: true });
  watch(document.getElementById('dth'), { childList: true, subtree: true });
  watch(document.getElementById('sd'), { attributes: true, attributeFilter: ['class'] });
  refresh();

  if (window.visualViewport) {
    var vv = window.visualViewport;
    var fitKeyboard = function () {
      var overlap = Math.max(0, window.innerHeight - vv.height - vv.offsetTop);
      document.documentElement.style.setProperty('--kb', Math.round(overlap) + 'px');
    };
    vv.addEventListener('resize', fitKeyboard);
    vv.addEventListener('scroll', fitKeyboard);
    fitKeyboard();
  }
  function syncThemeColor() {
    var m = document.querySelector('meta[name="theme-color"]');
    if (!m) return;
    var light = document.documentElement.classList.contains('light');
    m.setAttribute('content', light ? '#f0fdfa' : '#0d9488');
  }
  syncThemeColor();
  new MutationObserver(syncThemeColor).observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });

  document.addEventListener('focusin', function (e) {
    var el = e.target;
    if (!el || !el.matches || !el.matches('input, textarea, select')) return;
    setTimeout(function () {
      try { el.scrollIntoView({ block: 'center', inline: 'nearest' }); } catch (_) {}
    }, 280);
  });
})();
