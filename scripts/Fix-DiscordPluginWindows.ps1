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
        [System.IO.File]::WriteAllText(
            $mcpPath,
            ($mcp | ConvertTo-Json -Depth 10),
            [System.Text.UTF8Encoding]::new($false)
        )
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
        $server = $server.Replace(
            @'
async function fetchTextChannel(id: string) {
  const ch = await client.channels.fetch(id)
  if (!ch || !ch.isTextBased()) {
    throw new Error(`channel ${id} not found or not text-based`)
  }
  return ch
}
'@,
            @'
async function fetchTextChannel(id: string) {
  const ch = await client.channels.fetch(id)
  if (!ch || !ch.isTextBased()) {
    throw new Error(`channel ${id} not found or not text-based`)
  }
  return ch
}

async function resolveAllowedDmChannel(ch: Awaited<ReturnType<typeof fetchTextChannel>>, allowFrom: string[]) {
  if (ch.type !== ChannelType.DM) return null
  if (typeof ch.recipientId === 'string' && ch.recipientId.length > 0) return ch

  const cached = client.channels.cache.get(ch.id)
  if (cached?.type === ChannelType.DM && typeof cached.recipientId === 'string' && cached.recipientId.length > 0) {
    return cached
  }

  for (const userId of allowFrom) {
    try {
      const dm = await client.users.createDM(userId, { force: false })
      if (dm.id === ch.id) return dm
    } catch {}
  }

  return null
}
'@
        )
        $server = $server.Replace(
            "  if (ch.type === ChannelType.DM) {`r`n    if (access.allowFrom.includes(ch.recipientId)) return ch",
            "  if (ch.type === ChannelType.DM) {`r`n    const allowedDm = await resolveAllowedDmChannel(ch, access.allowFrom)`r`n    if (allowedDm) return allowedDm"
        )
        [System.IO.File]::WriteAllText($serverPath, $server, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "Reapplied Windows Discord plugin fixes."
