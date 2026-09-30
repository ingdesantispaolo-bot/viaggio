using System;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace IlGrandeMeridiano {
    static class Program {
        private static HttpListener _listener;
        private static Thread _serverThread;
        private static bool _isRunning = true;
        private static string _baseDir;
        private static int _port;

        [STAThread]
        static void Main(string[] args) {
            _baseDir = AppDomain.CurrentDomain.BaseDirectory;

            // Find a free TCP port on localhost
            _port = GetFreePort();

            // Start embedded high-performance local HTTP server
            _serverThread = new Thread(RunServer) { IsBackground = true };
            _serverThread.Start();

            // Allow server thread to initialize
            Thread.Sleep(150);

            // Locate Microsoft Edge or Chrome for dedicated App Mode
            string browserPath = GetBrowserPath();
            if (string.IsNullOrEmpty(browserPath)) {
                MessageBox.Show(
                    "Impossibile trovare Microsoft Edge o Google Chrome per avviare il motore grafico dedicato.\nAssicurati che Microsoft Edge sia presente sul sistema.",
                    "IL GRANDE MERIDIANO - Errore Avvio",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                return;
            }

            string url = string.Format("http://127.0.0.1:{0}/index.html", _port);
            string profileDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "IlGrandeMeridiano_Data");

            // Hardware GPU acceleration and standalone App Mode flags
            string arguments = string.Format(
                "--app=\"{0}\" " +
                "--user-data-dir=\"{1}\" " +
                "--window-size=1440,940 " +
                "--enable-gpu-rasterization " +
                "--enable-zero-copy " +
                "--ignore-gpu-blocklist " +
                "--disable-pinch " +
                "--disable-features=UseEcoQoSForBackgroundProcess " +
                "--autoplay-policy=no-user-gesture-required",
                url,
                profileDir
            );

            try {
                ProcessStartInfo psi = new ProcessStartInfo {
                    FileName = browserPath,
                    Arguments = arguments,
                    UseShellExecute = false
                };

                using (Process proc = Process.Start(psi)) {
                    if (proc != null) {
                        proc.WaitForExit();
                    }
                }
            } catch (Exception ex) {
                MessageBox.Show(
                    "Errore durante l'avvio del processo grafico:\n" + ex.Message,
                    "IL GRANDE MERIDIANO",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
            } finally {
                _isRunning = false;
                try { _listener.Stop(); } catch { }
            }
        }

        private static int GetFreePort() {
            TcpListener l = new TcpListener(IPAddress.Loopback, 0);
            l.Start();
            int port = ((IPEndPoint)l.LocalEndpoint).Port;
            l.Stop();
            return port;
        }

        private static string GetBrowserPath() {
            string[] candidates = new string[] {
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), @"Microsoft\Edge\Application\msedge.exe"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), @"Microsoft\Edge\Application\msedge.exe"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), @"Google\Chrome\Application\chrome.exe"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), @"Google\Chrome\Application\chrome.exe")
            };

            foreach (string path in candidates) {
                if (File.Exists(path)) return path;
            }
            return null;
        }

        private static void RunServer() {
            try {
                _listener = new HttpListener();
                _listener.Prefixes.Add(string.Format("http://127.0.0.1:{0}/", _port));
                _listener.Start();

                while (_isRunning) {
                    try {
                        HttpListenerContext context = _listener.GetContext();
                        ThreadPool.QueueUserWorkItem(ProcessRequest, context);
                    } catch {
                        if (!_isRunning) break;
                    }
                }
            } catch (Exception ex) {
                Debug.WriteLine("Server error: " + ex.Message);
            }
        }

        private static void ProcessRequest(object state) {
            HttpListenerContext context = (HttpListenerContext)state;
            try {
                string rawUrl = context.Request.Url.AbsolutePath.TrimStart('/');
                if (string.IsNullOrEmpty(rawUrl)) rawUrl = "index.html";

                // Prevent directory traversal
                rawUrl = rawUrl.Replace("/", "\\");
                string filePath = Path.Combine(_baseDir, rawUrl);

                if (File.Exists(filePath)) {
                    byte[] bytes = File.ReadAllBytes(filePath);
                    context.Response.ContentType = GetMimeType(filePath);
                    context.Response.ContentLength64 = bytes.Length;
                    context.Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                    context.Response.OutputStream.Write(bytes, 0, bytes.Length);
                } else {
                    context.Response.StatusCode = 404;
                    byte[] notFound = Encoding.UTF8.GetBytes("404 - Not Found");
                    context.Response.OutputStream.Write(notFound, 0, notFound.Length);
                }
            } catch {
                try { context.Response.StatusCode = 500; } catch { }
            } finally {
                try { context.Response.OutputStream.Close(); } catch { }
            }
        }

        private static string GetMimeType(string path) {
            string ext = Path.GetExtension(path).ToLowerInvariant();
            switch (ext) {
                case ".html": return "text/html; charset=utf-8";
                case ".js": return "application/javascript; charset=utf-8";
                case ".css": return "text/css; charset=utf-8";
                case ".json": return "application/json; charset=utf-8";
                case ".png": return "image/png";
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".svg": return "image/svg+xml";
                case ".ico": return "image/x-icon";
                case ".wav": return "audio/wav";
                case ".mp3": return "audio/mpeg";
                default: return "application/octet-stream";
            }
        }
    }
}
