# TcpListener based web server (No Windows HTTP.sys / admin required)
$port = 8080
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$listener.Start()
Write-Host "TCP Server listening on http://localhost:$port/"

$root = $PSScriptRoot

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
}

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)
        $line = $reader.ReadLine()

        if (-not [string]::IsNullOrEmpty($line)) {
            $parts = $line.Split(' ')
            $path = $parts[1].TrimStart('/')
            if ([string]::IsNullOrEmpty($path) -or $path -eq "") {
                $path = "index.html"
            }
            # Remove query string if any
            if ($path.Contains('?')) {
                $path = $path.Substring(0, $path.IndexOf('?'))
            }

            $filePath = Join-Path $root $path

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
                $bytes = [System.IO.File]::ReadAllBytes($filePath)

                $header = "HTTP/1.1 200 OK`r`nContent-Type: $mime`r`nContent-Length: $($bytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nConnection: close`r`n`r`n"
                $hBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
                $stream.Write($hBytes, 0, $hBytes.Length)
                $stream.Write($bytes, 0, $bytes.Length)
            } else {
                $body = "404 Not Found: $path"
                $bBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
                $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain`r`nContent-Length: $($bBytes.Length)`r`nConnection: close`r`n`r`n"
                $hBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
                $stream.Write($hBytes, 0, $hBytes.Length)
                $stream.Write($bBytes, 0, $bBytes.Length)
            }
        }
        $client.Close()
    }
} finally {
    $listener.Stop()
}
