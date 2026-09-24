(function () {
  "use strict";

  var REFRESH_MS = 20000;
  var TIMEOUT_MS = 4000;

  var app = document.getElementById("app");
  var summary = document.getElementById("summary");
  var search = document.getElementById("search");

  var cards = [];

  // Aberto por outro computador da rede? "localhost" vira o host atual.
  function localize(url) {
    if (!url) return url;
    var here = window.location.hostname;
    if (here === "localhost" || here === "127.0.0.1" || here === "") return url;
    return url.replace(/\/\/(localhost|127\.0\.0\.1)(?=[:\/]|$)/, "//" + here);
  }

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function build(config) {
    app.textContent = "";
    cards = [];

    config.groups.forEach(function (group) {
      var section = el("section");
      section.appendChild(el("h2", "", group.name));
      var grid = el("div", "grid");

      group.services.forEach(function (service) {
        var href = localize(service.url);
        var link = el("a", "card");
        link.href = href;
        link.target = "_blank";
        link.rel = "noopener noreferrer";

        var head = el("div", "card-head");
        head.appendChild(el("span", "icon", service.icon || "•"));
        head.appendChild(el("span", "name", service.name));
        link.appendChild(head);

        link.appendChild(el("span", "desc", service.description || ""));
        link.appendChild(el("span", "url", href));

        var status = el("span", "status");
        status.dataset.state = "wait";
        status.appendChild(el("span", "dot"));
        var label = el("span", "", "verificando");
        status.appendChild(label);
        link.appendChild(status);

        grid.appendChild(link);

        cards.push({
          node: link,
          status: status,
          label: label,
          search: (service.name + " " + (service.description || "")).toLowerCase(),
          probeId: service.id && service.probe ? service.id : null,
          checkUrl: service.check === false ? null : localize(service.check || service.url),
          external: !!service.external
        });
      });

      section.appendChild(grid);
      app.appendChild(section);
    });
  }

  function setState(card, state, text) {
    card.status.dataset.state = state;
    card.label.textContent = text;
  }

  function timeboxed(url, options) {
    var controller = new AbortController();
    var timer = setTimeout(function () { controller.abort(); }, TIMEOUT_MS);
    options.signal = controller.signal;
    return fetch(url, options).then(
      function (response) { clearTimeout(timer); return response; },
      function (error) { clearTimeout(timer); throw error; }
    );
  }

  // Serviços do Orion: quem verifica é o nginx do dashboard (/probe/<id>),
  // por dentro da rede Docker. Ele devolve 502/504 se o container não
  // responde; qualquer outro status (200, 302, 401...) significa "no ar".
  function probeViaServer(card) {
    return timeboxed("probe/" + card.probeId, { cache: "no-store" })
      .then(function (response) { return response.status < 500; });
  }

  // Serviços fora do Orion: "no-cors" não deixa ler a resposta, mas basta
  // para saber se a porta atende (resolve = respondeu, rejeita = caiu).
  function probeViaBrowser(card) {
    return timeboxed(card.checkUrl, { mode: "no-cors", cache: "no-store" })
      .then(function () { return true; });
  }

  function probe(card) {
    if (!card.probeId && !card.checkUrl) {
      setState(card, "wait", card.external ? "externo" : "não verificado");
      return Promise.resolve(null);
    }
    return (card.probeId ? probeViaServer(card) : probeViaBrowser(card))
      .catch(function () { return false; })
      .then(function (up) {
        setState(card, up ? "up" : "down", up ? "online" : "fora do ar");
        return up;
      });
  }

  function refresh() {
    return Promise.all(cards.map(probe)).then(function (results) {
      var checked = results.filter(function (r) { return r !== null; });
      var up = checked.filter(Boolean).length;
      summary.textContent = up + " de " + checked.length + " serviços online";
    });
  }

  function applyFilter() {
    var term = search.value.trim().toLowerCase();
    var visible = 0;
    cards.forEach(function (card) {
      var show = !term || card.search.indexOf(term) !== -1;
      card.node.hidden = !show;
      if (show) visible++;
    });
    document.querySelectorAll("section").forEach(function (section) {
      section.hidden = !section.querySelector(".card:not([hidden])");
    });
    var empty = document.getElementById("empty");
    if (!visible && !empty) {
      empty = el("p", "empty", "Nenhum serviço encontrado.");
      empty.id = "empty";
      app.appendChild(empty);
    } else if (visible && empty) {
      empty.remove();
    }
  }

  search.addEventListener("input", applyFilter);
  search.addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      var first = cards.filter(function (c) { return !c.node.hidden; })[0];
      if (first) first.node.click();
    }
    if (event.key === "Escape") { search.value = ""; applyFilter(); search.blur(); }
  });
  document.addEventListener("keydown", function (event) {
    if (event.key === "/" && document.activeElement !== search) {
      event.preventDefault();
      search.focus();
    }
  });

  fetch("services.json", { cache: "no-store" })
    .then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    })
    .then(function (config) {
      build(config);
      refresh();
      setInterval(refresh, REFRESH_MS);
    })
    .catch(function (error) {
      summary.textContent = "Não foi possível carregar services.json (" + error.message + ")";
    });
})();
