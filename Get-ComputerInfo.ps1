# Script para obtener información completa del equipo con detección de múltiples monitores
# Guardar como Get-PCInfo-Completo.ps1

# Configuración inicial
Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   SISTEMA DE INVENTARIO DE EQUIPOS     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar nombre del usuario/dueño del equipo
$nombreUsuario = Read-Host "Ingrese el nombre del usuario/dueño del equipo"

# Crear archivo de salida
$fecha = Get-Date -Format "yyyyMMdd_HHmm"
$nombreArchivo = "Equipo_$($nombreUsuario.Replace(' ', '_'))_$fecha.txt"
$rutaCompleta = Join-Path -Path (Get-Location) -ChildPath $nombreArchivo

Write-Host ""
Write-Host "Recolectando información del equipo..." -ForegroundColor Green
Write-Host ""

# =============================================
# FUNCIÓN: Obtener TODOS los monitores conectados
# =============================================
function Get-TodosMonitores {
    $monitoresInfo = @()
    
    try {
        # Método 1: Usando Win32_PnPEntity (más confiable)
        $monitoresPNP = Get-WmiObject Win32_PnPEntity | Where-Object { 
            $_.PNPClass -eq 'Monitor' -or $_.Name -like '*monitor*' -or $_.Name -like '*pantalla*'
        }
        
        if ($monitoresPNP) {
            foreach ($monitor in $monitoresPNP) {
                $monitoresInfo += [PSCustomObject]@{
                    Metodo      = "PNP Entity"
                    Nombre      = $monitor.Name
                    ID          = $monitor.DeviceID
                    Estado      = $monitor.Status
                    Descripcion = $monitor.Description
                }
            }
        }
        
        # Método 2: Usando WmiMonitorID para información de fabricante
        $monitoresWMI = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ErrorAction SilentlyContinue
        
        if ($monitoresWMI) {
            $contador = 1
            foreach ($monitor in $monitoresWMI) {
                # Convertir bytes a string legible
                $marcaBytes = $monitor.ManufacturerName | Where-Object { $_ -ne 0 }
                $modeloBytes = $monitor.ProductCodeID | Where-Object { $_ -ne 0 }
                $serialBytes = $monitor.SerialNumberID | Where-Object { $_ -ne 0 }
                
                $marca = if ($marcaBytes) { [System.Text.Encoding]::ASCII.GetString($marcaBytes) } else { "Desconocida" }
                $modelo = if ($modeloBytes) { [System.Text.Encoding]::ASCII.GetString($modeloBytes) } else { "Desconocido" }
                $serial = if ($serialBytes) { [System.Text.Encoding]::ASCII.GetString($serialBytes) } else { "No disponible" }
                
                $monitoresInfo += [PSCustomObject]@{
                    Metodo      = "WMI Monitor ID"
                    Numero      = $contador
                    Marca       = $marca.Trim()
                    Modelo      = $modelo.Trim()
                    Serial      = $serial.Trim()
                    Fabricante  = switch ($marca.ToUpper()) {
                        { $_ -like "*DELL*" } { "Dell" }
                        { $_ -like "*LENOVO*" } { "Lenovo" }
                        { $_ -like "*HP*" } { "HP" }
                        { $_ -like "*ACER*" } { "Acer" }
                        { $_ -like "*ASUS*" } { "Asus" }
                        { $_ -like "*SAMSUNG*" } { "Samsung" }
                        { $_ -like "*LG*" } { "LG" }
                        { $_ -like "*BENQ*" } { "BenQ" }
                        { $_ -like "*VIEWSONIC*" } { "ViewSonic" }
                        default { "Desconocido" }
                    }
                }
                $contador++
            }
        }
        
        # Método 3: Información de configuración de pantalla actual
        Add-Type -AssemblyName System.Windows.Forms
        $pantallas = [System.Windows.Forms.Screen]::AllScreens
        
        if ($pantallas) {
            $contador = 1
            foreach ($pantalla in $pantallas) {
                $monitoresInfo += [PSCustomObject]@{
                    Metodo      = "Pantalla Activa"
                    Numero      = $contador
                    Primaria    = if ($pantalla.Primary) { "SI" } else { "NO" }
                    Resolucion  = "$($pantalla.Bounds.Width)x$($pantalla.Bounds.Height)"
                    AreaTrabajo = "$($pantalla.WorkingArea.Width)x$($pantalla.WorkingArea.Height)"
                    BitsPixel   = $pantalla.BitsPerPixel
                }
                $contador++
            }
        }
        
    } catch {
        $monitoresInfo += [PSCustomObject]@{
            Metodo = "Error"
            Error  = "No se pudo obtener información de monitores: $_"
        }
    }
    
    return $monitoresInfo
}

