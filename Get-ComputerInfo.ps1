# =============================================
# HERRAMIENTA DE INVENTARIO DE PC - VERSION CORREGIDA
# =============================================

Clear-Host

Write-Host ""
Write-Host "  +++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
Write-Host "       HERRAMIENTA DE INVENTARIO DE HARDWARE      " -ForegroundColor Cyan
Write-Host "  +++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Herramienta para inventariar equipos de computo" -ForegroundColor Gray
Write-Host "  Version 2.0 - Deteccion multiple de monitores" -ForegroundColor Gray
Write-Host ""

Write-Host "  ------------------------------------------------" -ForegroundColor Yellow
Write-Host "          INGRESE LA INFORMACION DEL USUARIO      " -ForegroundColor Yellow
Write-Host "  ------------------------------------------------" -ForegroundColor Yellow
Write-Host ""
$nombreUsuario = Read-Host "  Nombre del usuario/dueño del equipo"
Write-Host ""

$fecha = Get-Date -Format "yyyyMMdd_HHmm"
$nombreArchivo = "Inventario_$($nombreUsuario.Replace(' ', '_'))_$fecha.txt"
$rutaCompleta = Join-Path -Path (Get-Location) -ChildPath $nombreArchivo

Write-Host ""
Write-Host "  [*] Iniciando escaneo del sistema..." -ForegroundColor Gray
Write-Host "  [" -NoNewline -ForegroundColor Cyan
for ($i = 1; $i -le 40; $i++) {
    Write-Host "=" -NoNewline -ForegroundColor Green
    Start-Sleep -Milliseconds 30
}
Write-Host "] 100%" -ForegroundColor Cyan
Write-Host ""

# =============================================
# FUNCION SIMPLIFICADA PARA MONITORES
# =============================================

function Get-MonitoresInfo {
    try {
        $monitoresWMI = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ErrorAction SilentlyContinue
        $infoMonitores = @()
        
        if ($monitoresWMI) {
            $contador = 1
            foreach ($monitor in $monitoresWMI) {
                $marcaBytes = $monitor.ManufacturerName | Where-Object { $_ -ne 0 }
                $modeloBytes = $monitor.ProductCodeID | Where-Object { $_ -ne 0 }
                
                $marca = "Desconocida"
                if ($marcaBytes) { 
                    $marca = [System.Text.Encoding]::ASCII.GetString($marcaBytes).Trim()
                }
                
                $modelo = "Desconocido"
                if ($modeloBytes) { 
                    $modelo = [System.Text.Encoding]::ASCII.GetString($modeloBytes).Trim()
                }
                
                # CORREGIDO: Usar ${contador} para evitar problemas con el :
                $infoMonitores += "Monitor ${contador}: $marca $modelo"
                $contador++
            }
        }
        
        return $infoMonitores
    } catch {
        return @()
    }
}

# =============================================
# RECOLECCION DE INFORMACION
# =============================================

Write-Host "  [*] Obteniendo informacion del sistema..." -ForegroundColor Gray

# Informacion basica
$sistema = Get-WmiObject Win32_ComputerSystem
$cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
$os = Get-WmiObject Win32_OperatingSystem
$bios = Get-WmiObject Win32_BIOS
$placaBase = Get-WmiObject Win32_BaseBoard

Write-Host "  [*] Analizando almacenamiento..." -ForegroundColor Gray
$discos = Get-WmiObject Win32_DiskDrive
$infoDiscos = @()
foreach ($disco in $discos) {
    $capacidadGB = [math]::Round($disco.Size / 1GB, 2)
    $tipo = "HDD"
    if ($disco.Model -like "*SSD*" -or $disco.MediaType -like "*SSD*") { 
        $tipo = "SSD"
    }
    $infoDiscos += "$($disco.Model) - $capacidadGB GB ($tipo)"
}

Write-Host "  [*] Revisando memoria RAM..." -ForegroundColor Gray
$ramTotal = [math]::Round($sistema.TotalPhysicalMemory / 1GB, 2)

Write-Host "  [*] Detectando componentes graficos..." -ForegroundColor Gray
$graficas = Get-WmiObject Win32_VideoController | Where-Object { 
    $_.Name -notlike "*Microsoft*" -and $_.Name -notlike "*Basic Display*"
}
$infoGraficas = @()
if ($graficas) {
    foreach ($grafica in $graficas) {
        $infoGraficas += $grafica.Name
    }
}

Write-Host "  [*] Escaneando monitores..." -ForegroundColor Gray
$monitoresInfo = Get-MonitoresInfo

