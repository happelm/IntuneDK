<#
  Azure Automation runbook (PowerShell 5.1) - daily enrollment report by mail
  Builds the same HTML page as Get-EnrollmentDashboard.ps1 and mails it as attachment.

  Identity:  system-assigned managed identity of the Automation account
  Graph:     DeviceManagementManagedDevices.Read.All, Device.Read.All (application, granted in Entra ID)
  Mail:      "Application Mail.Send" via Exchange Online RBAC for Applications, scoped to the sender mailbox
  Module:    Microsoft.Graph.Authentication (imported into the Automation account)

  Parameters come from the job schedule (ARM template azuredeploy.json).
#>
param(
    [Parameter(Mandatory)] [string] $Sender,      # mailbox the report is sent from, e.g. a shared mailbox
    [Parameter(Mandatory)] [string] $Recipients,  # comma-separated list of addresses
    [int] $Days = 30
)

$ErrorActionPreference = 'Stop'
Connect-MgGraph -Identity -NoWelcome

# GET with paging - follows @odata.nextLink until the last page
function Get-GraphAll ([string] $Uri) {
    $items = @()
    while ($Uri) {
        $page  = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject
        $items += @($page.value)
        $Uri   = $page.'@odata.nextLink'
    }
    $items
}

# ISO string (UTC) for the page, or $null
function ConvertTo-Iso ($Value) {
    if (-not $Value) { return $null }
    $d = [datetime]$Value
    if ($d.Year -le 1) { return $null }
    $d.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

# ISO 8601 duration (PT12M30S) -> minutes, or $null
function ConvertTo-Minutes ($Duration) {
    if (-not $Duration) { return $null }
    try { [math]::Round([System.Xml.XmlConvert]::ToTimeSpan($Duration).TotalMinutes, 1) } catch { $null }
}

# 1. Intune and Entra ID - joined by the Entra device ID
$managed = Get-GraphAll 'https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$select=deviceName,operatingSystem,userPrincipalName,enrolledDateTime,lastSyncDateTime,azureADDeviceId,deviceEnrollmentType,managementAgent'
$entra = @{}
Get-GraphAll 'https://graph.microsoft.com/v1.0/devices?$select=deviceId,registrationDateTime,createdDateTime,trustType' |
    ForEach-Object { $entra[$_.deviceId] = $_ }

$devices = foreach ($m in $managed) {
    $e = if ($m.azureADDeviceId) { $entra[$m.azureADDeviceId] } else { $null }
    [pscustomobject]@{
        name       = $m.deviceName
        os         = $m.operatingSystem
        user       = $m.userPrincipalName
        type       = $m.deviceEnrollmentType
        agent      = $m.managementAgent
        trust      = if ($e) { $e.trustType } else { $null }
        registered = if ($e) { ConvertTo-Iso ($(if ($e.registrationDateTime) { $e.registrationDateTime } else { $e.createdDateTime })) } else { $null }
        enrolled   = ConvertTo-Iso $m.enrolledDateTime
        lastSync   = ConvertTo-Iso $m.lastSyncDateTime
    }
}

# 2. Windows Autopilot events (beta) - empty without Autopilot, the page then hides the section
$autopilot = @()
try {
    $autopilot = @(Get-GraphAll 'https://graph.microsoft.com/beta/deviceManagement/autopilotEvents' | ForEach-Object {
        [pscustomobject]@{
            name          = $_.managedDeviceName
            serial        = $_.deviceSerialNumber
            state         = $_.enrollmentState
            start         = ConvertTo-Iso $_.enrollmentStartDateTime
            deviceSetup   = ConvertTo-Minutes $_.deviceSetupDuration
            accountSetup  = ConvertTo-Minutes $_.accountSetupDuration
            total         = ConvertTo-Minutes $_.totalDuration
        }
    })
} catch { Write-Warning "Autopilot events not available: $($_.Exception.Message)" }

$data = [ordered]@{
    generated = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    days      = $Days
    devices   = @($devices)
    autopilot = $autopilot
}
$json = ConvertTo-Json -InputObject $data -Depth 4 -Compress

# 3. HTML page - Chart.js draws in the browser, times are shown in the local time zone of the browser
$html = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Enrollment Dashboard</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"></script>
<style>
  :root {
    --page: #f9f9f7; --surface: #fcfcfb; --ink: #0b0b0b; --ink2: #52514e; --muted: #898781;
    --grid: #e1e0d9; --border: rgba(11,11,11,0.10);
    --s1: #2a78d6; --s2: #eb6834; --s3: #1baf7a; --s4: #eda100; --s5: #e87ba4; --s6: #6250d6;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --page: #0d0d0d; --surface: #1a1a19; --ink: #f0efec; --ink2: #c3c2b7; --muted: #898781;
      --grid: #2c2c2a; --border: rgba(255,255,255,0.10);
      --s1: #3987e5; --s2: #d95926; --s3: #199e70; --s4: #c98500; --s5: #d55181; --s6: #9085e9;
    }
  }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--page); color: var(--ink);
         font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
  main { max-width: 1200px; margin: 0 auto; padding: 24px 16px 40px; }
  header { display: flex; justify-content: space-between; align-items: baseline; flex-wrap: wrap; gap: 8px; }
  h1 { font-size: 22px; margin: 0; }
  .meta { color: var(--ink2); font-size: 13px; }
  .tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin: 20px 0; }
  .tile, .card { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; }
  .tile { padding: 14px 16px; }
  .tile .label { color: var(--ink2); font-size: 13px; }
  .tile .value { font-size: 30px; font-weight: 600; margin-top: 4px; }
  .tile .sub { color: var(--muted); font-size: 12px; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(440px, 1fr)); gap: 12px; }
  .card { padding: 14px 16px; min-width: 0; }
  .card h2 { font-size: 15px; margin: 0 0 4px; }
  .card p.hint { color: var(--muted); font-size: 12px; margin: 0 0 10px; }
  .chart { position: relative; height: 280px; }
  .wide { grid-column: 1 / -1; }
  .scroll { overflow-x: auto; }
  table { width: 100%; border-collapse: collapse; font-size: 13px; }
  th, td { text-align: left; padding: 6px 8px; border-bottom: 1px solid var(--grid); white-space: nowrap; }
  th { color: var(--ink2); font-weight: 600; }
  td.num { font-variant-numeric: tabular-nums; }
  .empty { color: var(--muted); font-size: 13px; }