# =============================================
# FUNCIÓN: Determinar tipo de equipo
# =============================================
function Get-TipoEquipo {
    $marca = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    $modelo = (Get-WmiObject Win32_ComputerSystem).Model
    
    $marcasConocidas = @("Dell", "HP", "Hewlett-Packard", "Lenovo", "Acer", "Asus", "Toshiba", "Sony", "MSI", "Microsoft", "Apple", "Samsung", "LG")
    
    foreach ($marcaConocida in $marcasConocidas) {
        if ($marca -like "*$marcaConocida*") {
            return "De Marca - $marca"
        }
    }
    
    if ($marca -eq "" -or $marca -like "*SYSTEM*" -or $marca -like "*To be filled*" -or $marca -eq "System manufacturer") {
        return "Ensamblado"
    }
    
    return "Ensamblado (Marca: $marca)"
}

# =============================================
# FUNCIÓN: Obtener información de discos
# =============================================
function Get-InfoDiscos {
    $discos = Get-WmiObject Win32_DiskDrive
    $infoDiscos = @()
    
    foreach ($disco in $discos) {
        $tipo = if ($disco.MediaType -like "*SSD*" -or $disco.Model -like "*SSD*" -or $disco.Model -like "*Solid State*") {
            "SSD"
        } elseif ($disco.MediaType -like "*HDD*" -or $disco.Model -like "*HDD*" -or $disco.Model -like "*Hard Disk*") {
            "HDD Mecánico"
        } else {
            "Tipo desconocido"
        }
        
        $capacidadGB = [math]::Round($disco.Size / 1GB, 2)
        
        $infoDiscos += [PSCustomObject]@{
            Numero      = $disco.Index + 1
            Modelo      = $disco.Model.Trim()
            Tipo        = $tipo
            CapacidadGB = $capacidadGB
            Serial      = $disco.SerialNumber
            Particiones = $disco.Partitions
            Interface   = $disco.InterfaceType
        }
    }
    
    return $infoDiscos
}

# =============================================
# FUNCIÓN: Obtener información de RAM
# =============================================
function Get-InfoRAM {
    $modulos = Get-WmiObject Win32_PhysicalMemory
    $infoRAM = @()
    $totalGB = 0
    
    if ($modulos) {
        foreach ($modulo in $modulos) {
            $capacidadGB = [math]::Round($modulo.Capacity / 1GB, 2)
            $totalGB += $capacidadGB
            
            $tipoRAM = switch ($modulo.SMBIOSMemoryType) {
                20 { "DDR" }
                21 { "DDR2" }
                24 { "DDR3" }
                26 { "DDR4" }
                34 { "DDR5" }
                default { "Desconocido (Tipo $($modulo.SMBIOSMemoryType))" }
            }
            
            $fabricante = switch ($modulo.Manufacturer) {
                { $_ -like "*Samsung*" } { "Samsung" }
                { $_ -like "*Kingston*" } { "Kingston" }
                { $_ -like "*Corsair*" } { "Corsair" }
                { $_ -like "*Crucial*" } { "Crucial" }
                { $_ -like "*G.Skill*" } { "G.Skill" }
                { $_ -like "*ADATA*" } { "ADATA" }
                { $_ -like "*Micron*" } { "Micron" }
                { $_ -like "*SK Hynix*" } { "SK Hynix" }
                default { $modulo.Manufacturer }
            }
            
            $infoRAM += [PSCustomObject]@{
                Slot        = $modulo.DeviceLocator
                Capacidad   = "$capacidadGB GB"
                Tipo        = $tipoRAM
                Velocidad   = "$($modulo.Speed) MHz"
                Fabricante  = $fabricante
                Serial      = $modulo.SerialNumber
            }
        }
    }
    
    return @{
        Modulos = $infoRAM
        TotalGB = $totalGB
        Cantidad = $modulos.Count
    }
}

