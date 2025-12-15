🖥️ PC Hardware Inventory Tool

**Herramienta automatizada para inventariar hardware de equipos de cómputo**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/powershell/)
[![Windows](https://img.shields.io/badge/Windows-7+-green.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Descripción

Script PowerShell que recolecta automáticamente información completa del hardware de un equipo Windows, ideal para técnicos, soporte IT y administradores de sistemas que necesitan realizar inventarios rápidos.

## ✨ Características Principales

### 🔍 **Detección Completa de Hardware**
- ✅ **Procesador**: Marca, modelo, núcleos, velocidad
- ✅ **Memoria RAM**: Total, módulos, tipo (DDR3/DDR4/DDR5), velocidad, fabricante
- ✅ **Almacenamiento**: Discos (SSD/HDD), capacidad, modelo, interface
- ✅ **Tarjetas Gráficas**: Dedicadas e integradas, memoria, driver
- ✅ **Monitores**: **¡Múltiples monitores detectados!**, marca, modelo, serial, resolución
- ✅ **Sistema**: Tipo (ensamblado/de marca), modelo, serial, BIOS

### 🚀 **Funcionalidades Especiales**
- 🎯 **Detección de múltiples monitores** conectados simultáneamente
- 📊 **Clasificación automática** de equipo (ensamblado vs. de marca)
- 💾 **Exportación automática** a archivo TXT con nombre personalizado
- ⚡ **Ejecución rápida** desde USB sin instalación
- 📝 **Interfaz interactiva** con preguntas guiadas

## 📁 Estructura del Proyecto
PC-Inventory-Tool/
│
├── Get-PCInventory.ps1 # Script principal (versión completa)
├── Get-PCInventory-Simple.ps1 # Versión simplificada
├── README.md # Este archivo
├── LICENSE # Licencia MIT
└── examples/ # Ejemplos de salida
├── Equipo_Juan_Perez_20241216_1430.txt
└── Equipo_Maria_Garcia_20241216_1520.txt

text

## 🛠️ Requisitos

- **Sistema Operativo**: Windows 7, 8, 10, 11 o superior
- **PowerShell**: Versión 5.1 o superior (incluido en Windows 10+)
- **Permisos**: Ejecución como administrador (recomendado)
- **Espacio**: Menos de 1 MB

## 🚀 Instalación y Uso

### Método 1: Desde USB (Recomendado para técnicos)
1. Copia el script a tu USB
2. En el equipo a revisar, abre PowerShell **como administrador**
3. Navega a la unidad USB: `E:` (ajusta la letra)
4. Ejecuta: `.\Get-PCInventory.ps1`

### Método 2: Clonar repositorio
#powershell
# Clonar el repositorio
git clone https://github.com/tuusuario/pc-inventory-tool-byme6a.git
cd pc-inventory-tool-byme6a

# Ejecutar el script
.\Get-PCInventory.ps1
Método 3: Descarga directa
Descarga Get-PCInventory.ps1 desde Releases

Ejecuta desde PowerShell

🔧 Primer Uso - Configurar Política de Ejecución
Si es la primera vez que ejecutas scripts PowerShell, ejecuta esto como administrador:

powershell
# Para esta sesión solamente
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# O para permitir permanentemente (recomendado para técnicos)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
📊 Ejemplo de Uso
text
=========================================
   SISTEMA DE INVENTARIO DE EQUIPOS     
=========================================

Ingrese el nombre del usuario/dueño del equipo: Juan Pérez

Recolectando información del equipo...

  - Obteniendo información del sistema...
  - Analizando almacenamiento...
  - Revisando memoria RAM...
  - Detectando tarjetas gráficas...
  - Escaneando monitores conectados...
  - Revisando información de red...

=========================================
       RESUMEN DEL EQUIPO REVISADO       
=========================================

Usuario:            Juan Pérez
Equipo:             De Marca - Dell Inc.
Procesador:         Intel(R) Core(TM) i7-10700 CPU @ 2.90GHz
Memoria RAM:        16 GB (2 módulos)
Discos detectados:  2
Tarjetas gráficas:  1
Monitores detectados:
  - Monitor 1: Dell U2415
  - Monitor 2: Dell U2415
Pantallas activas:
  - Pantalla 1: 1920x1200 PRIMARIA
  - Pantalla 2: 1920x1200 SECUNDARIA

=========================================
  REPORTE GUARDADO EXITOSAMENTE
=========================================

Archivo: Equipo_Juan_Perez_20241216_1430.txt
Ruta: C:\Users\Admin\Desktop\Equipo_Juan_Perez_20241216_1430.txt
📄 Formato del Archivo de Salida
El script genera un archivo con nombre: Equipo_[Nombre]_[Fecha]_[Hora].txt

Contenido del reporte:

text
INFORMACIÓN DEL EQUIPO
Usuario: Juan Pérez
Fecha: 2024-12-16 14:30

SISTEMA:
  Marca: Dell Inc.
  Modelo: OptiPlex 7080
  Tipo: De Marca

PROCESADOR:
  Modelo: Intel(R) Core(TM) i7-10700
  Núcleos: 8
  Hilos: 16

MEMORIA RAM:
  Total: 16 GB
  Módulos: 2 x 8GB DDR4 3200MHz

ALMACENAMIENTO:
  Disco 1: Samsung SSD 970 EVO 500GB (SSD)
  Disco 2: Seagate ST2000DM001 2TB (HDD)

TARJETA GRÁFICA:
  NVIDIA GeForce RTX 3060 12GB

MONITORES:
  Monitor 1: Dell U2415 (Serial: ABC123)
  Monitor 2: Dell U2415 (Serial: DEF456)

... y más información
🆕 Novedades en la Versión Actual
¡Nueva Detección de Múltiples Monitores! 🖥️🖥️
La versión actualizada ahora detecta TODOS los monitores conectados usando 3 métodos diferentes:

Información de fabricante (WmiMonitorID) - Marca, modelo, serial

Dispositivos PnP - Monitores detectados por Windows

Pantallas activas - Configuración actual, resolución, primaria/secundaria

Mejoras Adicionales:
✅ Clasificación mejorada de equipos (ensamblado vs. de marca)

✅ Información detallada de cada módulo de RAM

✅ Tipo exacto de disco (SSD NVMe, SATA, HDD)

✅ Información de fabricante de componentes

✅ Formato de reporte más profesional

🤝 Contribuir
¡Las contribuciones son bienvenidas!

Haz fork del repositorio

Crea una rama para tu función (git checkout -b nueva-funcion)

Commit tus cambios (git commit -am 'Agrega nueva función')

Push a la rama (git push origin nueva-funcion)

Abre un Pull Request

Mejoras Planeadas:
Exportar a CSV/Excel

Interfaz gráfica (GUI)

Escaneo de red (múltiples equipos)

Base de datos centralizada

Detección de software instalado

📝 Changelog
v2.0 (Actual)
Nuevo: Detección completa de múltiples monitores

Nuevo: Información de fabricante de componentes

Mejora: Reporte más detallado y organizado

Mejora: Clasificación mejorada de tipo de equipo

Fix: Errores de sintesis corregidos

v1.0
Información básica de hardware

Exportación a TXT

Detección simple de componentes

🐛 Reportar Problemas
Si encuentras algún error o tienes sugerencias:

Revisa los Issues

Si no existe, crea uno nuevo con:

Descripción del problema

Sistema operativo y versión de PowerShell

Captura de pantalla si es posible

Salida de error completa

📄 Licencia
Este proyecto está bajo la licencia MIT. Ver archivo LICENSE para más detalles.

⭐ Reconocimientos
Desarrollado por: [Tu Nombre/Equipo]

Inspirado en: Necesidades reales de soporte técnico

Para: Técnicos, administradores de sistemas y profesionales IT

¿Te sirvió esta herramienta? ¡Dale una estrella al repositorio! ⭐

¿Problemas o sugerencias? Abre un Issue o Pull Request.

¿Quieres más herramientas IT? ¡Síguenos para futuros proyectos!

text

## 🎯 Recomendaciones adicionales para tu repositorio:

### 1. **Agregar un archivo `.gitignore`**:
```gitignore
# .gitignore para PowerShell proyectos
*.suo
*.user
*.cache
*.bak
*.tmp
*.log
.DS_Store
Thumbs.db
output/
temp/
2. Agregar un archivo LICENSE (MIT):
text
MIT License

Copyright (c) 2024 [Tu Nombre]

Permission is hereby granted, free of charge, to any person obtaining a copy...
3. Estructura recomendada de carpetas:
text
.github/
  workflows/          # GitHub Actions para CI/CD
docs/                # Documentación adicional
screenshots/         # Capturas de pantalla
tests/               # Scripts de prueba
4. Badges adicionales (opcional):
markdown
[![GitHub Stars](https://img.shields.io/github/stars/tuusuario/pc-inventory-tool-byme6a?style=social)](https://github.com/tuusuario/pc-inventory-tool-byme6a)
[![Downloads](https://img.shields.io/github/downloads/tuusuario/pc-inventory-tool-byme6a/total)](https://github.com/tuusuario/pc-inventory-tool-byme6a/releases)
[![Last Commit](https://img.shields.io/github/last-commit/tuusuario/pc-inventory-tool-byme6a)](https://github.com/tuusuario/pc-inventory-tool-byme6a/commits/main)
5. Commits iniciales sugeridos:
bash
# Inicializar repositorio
git init
git add .
git commit -m "feat: :sparkles: Initial commit - PC Hardware Inventory Tool v2.0"

git add README.md
git commit -m "docs: :memo: Add comprehensive README with multiple monitor detection feature"

git add Get-PCInventory.ps1
git commit -m "feat: :children_crossing: Add enhanced multi-monitor detection and professional reporting"

# Agregar repositorio remoto
git remote add origin https://github.com/tuusuario/pc-inventory-tool-byme6a.git
git branch -M main
git push -u origin main