Write-Host "  [*] Revisando red..." -ForegroundColor Gray
$adaptadorRed = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1

# Determinar tipo de equipo
$marca = $sistema.Manufacturer
$tipoEquipo = "EQUIPO ENSAMBLADO"
if ($marca -notlike "*SYSTEM*" -and $marca -notlike "*To be filled*" -and $marca -ne "") {
    $tipoEquipo = "EQUIPO DE MARCA - $marca"
}

Write-Host ""
Write-Host "  [*] Finalizando escaneo..." -ForegroundColor Gray
Write-Host "  [" -NoNewline -ForegroundColor Cyan
for ($i = 1; $i -le 40; $i++) {
    Write-Host "=" -NoNewline -ForegroundColor Green
    Start-Sleep -Milliseconds 20
}
Write-Host "] 100%" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [OK] Escaneo completado exitosamente!" -ForegroundColor Green
Write-Host ""

# =============================================
# GENERAR REPORTE DE FORMA SIMPLE
# =============================================

# Crear el contenido del reporte directamente
$contenidoReporte = @"
////////////////////////////////////////////////////////////////////////////////
                    INVENTARIO DE HARDWARE - REPORTE
////////////////////////////////////////////////////////////////////////////////

FECHA:          $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
USUARIO:        $nombreUsuario
TECNICO:        $env:USERNAME
EQUIPO:         $env:COMPUTERNAME

////////////////////////////////////////////////////////////////////////////////
                    INFORMACION DEL SISTEMA
////////////////////////////////////////////////////////////////////////////////

TIPO:           $tipoEquipo
MARCA:          $($sistema.Manufacturer)
MODELO:         $($sistema.Model)
SERIE:          $($bios.SerialNumber)
SISTEMA OP:     $($os.Caption)
ARQUITECTURA:   $($os.OSArchitecture)

////////////////////////////////////////////////////////////////////////////////
                    PROCESADOR (CPU)
////////////////////////////////////////////////////////////////////////////////

MODELO:         $($cpu.Name)
NUCLEOS FISICOS:$($cpu.NumberOfCores)
NUCLEOS LOGICOS:$($cpu.NumberOfLogicalProcessors)
VELOCIDAD:      $($cpu.MaxClockSpeed) MHz
SOCKET:         $($cpu.SocketDesignation)

////////////////////////////////////////////////////////////////////////////////
                    MEMORIA RAM
////////////////////////////////////////////////////////////////////////////////

TOTAL RAM:      $ramTotal GB

////////////////////////////////////////////////////////////////////////////////
                    ALMACENAMIENTO
////////////////////////////////////////////////////////////////////////////////

UNIDADES:       $($discos.Count)
"@

# Agregar informacion de discos
if ($infoDiscos.Count -gt 0) {
    foreach ($discoInfo in $infoDiscos) {
        $contenidoReporte += "`r`n$discoInfo"
    }
} else {
    $contenidoReporte += "`r`nNo se detectaron discos"
}

$contenidoReporte += @"

////////////////////////////////////////////////////////////////////////////////
                    TARJETAS GRAFICAS
////////////////////////////////////////////////////////////////////////////////
"@

# Agregar informacion de graficas
if ($infoGraficas.Count -gt 0) {
    foreach ($graficaInfo in $infoGraficas) {
        $contenidoReporte += "`r`n$graficaInfo"
    }
} else {
    $contenidoReporte += "`r`nGraficos integrados"
}

$contenidoReporte += @"

////////////////////////////////////////////////////////////////////////////////
                    MONITORES
////////////////////////////////////////////////////////////////////////////////
"@

# Agregar informacion de monitores
if ($monitoresInfo.Count -gt 0) {
    foreach ($monitorInfo in $monitoresInfo) {
        $contenidoReporte += "`r`n$monitorInfo"
    }
} else {
    $contenidoReporte += "`r`nNo se detectaron monitores"
}

# Agregar informacion adicional
$contenidoReporte += @"

////////////////////////////////////////////////////////////////////////////////
                    INFORMACION ADICIONAL
////////////////////////////////////////////////////////////////////////////////

PLACA BASE:
  Fabricante: $(try { $placaBase.Manufacturer } catch { "No disponible" })
  Modelo:     $(try { $placaBase.Product } catch { "No disponible" })
  Serie:      $(try { $placaBase.SerialNumber } catch { "No disponible" })

BIOS:
  Version:    $($bios.Version)
  Fabricante: $($bios.Manufacturer)