# =============================================
# FUNCIÓN: Obtener información de tarjetas gráficas
# =============================================
function Get-InfoGraficas {
    $graficas = Get-WmiObject Win32_VideoController
    $infoGraficas = @()
    
    foreach ($grafica in $graficas) {
        # Ignorar dispositivos Microsoft básicos
        if ($grafica.Name -like "*Microsoft*" -or $grafica.Name -like "*Basic Display*") {
            continue
        }
        
        $memoriaMB = if ($grafica.AdapterRAM -gt 0) {
            [math]::Round($grafica.AdapterRAM / 1MB, 2)
        } else {
            "Desconocida"
        }
        
        $tipo = if ($grafica.Name -like "*Intel*") { "Integrada" } 
               elseif ($grafica.Name -like "*NVIDIA*") { "Dedicada NVIDIA" } 
               elseif ($grafica.Name -like "*AMD*" -or $grafica.Name -like "*ATI*") { "Dedicada AMD" } 
               else { "Desconocido" }
        
        $infoGraficas += [PSCustomObject]@{
            Nombre      = $grafica.Name
            Tipo        = $tipo
            Memoria     = if ($memoriaMB -eq "Desconocida") { $memoriaMB } else { "$memoriaMB MB" }
            Resolucion  = "$($grafica.CurrentHorizontalResolution)x$($grafica.CurrentVerticalResolution)"
            Driver      = $grafica.DriverVersion
            Refresco    = if ($grafica.CurrentRefreshRate -gt 0) { "$($grafica.CurrentRefreshRate) Hz" } else { "N/A" }
        }
    }
    
    return $infoGraficas
}

# =============================================
# RECOLECTAR TODA LA INFORMACIÓN
# =============================================

Write-Host "  - Obteniendo información del sistema..." -ForegroundColor Gray
$tipoEquipo = Get-TipoEquipo
$sistema = Get-WmiObject Win32_ComputerSystem
$procesador = Get-WmiObject Win32_Processor | Select-Object -First 1
$bios = Get-WmiObject Win32_BIOS
$os = Get-WmiObject Win32_OperatingSystem

Write-Host "  - Analizando almacenamiento..." -ForegroundColor Gray
$discosInfo = Get-InfoDiscos

Write-Host "  - Revisando memoria RAM..." -ForegroundColor Gray
$ramInfo = Get-InfoRAM

Write-Host "  - Detectando tarjetas gráficas..." -ForegroundColor Gray
$graficasInfo = Get-InfoGraficas

Write-Host "  - Escaneando monitores conectados..." -ForegroundColor Gray
$monitoresInfo = Get-TodosMonitores

Write-Host "  - Revisando información de red..." -ForegroundColor Gray
$adaptadoresRed = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# =============================================
# GENERAR REPORTE
# =============================================

$reporte = @"
===============================================================================
                         INVENTARIO DE EQUIPO - REPORTE COMPLETO
===============================================================================
Fecha de generación: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Usuario/Responsable: $nombreUsuario
Técnico/Revisor:     $env:USERNAME
Equipo revisado:     $env:COMPUTERNAME

===============================================================================
                               INFORMACIÓN GENERAL
===============================================================================
Tipo de Equipo:      $tipoEquipo
Marca del Sistema:   $($sistema.Manufacturer)
Modelo del Sistema:  $($sistema.Model)
Número de Serie:     $($bios.SerialNumber)
Sistema Operativo:   $($os.Caption) ($($os.OSArchitecture))
Versión del SO:      $($os.Version)
Directorio Windows:  $($os.WindowsDirectory)
Usuario logueado:    $($sistema.UserName)

===============================================================================
                                 PROCESADOR (CPU)
===============================================================================
Fabricante:          $($procesador.Manufacturer)
Modelo:              $($procesador.Name)
Núcleos Físicos:     $($procesador.NumberOfCores)
Núcleos Lógicos:     $($procesador.NumberOfLogicalProcessors)
Velocidad Base:      $($procesador.MaxClockSpeed) MHz
Socket:              $($procesador.SocketDesignation)

===============================================================================
                               MEMORIA RAM (Total: $($ramInfo.TotalGB) GB)