</style>
</head>
<body>
<main>
  <header>
    <h1>Enrollment Dashboard</h1>
    <div class="meta" id="meta"></div>
  </header>
  <section class="tiles" id="tiles"></section>
  <section class="grid">
    <div class="card wide">
      <h2>Enrollments per day</h2>
      <p class="hint" id="perDayHint"></p>
      <div class="chart"><canvas id="perDay"></canvas></div>
    </div>
    <div class="card">
      <h2>Enrollment type</h2>
      <p class="hint">deviceEnrollmentType in Intune</p>
      <div class="chart"><canvas id="types"></canvas></div>
    </div>
    <div class="card">
      <h2>Entra registration → Intune enrollment</h2>
      <p class="hint">Minutes between the two timestamps. Negative: enrolled in Intune before the Entra registration (typical for Apple ADE).</p>
      <div class="chart" id="delayBox"><canvas id="delay"></canvas></div>
    </div>
    <div class="card wide">
      <h2>Timeline per device</h2>
      <p class="hint" id="timelineHint"></p>
      <div class="chart" id="timelineBox"><canvas id="timeline"></canvas></div>
    </div>
    <div class="card wide" id="apCard" hidden>
      <h2>Windows Autopilot – enrollment status page</h2>
      <p class="hint">Minutes per phase from the Autopilot events</p>
      <div class="chart"><canvas id="ap"></canvas></div>
    </div>
    <div class="card wide">
      <h2>All devices</h2>
      <div class="scroll" id="list"></div>
    </div>
  </section>