RED:
  Adaptador:  $(if ($adaptadorRed) { $adaptadorRed.Description } else { "No disponible" })
  IP:         $(if ($adaptadorRed -and $adaptadorRed.IPAddress -and $adaptadorRed.IPAddress[0]) { $adaptadorRed.IPAddress[0] } else { "No disponible" })
  MAC:        $(if ($adaptadorRed) { $adaptadorRed.MACAddress } else { "No disponible" })

////////////////////////////////////////////////////////////////////////////////
                    FIN DEL REPORTE
////////////////////////////////////////////////////////////////////////////////
Reporte generado automaticamente por Herramienta de Inventario de Hardware
$(Get-Date -Format 'dd/MM/yyyy')
"@

# =============================================
# GUARDAR REPORTE
# =============================================

Write-Host ""
Write-Host "  ------------------------------------------------" -ForegroundColor Cyan
Write-Host "          GENERANDO REPORTE FINAL                " -ForegroundColor Cyan
Write-Host "  ------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Guardar en formato ANSI
try {
    $ansiEncoding = [System.Text.Encoding]::Default
    $bytes = $ansiEncoding.GetBytes($contenidoReporte)
    [System.IO.File]::WriteAllBytes($rutaCompleta, $bytes)
    $guardadoExitoso = $true
} catch {
    $guardadoExitoso = $false
    $errorMsg = $_.Exception.Message
}

# =============================================
# MOSTRAR RESUMEN
# =============================================

Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "          RESUMEN DEL INVENTARIO                  " -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  USUARIO:     $nombreUsuario" -ForegroundColor Yellow
Write-Host "  EQUIPO:      $tipoEquipo" -ForegroundColor Yellow
Write-Host "  PROCESADOR:  $($cpu.Name)" -ForegroundColor Yellow
Write-Host "  RAM:         $ramTotal GB" -ForegroundColor Yellow
Write-Host "  DISCOS:      $($discos.Count) unidades" -ForegroundColor Yellow
Write-Host "  GRAFICOS:    $($graficas.Count) dispositivos" -ForegroundColor Yellow
Write-Host "  MONITORES:   $($monitoresInfo.Count) detectados" -ForegroundColor Yellow
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "          ARCHIVO GENERADO EXITOSAMENTE          " -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""

if ($guardadoExitoso) {
    Write-Host "  ARCHIVO:  $nombreArchivo" -ForegroundColor White
    Write-Host "  RUTA:     $(Get-Location)" -ForegroundColor White
    Write-Host "  TAMANO:   $($bytes.Length) bytes" -ForegroundColor White
    Write-Host "  FORMATO:  ANSI (Windows-1252)" -ForegroundColor White
} else {
    Write-Host "  ERROR: No se pudo guardar el archivo" -ForegroundColor Red
    Write-Host "  $errorMsg" -ForegroundColor Red
}

# Mostrar vista previa
Write-Host ""
Write-Host "  ------------------------------------------------" -ForegroundColor Cyan
Write-Host "          VISTA PREVIA DEL REPORTE              " -ForegroundColor Cyan
Write-Host "  ------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Mostrar primeras lineas
$lineas = $contenidoReporte -split "`r`n"
$contador = 0
foreach ($linea in $lineas) {
    if ($contador -lt 10) {
        Write-Host "  $linea" -ForegroundColor Gray
        $contador++
    } else {
        break
    }
}

Write-Host ""
Write-Host "  [!] El reporte completo se guardo en el archivo mencionado" -ForegroundColor Yellow

Write-Host ""
Write-Host "  ------------------------------------------------" -ForegroundColor DarkCyan
Write-Host "          PRESIONE CUALQUIER TECLA PARA SALIR    " -ForegroundColor DarkCyan
Write-Host "  ------------------------------------------------" -ForegroundColor DarkCyan
Write-Host ""

# Esperar tecla
$Host.UI.RawUI.FlushInputBuffer()
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Mensaje final
Clear-Host
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "        INVENTARIO COMPLETADO EXITOSAMENTE        " -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Gracias por usar la herramienta de inventario." -ForegroundColor Gray
Write-Host ""
Write-Host "  El archivo esta listo para su revision" -ForegroundColor Yellow
Write-Host "  Puede abrirlo con el Bloc de notas" -ForegroundColor Yellow
Write-Host "  Nombre del archivo: $nombreArchivo" -ForegroundColor Cyan
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Cerrando programa..." -ForegroundColor DarkGray
Start-Sleep -Seconds 2
