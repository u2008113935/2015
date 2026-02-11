# 📊 Sistema de Análisis Automatizado de Scripts SQL - 2015

Este repositorio contiene un sistema automatizado que analiza en profundidad el contenido de 262 scripts SQL del año 2015, categorizándolos por tipo de requerimiento y tipo de crédito basándose en el análisis del código SQL real.

## 🎯 Características Principales

- **Análisis de Contenido**: Examina el código SQL real, no solo nombres de archivos
- **Clasificación Inteligente**: Categoriza por tipo de requerimiento (9 categorías) y tipo de crédito (7 tipos)
- **Reportes Múltiples**: Genera 4 tipos de reportes diferentes
- **Automatización**: GitHub Actions workflow para análisis continuo
- **Rápido**: Procesa 262 scripts en menos de 5 minutos

## 📁 Estructura del Proyecto

```
2015/
├── .github/
│   ├── scripts/
│   │   ├── analizar_sql_2015.py      # Script principal de análisis
│   │   └── config_analisis.json      # Configuración de categorías
│   └── workflows/
│       └── analizar_sql_2015.yml     # GitHub Actions workflow
├── reportes/                          # Reportes generados (ignorados en git)
│   ├── REPORTE_ANALISIS_2015.md
│   ├── analisis_detallado_2015.csv
│   ├── metricas_2015.json
│   └── presentacion_metricas_2015.md
├── Marzo2015/                         # Scripts SQL por mes
├── Abril2015/
├── Mayo2015/
├── ... (otros meses)
└── README.md                          # Este archivo
```

## 🚀 Uso del Sistema

### Ejecutar Análisis Manualmente

```bash
# Desde la raíz del repositorio
python3 .github/scripts/analizar_sql_2015.py
```

### Ejecutar vía GitHub Actions

1. Ve a la pestaña "Actions" en GitHub
2. Selecciona el workflow "Análisis Profundo Scripts SQL 2015"
3. Haz clic en "Run workflow"
4. Los reportes se generarán como artifacts descargables

### Ejecutar Automáticamente

El workflow se ejecuta automáticamente cuando:
- Se modifica un archivo `.sql`
- Se modifica el script de análisis
- Se modifica la configuración

## 📊 Reportes Generados

### 1. REPORTE_ANALISIS_2015.md
Reporte principal en formato Markdown con:
- Resumen ejecutivo
- Distribución mensual
- Categorización por tipo de requerimiento
- Categorización por tipo de crédito
- Top 10 scripts más complejos
- Conclusiones y métricas

### 2. analisis_detallado_2015.csv
Reporte detallado en CSV con todas las métricas de cada script:
- Mes, Archivo, Ruta
- Tipo de Requerimiento, Tipo de Crédito
- Tablas consultadas
- Palabras clave detectadas
- Tamaño, líneas de código, complejidad
- Comentarios extraídos

### 3. metricas_2015.json
Datos estructurados en JSON para integración con otras herramientas:
- Resumen con totales y estadísticas
- Distribución por mes
- Distribución por categoría
- Detalle completo de cada script

### 4. presentacion_metricas_2015.md
Formato de presentación con slides para reportes ejecutivos

## 🏷️ Categorías de Requerimientos

El sistema clasifica los scripts en 9 categorías:

1. **Morosidad** (10 scripts - 3.8%)
   - Análisis de cartera vencida y atrasos

2. **Clientes** (53 scripts - 20.2%)
   - Gestión y análisis de clientes

3. **Desembolsos** (105 scripts - 40.1%)
   - Análisis de créditos desembolsados

4. **Cartera** (9 scripts - 3.4%)
   - Análisis de saldos y carteras

5. **Reportes SBS** (36 scripts - 13.7%)
   - Reportes regulatorios

6. **Garantías** (24 scripts - 9.2%)
   - Gestión de garantías y prendas

7. **Expedientes** (10 scripts - 3.8%)
   - Gestión de expedientes

8. **Gerencia/Subgerencia** (2 scripts - 0.8%)
   - Reportes gerenciales estratégicos

9. **Otros** (13 scripts - 5.0%)
   - Scripts no categorizados

## 💳 Tipos de Crédito

El sistema identifica 7 tipos de crédito:

1. **Múltiple/General** (186 scripts - 71.0%)
2. **Microempresa** (27 scripts - 10.3%)
3. **Prendario** (21 scripts - 8.0%)
4. **Hipotecario** (15 scripts - 5.7%)
5. **CTS** (5 scripts - 1.9%)
6. **Consumo** (4 scripts - 1.5%)
7. **No Minorista** (4 scripts - 1.5%)

## 🔧 Configuración

La configuración del sistema está en `.github/scripts/config_analisis.json`:

- **Tablas del sistema**: Lista de tablas conocidas
- **Categorías de requerimiento**: Reglas de clasificación por tablas y palabras clave
- **Tipos de crédito**: Patrones para detectar tipos de crédito
- **Meses**: Distribución esperada por mes

Puedes modificar este archivo para ajustar las reglas de clasificación.

## 📈 Estadísticas del Análisis

- **Total de scripts analizados**: 262
- **Período**: Marzo - Diciembre 2015 (10 meses)
- **Mes con mayor actividad**: Mayo 2015 (63 scripts)
- **Categoría más frecuente**: Desembolsos (40.1%)
- **Complejidad promedio**: ~5 tablas por script
- **Tamaño promedio**: ~6 KB por script

## 🛠️ Requisitos

- Python 3.11+
- No requiere dependencias externas (usa solo bibliotecas estándar)

## 📝 Notas Técnicas

- El análisis se basa en expresiones regulares para detectar tablas y palabras clave
- Soporta múltiples encodings (UTF-8, Latin-1, CP1252, ISO-8859-1)
- Ignora tablas temporales (#TMP_*)
- Los reportes se generan en la carpeta `reportes/` (no se suben a git)

## 🤝 Contribuir

Para mejorar el sistema de análisis:

1. Modifica `.github/scripts/config_analisis.json` para ajustar categorías
2. Actualiza `.github/scripts/analizar_sql_2015.py` para nuevas funcionalidades
3. Ejecuta el análisis para validar cambios
4. Crea un pull request con los cambios

## 📄 Licencia

Este proyecto es parte del repositorio privado de análisis de datos 2015.

---

**Generado automáticamente por el Sistema de Análisis SQL 2015**