</main>
<script>
const data = __DATA__;
const css = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const pad = n => String(n).padStart(2, '0');
const fmt = t => { if (!t) return ''; const d = new Date(t);
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`; };
const day = d => `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
const series = ['--s1','--s2','--s3','--s4','--s5','--s6'].map(css);

Chart.defaults.font.family = 'system-ui, -apple-system, "Segoe UI", sans-serif';
Chart.defaults.color = css('--ink2');
Chart.defaults.borderColor = css('--grid');
Chart.defaults.plugins.legend.labels.boxWidth = 12;

const now = new Date();
const since = new Date(now); since.setHours(0,0,0,0); since.setDate(since.getDate() - data.days + 1);
const devs = data.devices;
const recent = devs.filter(d => d.enrolled && new Date(d.enrolled) >= since);
const delayMin = d => (d.registered && d.enrolled) ? (new Date(d.enrolled) - new Date(d.registered)) / 60000 : null;

document.getElementById('meta').textContent = `Generated ${data.generated} · ${devs.length} managed devices`;

// Tiles
const last = devs.filter(d => d.enrolled).sort((a, b) => new Date(b.enrolled) - new Date(a.enrolled))[0];
const winDelays = devs.filter(d => d.os === 'Windows').map(delayMin).filter(x => x !== null).sort((a, b) => a - b);
const median = winDelays.length ? winDelays[Math.floor(winDelays.length / 2)] : null;
const tiles = [
  ['Managed devices', devs.length, ''],
  [`Enrolled in the last ${data.days} days`, recent.length, 'devices'],
  ['Last enrollment', last ? (d => `${pad(d.getDate())}.${pad(d.getMonth()+1)}. ${pad(d.getHours())}:${pad(d.getMinutes())}`)(new Date(last.enrolled)) : '–', last ? last.name : ''],
  ['Windows: registration → enrollment', median === null ? '–' : (median < 1 ? `${Math.round(median * 60)} s` : `${median.toFixed(1)} min`), 'median']
];
document.getElementById('tiles').innerHTML = tiles.map(([l, v, s]) =>
  `<div class="tile"><div class="label">${esc(l)}</div><div class="value">${esc(v)}</div><div class="sub">${esc(s)}</div></div>`).join('');

// 1. Enrollments per day, stacked by operating system
const osList = [...new Set(devs.map(d => d.os || 'Unknown'))]
  .sort((a, b) => devs.filter(d => d.os === b).length - devs.filter(d => d.os === a).length);
const dayLabels = [];
const dayKeys = [];
for (let d = new Date(since); d <= now; d.setDate(d.getDate() + 1)) { dayKeys.push(day(d)); dayLabels.push(`${pad(d.getDate())}.${pad(d.getMonth()+1)}.`); }
document.getElementById('perDayHint').textContent = `Last ${data.days} days, by operating system (Intune enrolledDateTime)`;
new Chart(document.getElementById('perDay'), {
  type: 'bar',
  data: { labels: dayLabels,
          datasets: osList.map((os, i) => ({
            label: os,
            data: dayLabels.map((l, j) => recent.filter(d => (d.os || 'Unknown') === os && day(new Date(d.enrolled)) === dayKeys[j]).length),
            backgroundColor: series[i % series.length], borderColor: css('--surface'), borderWidth: 1, borderRadius: 3 })) },
  options: { maintainAspectRatio: false,
             scales: { x: { stacked: true, grid: { display: false } }, y: { stacked: true, beginAtZero: true, ticks: { precision: 0 } } } }
});

// 2. Enrollment type
const types = Object.entries(devs.reduce((a, d) => (a[d.type || 'unknown'] = (a[d.type || 'unknown'] || 0) + 1, a), {}))
  .sort((a, b) => b[1] - a[1]);
const topTypes = types.slice(0, 5); const rest = types.slice(5).reduce((s, x) => s + x[1], 0);
if (rest) topTypes.push(['other', rest]);
new Chart(document.getElementById('types'), {
  type: 'doughnut',
  data: { labels: topTypes.map(([t, c]) => `${t} (${c})`),
          datasets: [{ data: topTypes.map(x => x[1]), backgroundColor: topTypes.map((x, i) => series[i % series.length]),
                       borderColor: css('--surface'), borderWidth: 2 }] },
  options: { maintainAspectRatio: false, cutout: '60%', plugins: { legend: { position: 'right' } } }
});

// 3. Delay Entra registration -> Intune enrollment
const delays = devs.map(d => ({ name: d.name, v: delayMin(d) })).filter(x => x.v !== null)
  .sort((a, b) => Math.abs(b.v) - Math.abs(a.v)).slice(0, 15);
document.getElementById('delayBox').style.height = Math.max(200, delays.length * 26 + 50) + 'px';
new Chart(document.getElementById('delay'), {
  type: 'bar',
  data: { labels: delays.map(x => x.name),
          datasets: [{ label: 'Minutes', data: delays.map(x => +x.v.toFixed(2)),
                       backgroundColor: delays.map(x => x.v < 0 ? series[1] : series[0]), borderRadius: 3, maxBarThickness: 18 }] },
  options: { maintainAspectRatio: false, indexAxis: 'y', plugins: { legend: { display: false },
             tooltip: { callbacks: { label: c => { const v = c.raw; const a = Math.abs(v);
               return `${v < 0 ? '−' : ''}${a < 1 ? Math.round(a * 60) + ' s' : a.toFixed(1) + ' min'}`; } } } },
             scales: { x: { title: { display: true, text: 'minutes' } }, y: { grid: { display: false } } } }
});

// 4. Timeline per device: Entra registration -> enrollment -> last check-in
const tl = recent.slice().sort((a, b) => new Date(a.enrolled) - new Date(b.enrolled));
document.getElementById('timelineHint').textContent =
  `Devices enrolled in the last ${data.days} days. Orange: Entra registration to Intune enrollment, blue: enrolled to last check-in.`;
document.getElementById('timelineBox').style.height = Math.max(200, tl.length * 24 + 60) + 'px';
const ms = t => t ? new Date(t).getTime() : null;
new Chart(document.getElementById('timeline'), {
  type: 'bar',
  data: { labels: tl.map(d => d.name),
          datasets: [
            { label: 'Entra registration → enrollment', data: tl.map(d => d.registered ? [Math.min(ms(d.registered), ms(d.enrolled)), Math.max(ms(d.registered), ms(d.enrolled))] : null),
              backgroundColor: series[1], borderRadius: 3, minBarLength: 4, grouped: false, barPercentage: 0.9 },
            { label: 'Enrolled → last check-in', data: tl.map(d => [ms(d.enrolled), ms(d.lastSync) || ms(d.enrolled)]),
              backgroundColor: series[0] + '99', borderRadius: 3, minBarLength: 4, grouped: false, barPercentage: 0.5 } ] },
  options: { maintainAspectRatio: false, indexAxis: 'y',
             plugins: { tooltip: { callbacks: { label: c => {
               const d = tl[c.dataIndex];
               return c.datasetIndex === 0 ? `Entra registered ${fmt(d.registered)} · enrolled ${fmt(d.enrolled)}`
                                           : `Enrolled ${fmt(d.enrolled)} · last check-in ${fmt(d.lastSync)}`; } } } },
             scales: { x: { type: 'linear', min: since.getTime(), max: now.getTime(),
                            ticks: { callback: v => { const d = new Date(v); return `${pad(d.getDate())}.${pad(d.getMonth()+1)}.`; }, maxTicksLimit: 12 } },
                       y: { grid: { display: false } } } }
});

// 5. Autopilot phases (only if there are events)
if (data.autopilot.length) {
  document.getElementById('apCard').hidden = false;
  const ap = data.autopilot.slice(0, 20);
  new Chart(document.getElementById('ap'), {
    type: 'bar',
    data: { labels: ap.map(a => a.name || a.serial),
            datasets: [ { label: 'Device setup', data: ap.map(a => a.deviceSetup), backgroundColor: series[0], borderRadius: 3 },
                        { label: 'Account setup', data: ap.map(a => a.accountSetup), backgroundColor: series[2], borderRadius: 3 } ] },
    options: { maintainAspectRatio: false, indexAxis: 'y',
               scales: { x: { stacked: true, title: { display: true, text: 'minutes' } }, y: { stacked: true, grid: { display: false } } } }
  });
}

// 6. Table
const rows = devs.slice().sort((a, b) => new Date(b.enrolled || 0) - new Date(a.enrolled || 0));
const dl = d => { const v = delayMin(d); if (v === null) return ''; const a = Math.abs(v);
  return `${v < 0 ? '−' : ''}${a < 1 ? Math.round(a * 60) + ' s' : a < 120 ? a.toFixed(1) + ' min' : (a / 1440).toFixed(1) + ' d'}`; };
document.getElementById('list').innerHTML =
  '<table><thead><tr><th>Device</th><th>OS</th><th>Enrollment type</th><th>Entra join</th><th>Entra registered</th><th>Intune enrolled</th><th>Delay</th><th>Last check-in</th></tr></thead><tbody>' +
  rows.map(d => `<tr><td>${esc(d.name)}</td><td>${esc(d.os)}</td><td>${esc(d.type)}</td><td>${esc(d.trust)}</td>` +
    `<td class="num">${fmt(d.registered)}</td><td class="num">${fmt(d.enrolled)}</td><td class="num">${dl(d)}</td><td class="num">${fmt(d.lastSync)}</td></tr>`).join('') +
  '</tbody></table>';
</script>
</body>
</html>
'@


# 4. Mail with the page as attachment
$file  = Join-Path $env:TEMP ("EnrollmentReport-{0:yyyy-MM-dd}.html" -f (Get-Date))
$html.Replace('__DATA__', $json) | Out-File -FilePath $file -Encoding utf8
$bytes = [System.IO.File]::ReadAllBytes($file)

$recent  = @($devices | Where-Object { $_.enrolled -and ([datetime]$_.enrolled) -ge (Get-Date).Date.AddDays(1 - $Days) }).Count
$summary = "<p>Enrollment report from {0:yyyy-MM-dd HH:mm}: {1} managed devices, {2} enrolled in the last {3} days.</p><p>Open the attachment in a browser for the charts.</p>" -f (Get-Date), @($devices).Count, $recent, $Days

$message = @{
    message = @{
        subject      = "Intune enrollment report {0:yyyy-MM-dd}" -f (Get-Date)
        body         = @{ contentType = 'HTML'; content = $summary }
        toRecipients = @($Recipients -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ } |
                         ForEach-Object { @{ emailAddress = @{ address = $_ } } })
        attachments  = @(@{
            '@odata.type' = '#microsoft.graph.fileAttachment'
            name          = Split-Path $file -Leaf
            contentType   = 'text/html'
            contentBytes  = [Convert]::ToBase64String($bytes)
        })
    }
    saveToSentItems = $true
}
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users/$Sender/sendMail" `
    -Body (ConvertTo-Json -InputObject $message -Depth 10) -ContentType 'application/json'
Write-Output "Report with $(@($devices).Count) devices sent to $Recipients"
