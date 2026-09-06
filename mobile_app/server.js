const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5000;
const PUBLIC_DIR = __dirname;

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.apk': 'application/vnd.android.package-archive'
};

const APK_PATH = path.join(__dirname, '..', 'PYP-PickYourPhotographer.apk');

const server = http.createServer((req, res) => {
  const urlPath = req.url.split('?')[0];

  // Direct APK Download Endpoint
  if (urlPath === '/download-apk' || urlPath === '/PYP-PickYourPhotographer.apk' || urlPath === '/pyp.apk') {
    if (fs.existsSync(APK_PATH)) {
      const stat = fs.statSync(APK_PATH);
      res.writeHead(200, {
        'Content-Type': 'application/vnd.android.package-archive',
        'Content-Disposition': 'attachment; filename="PYP-PickYourPhotographer.apk"',
        'Content-Length': stat.size,
        'Access-Control-Allow-Origin': '*'
      });
      const readStream = fs.createReadStream(APK_PATH);
      readStream.pipe(res);
      return;
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('APK file not found on server');
      return;
    }
  }

  let reqUrl = req.url === '/' ? '/index.html' : req.url;
  let filePath = path.join(PUBLIC_DIR, reqUrl.split('?')[0]);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      filePath = path.join(PUBLIC_DIR, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (readErr, content) => {
      if (readErr) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('500 Server Error');
        return;
      }
      res.writeHead(200, {
        'Content-Type': contentType,
        'Access-Control-Allow-Origin': '*'
      });
      res.end(content);
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`PYP Mobile Server running live at http://0.0.0.0:${PORT}`);
});