===============================================================================
Total de RAM:        $($ramInfo.TotalGB) GB
Módulos instalados:  $($ramInfo.Cantidad)

$(if ($ramInfo.Modulos.Count -gt 0) {
    $ramText = ""
    foreach ($modulo in $ramInfo.Modulos) {
        $ramText += "Módulo en $($modulo.Slot):`n"
        $ramText += "  • Capacidad: $($modulo.Capacidad)`n"
        $ramText += "  • Tipo: $($modulo.Tipo)`n"
        $ramText += "  • Velocidad: $($modulo.Velocidad)`n"
        $ramText += "  • Fabricante: $($modulo.Fabricante)`n"
        $ramText += "  • Serial: $($modulo.Serial)`n"
        $ramText += "`n"
    }
    $ramText
} else {
    "No se detectaron módulos de RAM específicos"
})

===============================================================================
                         ALMACENAMIENTO (Discos Duros/SSD)
===============================================================================
Cantidad de discos:  $($discosInfo.Count)

$(if ($discosInfo.Count -gt 0) {
    $discosText = ""
    foreach ($disco in $discosInfo) {
        $discosText += "Disco #$($disco.Numero):`n"
        $discosText += "  • Modelo: $($disco.Modelo)`n"
        $discosText += "  • Tipo: $($disco.Tipo)`n"
        $discosText += "  • Capacidad: $($disco.CapacidadGB) GB`n"
        $discosText += "  • Interface: $($disco.Interface)`n"
        $discosText += "  • Particiones: $($disco.Particiones)`n"
        $discosText += "  • Serial: $($disco.Serial)`n"
        $discosText += "`n"
    }
    $discosText
} else {
    "No se detectaron discos duros"
})

===============================================================================
                              TARJETAS GRÁFICAS
===============================================================================
$(if ($graficasInfo.Count -gt 0) {
    $gpuText = ""
    foreach ($gpu in $graficasInfo) {
        $gpuText += "Tarjeta Gráfica:`n"
        $gpuText += "  • Nombre: $($gpu.Nombre)`n"
        $gpuText += "  • Tipo: $($gpu.Tipo)`n"
        $gpuText += "  • Memoria: $($gpu.Memoria)`n"
        $gpuText += "  • Resolución actual: $($gpu.Resolucion)`n"
        $gpuText += "  • Frecuencia de refresco: $($gpu.Refresco)`n"
        $gpuText += "  • Driver: $($gpu.Driver)`n"
        $gpuText += "`n"
    }
    $gpuText
} else {
    "No se detectaron tarjetas gráficas específicas (usando gráficos básicos)"
})

===============================================================================
                       MONITORES CONECTADOS DETECTADOS
===============================================================================
Cantidad detectada:  $(($monitoresInfo | Where-Object { $_.Metodo -eq "WMI Monitor ID" }).Count)

$(if ($monitoresInfo.Count -gt 0) {
    $monitoresText = ""
    
    # Agrupar por método para mejor presentación
    $monitoresWMI = $monitoresInfo | Where-Object { $_.Metodo -eq "WMI Monitor ID" }
    $pantallasActivas = $monitoresInfo | Where-Object { $_.Metodo -eq "Pantalla Activa" }
    
    if ($monitoresWMI.Count -gt 0) {
        $monitoresText += "INFORMACIÓN DE FABRICANTE:`n"
        foreach ($monitor in $monitoresWMI) {
            $monitoresText += "Monitor #$($monitor.Numero):`n"
            $monitoresText += "  • Marca: $($monitor.Marca)`n"
            $monitoresText += "  • Modelo: $($monitor.Modelo)`n"
            $monitoresText += "  • Fabricante: $($monitor.Fabricante)`n"
            $monitoresText += "  • Serial: $($monitor.Serial)`n"
            $monitoresText += "`n"
        }
    }
    
    if ($pantallasActivas.Count -gt 0) {
        $monitoresText += "CONFIGURACIÓN DE PANTALLAS ACTIVAS:`n"
        foreach ($pantalla in $pantallasActivas) {
            $monitoresText += "Pantalla #$($pantalla.Numero):`n"
            $monitoresText += "  • Primaria: $($pantalla.Primaria)`n"
            $monitoresText += "  • Resolución: $($pantalla.Resolucion)`n"
            $monitoresText += "  • Área de trabajo: $($pantalla.AreaTrabajo)`n"
            $monitoresText += "  • Bits por pixel: $($pantalla.BitsPixel)`n"
            $monitoresText += "`n"
        }
    }
    
    $monitoresText
} else {
    "No se pudo obtener información detallada de los monitores"
})

