/// In-memory single-page HTML5/JS Web Viewer served to audience devices on LAN.
/// 
/// Completely self-contained with ZERO external CDN dependencies so it works
/// 100% offline on local Wi-Fi, air-gapped routers, or mobile hotspots.
class EmbeddedWebViewerHtml {
  const EmbeddedWebViewerHtml._();

  static const String html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>FlutCanvas • Live Presentation</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; -webkit-user-select: none; }
    html, body { width: 100%; height: 100%; overflow: hidden; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #0f1219; color: #f1f5f9; }
    #canvas-container { position: absolute; top: 0; left: 0; width: 100%; height: 100%; overflow: hidden; cursor: grab; }
    #canvas-container:active { cursor: grabbing; }
    canvas { display: block; width: 100%; height: 100%; }

    /* HUD Bar */
    .hud {
      position: absolute;
      top: 14px;
      left: 14px;
      right: 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      pointer-events: none;
      z-index: 10;
    }
    .hud-group {
      display: flex;
      gap: 8px;
      align-items: center;
      pointer-events: auto;
    }
    .pill {
      background: rgba(22, 27, 38, 0.88);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 20px;
      padding: 6px 14px;
      font-size: 13px;
      font-weight: 500;
      display: inline-flex;
      align-items: center;
      gap: 7px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.3);
      transition: all 0.2s ease;
    }
    .live-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: #10b981;
      box-shadow: 0 0 10px #10b981;
      animation: pulse 1.8s infinite;
    }
    .live-dot.disconnected {
      background: #ef4444;
      box-shadow: 0 0 10px #ef4444;
      animation: none;
    }
    @keyframes pulse {
      0% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.85); }
      100% { opacity: 1; transform: scale(1); }
    }
    .btn {
      cursor: pointer;
      pointer-events: auto;
    }
    .btn:hover {
      background: rgba(30, 41, 59, 0.95);
      border-color: rgba(255, 255, 255, 0.25);
    }
    .btn.active {
      background: #2563eb;
      color: #fff;
      border-color: #3b82f6;
    }

    /* Slide Frame Badge */
    #slide-indicator {
      display: none;
      font-size: 12px;
      font-weight: 600;
      color: #93c5fd;
    }

    /* Bottom Zoom Controls */
    .bottom-hud {
      position: absolute;
      bottom: 16px;
      right: 16px;
      display: flex;
      gap: 6px;
      pointer-events: auto;
      z-index: 10;
    }
    .icon-btn {
      background: rgba(22, 27, 38, 0.88);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 10px;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      color: #cbd5e1;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.25);
      transition: background 0.15s;
    }
    .icon-btn:hover { background: rgba(51, 65, 85, 0.9); color: #fff; }
  </style>
</head>
<body>
  <div id="canvas-container">
    <canvas id="board"></canvas>
  </div>

  <div class="hud">
    <div class="hud-group">
      <div class="pill">
        <div id="status-dot" class="live-dot"></div>
        <span id="status-text">Connecting...</span>
      </div>
      <div id="slide-indicator" class="pill"></div>
    </div>

    <div class="hud-group">
      <div id="follow-btn" class="pill btn active" onclick="toggleFollow()">
        <span>🎯 Follow Presenter</span>
      </div>
      <div class="pill" id="viewers-count">
        <span>👥 1</span>
      </div>
    </div>
  </div>

  <div class="bottom-hud">
    <div class="icon-btn" onclick="resetZoom()" title="Reset Zoom">⤾</div>
    <div class="icon-btn" onclick="zoomIn()" title="Zoom In">+</div>
    <div class="icon-btn" onclick="zoomOut()" title="Zoom Out">−</div>
  </div>

  <script>
    // --- Canvas & Viewport State ---
    const canvas = document.getElementById('board');
    const ctx = canvas.getContext('2d');
    const container = document.getElementById('canvas-container');

    let elements = [];
    let isDark = true;
    let pan = { x: 0, y: 0 };
    let zoom = 1.0;
    let targetPan = { x: 0, y: 0 };
    let targetZoom = 1.0;
    let followPresenter = true;

    // Laser trail storage
    let laserPoints = []; // [{ x, y, time }]

    // Sizing
    function resize() {
      const dpr = window.devicePixelRatio || 1;
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      ctx.scale(dpr, dpr);
      render();
    }
    window.addEventListener('resize', resize);

    // --- WebSocket Client ---
    const statusDot = document.getElementById('status-dot');
    const statusText = document.getElementById('status-text');
    const followBtn = document.getElementById('follow-btn');
    const viewersCountEl = document.getElementById('viewers-count');
    const slideIndicator = document.getElementById('slide-indicator');

    let ws = null;
    let reconnectTimer = null;

    function connectWs() {
      const proto = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsUrl = proto + '//' + window.location.host + '/ws';

      ws = new WebSocket(wsUrl);

      ws.onopen = () => {
        statusDot.className = 'live-dot';
        statusText.textContent = 'Live Broadcast';
        if (reconnectTimer) clearTimeout(reconnectTimer);
      };

      ws.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          handleMessage(msg);
        } catch (e) {
          console.error('WS Parse Error', e);
        }
      };

      ws.onclose = () => {
        statusDot.className = 'live-dot disconnected';
        statusText.textContent = 'Disconnected • Reconnecting...';
        reconnectTimer = setTimeout(connectWs, 2000);
      };

      ws.onerror = () => ws.close();
    }

    function handleMessage(msg) {
      switch (msg.type) {
        case 'snapshot':
          elements = msg.elements || [];
          isDark = msg.isDark !== undefined ? msg.isDark : true;
          document.body.style.backgroundColor = isDark ? '#0f1219' : '#f8fafc';
          if (msg.panX !== undefined && msg.panY !== undefined && msg.zoom !== undefined) {
            targetPan = { x: msg.panX, y: msg.panY };
            targetZoom = msg.zoom;
            if (followPresenter) {
              pan = { ...targetPan };
              zoom = targetZoom;
            }
          }
          render();
          break;

        case 'viewport':
          targetPan = { x: msg.panX, y: msg.panY };
          targetZoom = msg.zoom;
          if (followPresenter) {
            // Smoothly lerp towards target
            requestLerp();
          }
          break;

        case 'laser':
          if (msg.points) {
            laserPoints = msg.points;
            render();
          }
          break;

        case 'slide_change':
          slideIndicator.style.display = 'inline-flex';
          slideIndicator.textContent = `Slide \${msg.slideIndex + 1} of \${msg.totalSlides}` + (msg.title ? ` • \${msg.title}` : '');
          if (followPresenter && msg.left !== undefined) {
            // Auto frame slide in view
            const pad = 60;
            const w = window.innerWidth - pad * 2;
            const h = window.innerHeight - pad * 2;
            const sX = w / msg.width;
            const sY = h / msg.height;
            targetZoom = Math.min(sX, sY, 2.0);
            targetPan = {
              x: (window.innerWidth / 2) - ((msg.left + msg.width / 2) * targetZoom),
              y: (window.innerHeight / 2) - ((msg.top + msg.height / 2) * targetZoom)
            };
            requestLerp();
          }
          break;

        case 'elements_update':
          elements = msg.elements || [];
          render();
          break;

        case 'viewer_count':
          viewersCountEl.innerHTML = `<span>👥 \${msg.count}</span>`;
          break;
      }
    }

    // --- Smooth Camera LERP Animation ---
    let lerping = false;
    function requestLerp() {
      if (!lerping) {
        lerping = true;
        requestAnimationFrame(lerpStep);
      }
    }

    function lerpStep() {
      if (!followPresenter) {
        lerping = false;
        return;
      }
      const factor = 0.22;
      const dx = targetPan.x - pan.x;
      const dy = targetPan.y - pan.y;
      const dz = targetZoom - zoom;

      pan.x += dx * factor;
      pan.y += dy * factor;
      zoom += dz * factor;

      render();

      if (Math.abs(dx) > 0.5 || Math.abs(dy) > 0.5 || Math.abs(dz) > 0.002) {
        requestAnimationFrame(lerpStep);
      } else {
        pan = { ...targetPan };
        zoom = targetZoom;
        lerping = false;
        render();
      }
    }

    function toggleFollow() {
      followPresenter = !followPresenter;
      if (followPresenter) {
        followBtn.classList.add('active');
        followBtn.innerHTML = '<span>🎯 Following Presenter</span>';
        requestLerp();
      } else {
        followBtn.classList.remove('active');
        followBtn.innerHTML = '<span>👀 Free Roam</span>';
      }
    }

    // --- Interactive Touch & Mouse Navigation ---
    let isDragging = false;
    let dragStart = { x: 0, y: 0 };
    let lastPan = { x: 0, y: 0 };

    container.addEventListener('mousedown', (e) => {
      isDragging = true;
      dragStart = { x: e.clientX, y: e.clientY };
      lastPan = { ...pan };
    });

    window.addEventListener('mousemove', (e) => {
      if (!isDragging) return;
      if (followPresenter) {
        // Break out to free roam if manually dragged
        toggleFollow();
      }
      pan.x = lastPan.x + (e.clientX - dragStart.x);
      pan.y = lastPan.y + (e.clientY - dragStart.y);
      render();
    });

    window.addEventListener('mouseup', () => { isDragging = false; });

    container.addEventListener('wheel', (e) => {
      e.preventDefault();
      if (followPresenter) toggleFollow();

      const zoomFactor = e.deltaY < 0 ? 1.15 : 0.85;
      const mouseX = e.clientX;
      const mouseY = e.clientY;

      const newZoom = Math.min(Math.max(zoom * zoomFactor, 0.1), 8.0);
      pan.x = mouseX - (mouseX - pan.x) * (newZoom / zoom);
      pan.y = mouseY - (mouseY - pan.y) * (newZoom / zoom);
      zoom = newZoom;
      render();
    }, { passive: false });

    // Touch Support (Pinch-to-zoom & Drag)
    let initialTouchDist = null;
    let initialTouchZoom = zoom;

    container.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) {
        isDragging = true;
        dragStart = { x: e.touches[0].clientX, y: e.touches[0].clientY };
        lastPan = { ...pan };
      } else if (e.touches.length === 2) {
        isDragging = false;
        initialTouchDist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        initialTouchZoom = zoom;
      }
    });

    container.addEventListener('touchmove', (e) => {
      e.preventDefault();
      if (followPresenter) toggleFollow();

      if (e.touches.length === 1 && isDragging) {
        pan.x = lastPan.x + (e.touches[0].clientX - dragStart.x);
        pan.y = lastPan.y + (e.touches[0].clientY - dragStart.y);
        render();
      } else if (e.touches.length === 2 && initialTouchDist) {
        const dist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        const midX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
        const midY = (e.touches[0].clientY + e.touches[1].clientY) / 2;

        const newZoom = Math.min(Math.max(initialTouchZoom * (dist / initialTouchDist), 0.15), 6.0);
        pan.x = midX - (midX - pan.x) * (newZoom / zoom);
        pan.y = midY - (midY - pan.y) * (newZoom / zoom);
        zoom = newZoom;
        render();
      }
    }, { passive: false });

    container.addEventListener('touchend', () => {
      isDragging = false;
      initialTouchDist = null;
    });

    function resetZoom() {
      if (followPresenter) toggleFollow();
      zoom = 1.0;
      pan = { x: window.innerWidth / 4, y: window.innerHeight / 4 };
      render();
    }
    function zoomIn() {
      if (followPresenter) toggleFollow();
      zoom = Math.min(zoom * 1.25, 8.0);
      render();
    }
    function zoomOut() {
      if (followPresenter) toggleFollow();
      zoom = Math.max(zoom * 0.8, 0.1);
      render();
    }

    // --- Drawing Engine ---
    function render() {
      ctx.save();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Background Grid
      drawGrid();

      // World Transform
      ctx.translate(pan.x, pan.y);
      ctx.scale(zoom, zoom);

      // 1. Elements
      for (const el of elements) {
        if (el.isVisible === false) continue;
        drawElement(el);
      }

      // 2. Laser Trail
      drawLaser();

      ctx.restore();
    }

    function drawGrid() {
      const gridSize = 24 * zoom;
      if (gridSize < 12) return;

      const offsetX = pan.x % gridSize;
      const offsetY = pan.y % gridSize;
      const dotColor = isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.06)';

      ctx.fillStyle = dotColor;
      for (let x = offsetX; x < window.innerWidth; x += gridSize) {
        for (let y = offsetY; y < window.innerHeight; y += gridSize) {
          ctx.beginPath();
          ctx.arc(x, y, 1.2, 0, Math.PI * 2);
          ctx.fill();
        }
      }
    }

    function colorHex(c) {
      if (!c) return '#000000';
      if (typeof c === 'string') return c;
      const hex = (c >>> 0).toString(16).padStart(8, '0');
      return '#' + hex.substring(2) + hex.substring(0, 2);
    }

    function drawElement(el) {
      const x = Math.min(el.start.x, el.end.x);
      const y = Math.min(el.start.y, el.end.y);
      const w = Math.abs(el.end.x - el.start.x);
      const h = Math.abs(el.end.y - el.start.y);

      ctx.save();
      ctx.globalAlpha = el.opacity !== undefined ? el.opacity : 1.0;
      ctx.lineWidth = el.strokeWidth || 2;
      ctx.strokeStyle = el.color ? colorHex(el.color) : (isDark ? '#e2e8f0' : '#1e293b');

      switch (el.type) {
        case 'rectangle':
        case 'roundedRectangle':
          const radius = el.type === 'roundedRectangle' ? 12 : 0;
          ctx.fillStyle = el.fillColor && el.fillColor !== 0 ? colorHex(el.fillColor) : 'transparent';
          roundRect(ctx, x, y, w, h, radius, true, true);
          break;

        case 'ellipse':
          ctx.fillStyle = el.fillColor && el.fillColor !== 0 ? colorHex(el.fillColor) : 'transparent';
          ctx.beginPath();
          ctx.ellipse(x + w / 2, y + h / 2, w / 2, h / 2, 0, 0, Math.PI * 2);
          if (el.fillColor) ctx.fill();
          ctx.stroke();
          break;

        case 'stickyNote':
          ctx.fillStyle = el.fillColor && el.fillColor !== 0 ? colorHex(el.fillColor) : '#fef08a';
          ctx.shadowColor = 'rgba(0,0,0,0.2)';
          ctx.shadowBlur = 10;
          ctx.shadowOffsetY = 4;
          roundRect(ctx, x, y, w, h, 6, true, false);
          ctx.shadowColor = 'transparent';
          // Draw text
          if (el.text) {
            ctx.fillStyle = '#1e293b';
            ctx.font = '500 14px sans-serif';
            wrapText(ctx, el.text, x + 12, y + 24, w - 24, 18);
          }
          break;

        case 'frame':
          ctx.strokeStyle = 'rgba(59, 130, 246, 0.7)';
          ctx.setLineDash([6, 6]);
          roundRect(ctx, x, y, w, h, 8, false, true);
          ctx.setLineDash([]);
          // Frame header
          ctx.fillStyle = 'rgba(59, 130, 246, 0.9)';
          ctx.font = '600 12px sans-serif';
          ctx.fillText(el.frameTitle || 'Slide Frame', x + 6, y - 8);
          break;

        case 'line':
        case 'arrow':
          ctx.beginPath();
          ctx.moveTo(el.start.x, el.start.y);
          ctx.lineTo(el.end.x, el.end.y);
          ctx.stroke();
          if (el.type === 'arrow') {
            drawArrowHead(ctx, el.start.x, el.start.y, el.end.x, el.end.y);
          }
          break;

        case 'icon':
          ctx.fillStyle = isDark ? '#1e222d' : '#ffffff';
          roundRect(ctx, x, y, w, h, 10, true, true);
          // Badge
          ctx.fillStyle = el.color ? colorHex(el.color) : '#3b82f6';
          roundRect(ctx, x + 8, y + 8, 30, 30, 6, true, false);
          // Label
          ctx.fillStyle = isDark ? '#f8fafc' : '#1e293b';
          ctx.font = '600 12px sans-serif';
          ctx.textAlign = 'center';
          ctx.fillText(el.text || el.label || 'Node', x + w / 2, y + h - 14);
          ctx.textAlign = 'start';
          break;

        case 'text':
          ctx.fillStyle = el.color ? colorHex(el.color) : (isDark ? '#f8fafc' : '#1e293b');
          ctx.font = (el.fontSize || 20) + 'px sans-serif';
          ctx.fillText(el.text || '', x, y + (el.fontSize || 20));
          break;

        case 'pen':
        case 'highlighter':
          if (el.points && el.points.length > 1) {
            ctx.beginPath();
            ctx.moveTo(el.points[0].x, el.points[0].y);
            for (let i = 1; i < el.points.length; i++) {
              ctx.lineTo(el.points[i].x, el.points[i].y);
            }
            if (el.type === 'highlighter') {
              ctx.globalAlpha = 0.35;
              ctx.lineWidth = 14;
            }
            ctx.stroke();
          }
          break;
      }

      ctx.restore();
    }

    function roundRect(ctx, x, y, w, h, r, fill, stroke) {
      if (w < 2 * r) r = w / 2;
      if (h < 2 * r) r = h / 2;
      ctx.beginPath();
      ctx.moveTo(x + r, y);
      ctx.arcTo(x + w, y, x + w, y + h, r);
      ctx.arcTo(x + w, y + h, x, y + h, r);
      ctx.arcTo(x, y + h, x, y, r);
      ctx.arcTo(x, y, x + w, y, r);
      ctx.closePath();
      if (fill) ctx.fill();
      if (stroke) ctx.stroke();
    }

    function drawArrowHead(ctx, fromx, fromy, tox, toy) {
      const headlen = 12;
      const angle = Math.atan2(toy - fromy, tox - fromx);
      ctx.fillStyle = ctx.strokeStyle;
      ctx.beginPath();
      ctx.moveTo(tox, toy);
      ctx.lineTo(tox - headlen * Math.cos(angle - Math.PI / 6), toy - headlen * Math.sin(angle - Math.PI / 6));
      ctx.lineTo(tox - headlen * Math.cos(angle + Math.PI / 6), toy - headlen * Math.sin(angle + Math.PI / 6));
      ctx.closePath();
      ctx.fill();
    }

    function wrapText(ctx, text, x, y, maxWidth, lineHeight) {
      const words = text.split(' ');
      let line = '';
      for (let n = 0; n < words.length; n++) {
        const testLine = line + words[n] + ' ';
        const metrics = ctx.measureText(testLine);
        if (metrics.width > maxWidth && n > 0) {
          ctx.fillText(line, x, y);
          line = words[n] + ' ';
          y += lineHeight;
        } else {
          line = testLine;
        }
      }
      ctx.fillText(line, x, y);
    }

    function drawLaser() {
      if (!laserPoints || laserPoints.length < 1) return;
      ctx.save();
      ctx.strokeStyle = '#ff3366';
      ctx.fillStyle = '#ff3366';
      ctx.shadowColor = '#ff1155';
      ctx.shadowBlur = 14;
      ctx.lineWidth = 4;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';

      if (laserPoints.length === 1) {
        ctx.beginPath();
        ctx.arc(laserPoints[0].x, laserPoints[0].y, 5, 0, Math.PI * 2);
        ctx.fill();
      } else {
        ctx.beginPath();
        ctx.moveTo(laserPoints[0].x, laserPoints[0].y);
        for (let i = 1; i < laserPoints.length; i++) {
          ctx.lineTo(laserPoints[i].x, laserPoints[i].y);
        }
        ctx.stroke();

        const last = laserPoints[laserPoints.length - 1];
        ctx.beginPath();
        ctx.arc(last.x, last.y, 6, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.restore();
    }

    // Auto-fade laser points every frame
    function tickLaser() {
      if (laserPoints.length > 0) {
        const now = Date.now();
        laserPoints = laserPoints.filter(p => now - p.time < 900);
        render();
      }
      requestAnimationFrame(tickLaser);
    }

    // Init
    resize();
    connectWs();
    requestAnimationFrame(tickLaser);
  </script>
</body>
</html>
''';
}
