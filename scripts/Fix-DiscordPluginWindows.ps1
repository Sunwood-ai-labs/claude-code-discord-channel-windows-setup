Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$pluginRoots = @(
    (Join-Path $HOME ".claude\plugins\cache\claude-plugins-official\discord\0.0.1"),
    (Join-Path $HOME ".claude\plugins\marketplaces\claude-plugins-official\external_plugins\discord")
) | Where-Object { Test-Path $_ }

if ($pluginRoots.Count -eq 0) {
    throw "Discord plugin files were not found in the expected Claude plugin directories."
}

$bunCommand = "C:\\Users\\Aslan\\.local\\bin\\bun.cmd"
if (-not (Test-Path $bunCommand)) {
    throw "bun.cmd was not found at $bunCommand"
}

foreach ($root in $pluginRoots) {
    $mcpPath = Join-Path $root ".mcp.json"
    if (Test-Path $mcpPath) {
        $mcp = Get-Content -Raw -Path $mcpPath | ConvertFrom-Json
        $mcp.mcpServers.discord.command = $bunCommand
        $mcp | ConvertTo-Json -Depth 10 | Set-Content -Path $mcpPath -Encoding utf8
    }

    $serverPath = Join-Path $root "server.ts"
    if (Test-Path $serverPath) {
        $server = Get-Content -Raw -Path $serverPath
        $server = $server.Replace(
            "const m = line.match(/^(\w+)=(.*)$/)`r`n    if (m && process.env[m[1]] === undefined) process.env[m[1]] = m[2]",
            "const m = line.replace(/\r$/, '').match(/^(\w+)=(.*)$/)`r`n    if (m && (process.env[m[1]] === undefined || process.env[m[1]] === '')) process.env[m[1]] = m[2]"
        )
        $server = $server.Replace(
            "const TOKEN = process.env.DISCORD_BOT_TOKEN",
            "const TOKEN = process.env.DISCORD_BOT_TOKEN?.trim()"
        )
        [System.IO.File]::WriteAllText($serverPath, $server, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "Reapplied Windows Discord plugin fixes."