===============================================================================
                                 INFORMACIÓN DE RED
===============================================================================
$(if ($adaptadoresRed.Count -gt 0) {
    $redText = ""
    foreach ($adapter in $adaptadoresRed) {
        $redText += "Adaptador: $($adapter.Description)`n"
        $redText += "  • MAC Address: $($adapter.MACAddress)`n"
        if ($adapter.IPAddress -and $adapter.IPAddress[0]) {
            $redText += "  • IP Address: $($adapter.IPAddress[0])`n"
        }
        if ($adapter.DefaultIPGateway -and $adapter.DefaultIPGateway[0]) {
            $redText += "  • Gateway: $($adapter.DefaultIPGateway[0])`n"
        }
        $redText += "  • DHCP Enabled: $($adapter.DHCPEnabled)`n"
        $redText += "`n"
    }
    $redText
} else {
    "No se detectaron adaptadores de red activos"
})

===============================================================================
                               INFORMACIÓN ADICIONAL
===============================================================================
BIOS:
  • Versión: $($bios.Version)
  • Fabricante: $($bios.Manufacturer)
  • Fecha: $($bios.ReleaseDate)

Placa Base:
  • Fabricante: $(Get-WmiObject Win32_BaseBoard).Manufacturer
  • Modelo: $(Get-WmiObject Win32_BaseBoard).Product
  • Serial: $(Get-WmiObject Win32_BaseBoard).SerialNumber

Tiempo de actividad del sistema: $([math]::Round($os.ConvertToDateTime($os.LastBootUpTime).Subtract((Get-Date)).TotalDays * -1, 2)) días

===============================================================================
                                   FIN DEL REPORTE
===============================================================================
Reporte generado automáticamente por Sistema de Inventario de Equipos
"@

# Guardar el reporte en archivo
$reporte | Out-File -FilePath $rutaCompleta -Encoding UTF8

# =============================================
# MOSTRAR RESUMEN EN PANTALLA
# =============================================

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "       RESUMEN DEL EQUIPO REVISADO       " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Usuario:            $nombreUsuario" -ForegroundColor Yellow
Write-Host "Equipo:             $tipoEquipo" -ForegroundColor Yellow
Write-Host "Procesador:         $($procesador.Name)" -ForegroundColor Yellow
Write-Host "Memoria RAM:        $($ramInfo.TotalGB) GB ($($ramInfo.Cantidad) módulos)" -ForegroundColor Yellow
Write-Host "Discos detectados:  $($discosInfo.Count)" -ForegroundColor Yellow
Write-Host "Tarjetas gráficas:  $($graficasInfo.Count)" -ForegroundColor Yellow

# Mostrar información específica de monitores
$monitoresWMI = $monitoresInfo | Where-Object { $_.Metodo -eq "WMI Monitor ID" }
$pantallasActivas = $monitoresInfo | Where-Object { $_.Metodo -eq "Pantalla Activa" }

Write-Host "Monitores detectados:" -ForegroundColor Yellow
if ($monitoresWMI.Count -gt 0) {
    foreach ($monitor in $monitoresWMI) {
        Write-Host "  - Monitor $($monitor.Numero): $($monitor.Marca) $($monitor.Modelo)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  - No se detectó información de fabricante" -ForegroundColor Gray
}

if ($pantallasActivas.Count -gt 0) {
    Write-Host "Pantallas activas:" -ForegroundColor Yellow
    foreach ($pantalla in $pantallasActivas) {
        Write-Host "  - Pantalla $($pantalla.Numero): $($pantalla.Resolucion) $($pantalla.Primaria)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  REPORTE GUARDADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Archivo: $nombreArchivo" -ForegroundColor White
Write-Host "Ruta: $(Get-Location)\$nombreArchivo" -ForegroundColor White
Write-Host ""
Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#By: Me6a
