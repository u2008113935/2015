# 📚 Sistema de Análisis Multi-Repositorio de Requerimientos de Data

## 📋 Descripción

Este sistema automatizado permite **evidenciar y cuantificar el trabajo manual** realizado en la extracción de data mediante scripts SQL distribuidos en los repositorios 2015, 2016, 2017 y 2018.

### Objetivos

- ✅ Evidenciar el volumen de trabajo realizado
- ✅ Justificar necesidades de automatización
- ✅ Documentar tipos de atención brindados
- ✅ Generar métricas para presentaciones

---

## 🚀 Inicio Rápido

### Ejecución Manual (Local)

```bash
# 1. Clonar el repositorio
git clone https://github.com/u2008113935/2015.git
cd 2015

# 2. Ejecutar el análisis
python .github/scripts/analizar_requerimientos_multi.py

# 3. Ver los reportes generados
ls -l reportes/
```

### Ejecución con GitHub Actions

1. Ir a la pestaña **Actions** en GitHub
2. Seleccionar el workflow **"Análisis Multi-Repositorio de Requerimientos"**
3. Click en **"Run workflow"**
4. (Opcional) Marcar la opción para incluir repos externos
5. Click en **"Run workflow"** para confirmar
6. Esperar a que termine la ejecución
7. Descargar los reportes desde **Artifacts**

---

## 📊 Reportes Generados

El sistema genera 4 tipos de reportes complementarios:

### 1. 📄 REPORTE_EJECUTIVO.md

**Para quién:** Gerencia, directores, tomadores de decisiones

**Contenido:**
- Resumen ejecutivo con métricas clave
- Distribución por año y categoría
- Top 10 tipos de atención más frecuentes
- Gráficos ASCII para visualización rápida
- Conclusiones y recomendaciones

**Uso típico:**
```markdown
# Incluir en presentaciones ejecutivas
# Adjuntar en propuestas de proyecto
# Compartir con stakeholders
```

### 2. 📊 metricas_completas.json

**Para quién:** Desarrolladores, sistemas de BI, integraciones

**Contenido:**
- Datos estructurados en formato JSON
- Métricas detalladas por repositorio y categoría
- Información de cada archivo analizado
- Timestamps y metadata

**Uso típico:**
```javascript
// Importar en dashboards
// Procesar con scripts de análisis
// Integrar con sistemas de BI
const metricas = require('./reportes/metricas_completas.json');
console.log(`Total scripts: ${metricas.resumen_general.total_scripts}`);
```

### 3. 📋 analisis_detallado.csv

**Para quién:** Analistas, usuarios de Excel

**Contenido:**
- Una fila por cada script SQL encontrado
- Columnas: Repositorio, Mes, Categoría, Nombre, Ruta, Tamaño, Keywords

**Uso típico:**
```
1. Abrir en Microsoft Excel o Google Sheets
2. Crear tablas dinámicas
3. Filtrar por categoría o mes
4. Generar gráficos personalizados
```

### 4. 🎯 presentacion_metricas.md

**Para quién:** Presentadores, facilitadores

**Contenido:**
- Formato de slides en Markdown
- Estadísticas visuales listas para copiar
- Gráficos de barras ASCII
- Datos formateados para PowerPoint/Google Slides

**Uso típico:**
```markdown
# Convertir a PowerPoint con Pandoc
pandoc presentacion_metricas.md -o presentacion.pptx

# O copiar slides individualmente a presentación existente
```

---

## 📁 Estructura del Proyecto

```
2015/
├── .github/
│   ├── scripts/
│   │   ├── analizar_requerimientos_multi.py  # Script principal
│   │   └── config_categorias.json            # Configuración
│   └── workflows/
│       └── analizar_multi_repo.yml           # GitHub Action
├── reportes/                                  # Reportes generados
│   ├── REPORTE_EJECUTIVO.md
│   ├── metricas_completas.json
│   ├── analisis_detallado.csv
│   └── presentacion_metricas.md
└── README_ANALISIS_MULTIREPO.md              # Esta documentación
```

---

## 🔧 Configuración

### Categorías de Análisis

Las categorías se configuran en `.github/scripts/config_categorias.json`:

```json
{
  "categorias": {
    "Cartera": {
      "keywords": ["cart", "cartera"],
      "descripcion": "Gestión de carteras de créditos",
      "color": "#FF6B6B"
    },
    ...
  }
}
```

### Añadir Nueva Categoría

1. Editar `config_categorias.json`
2. Añadir nueva entrada con keywords y descripción
3. Ejecutar análisis nuevamente

**Ejemplo:**

```json
"Nueva Categoría": {
  "keywords": ["palabra1", "palabra2"],
  "descripcion": "Descripción de la categoría",
  "color": "#HEXCODE"
}
```

### Modificar Repositorios a Analizar

En `config_categorias.json`, sección `repositorios`:

```json
"repositorios": [
  "u2008113935/2015",
  "u2008113935/2016",
  "u2008113935/2017",
  "u2008113935/2018"
]
```

---

## 📖 Cómo Funciona

### Proceso de Análisis

1. **Escaneo:** Busca recursivamente todos los archivos `.sql`
2. **Categorización:** Identifica categoría basada en keywords en nombre y ruta
3. **Extracción:** Obtiene metadata (tamaño, fecha, ubicación)
4. **Agregación:** Calcula estadísticas por año, mes y categoría
5. **Generación:** Crea los 4 reportes en diferentes formatos

### Criterios de Categorización

Un archivo se categoriza por:
- **Nombre del archivo:** `QueryCreditos.sql` → Categoría "Créditos"
- **Ruta:** `CarteraAgSelva/Query.sql` → Categoría "Cartera"
- **Keywords detectadas:** Múltiples palabras clave aumentan precisión

### Manejo de Categoría "Otros"

Si un archivo no coincide con ninguna keyword, se asigna a "Otros".

---

## 🎯 Casos de Uso

### Caso 1: Presentación a Gerencia

**Objetivo:** Justificar inversión en automatización

**Proceso:**
1. Ejecutar análisis
2. Abrir `REPORTE_EJECUTIVO.md`
3. Copiar sección "Resumen Ejecutivo"
4. Usar `presentacion_metricas.md` para slides
5. Enfatizar: volumen (scripts totales), diversidad (categorías), oportunidad (categorías frecuentes)

**Mensaje clave:** 
> "Hemos identificado XXX scripts SQL que representan trabajo manual recurrente. Automatizar las top 3 categorías podría reducir XX% del esfuerzo."

### Caso 2: Análisis Detallado por Área

**Objetivo:** Entender necesidades específicas de un departamento

**Proceso:**
1. Abrir `analisis_detallado.csv` en Excel
2. Filtrar por categoría específica (ej: "Créditos")
3. Crear tabla dinámica por mes
4. Identificar patrones temporales
5. Exportar subset para análisis adicional

### Caso 3: Documentación de Proyecto

**Objetivo:** Fundamentar requerimientos de un proyecto de BI

**Proceso:**
1. Extraer métricas de `metricas_completas.json`
2. Citar en documento de proyecto:
   - Volumen histórico de requerimientos
   - Categorías afectadas
   - Frecuencia de solicitudes
3. Adjuntar `REPORTE_EJECUTIVO.md` como anexo

### Caso 4: Dashboard de Métricas

**Objetivo:** Visualización continua en herramienta de BI

**Proceso:**
1. Configurar ejecución programada del análisis
2. Leer `metricas_completas.json` desde BI tool
3. Crear visualizaciones:
   - Trend de scripts por año
   - Distribución por categoría
   - Heat map temporal
4. Actualizar automáticamente

---

## 🔍 Interpretación de Resultados

### Métricas Clave

| Métrica | Qué significa | Acción sugerida |
|---------|---------------|-----------------|
| **Total de scripts > 100** | Alto volumen de trabajo manual | Priorizar automatización |
| **Top categoría > 30%** | Concentración en área específica | Enfoque inicial de automatización |
| **Categorías > 10** | Alta diversidad de necesidades | Solución flexible requerida |
| **Scripts por año creciendo** | Demanda incremental | Urgencia de solución |

### Banderas Rojas 🚩

- Scripts muy frecuentes con nombres genéricos ("Query.sql") → Falta de documentación
- Categoría "Otros" > 20% → Necesidad de refinar categorías
- Concentración en un solo mes → Posible carga estacional

### Oportunidades 💡

- Categoría frecuente + keywords claras → Fácil de automatizar
- Patrones repetitivos → Candidatos para templates
- Múltiples categorías pequeñas → Consolidación posible

---

## 🛠️ Solución de Problemas

### Error: "No se encontraron archivos SQL"

**Causa:** El script no está en la raíz del repositorio correcto

**Solución:**
```bash
cd /ruta/correcta/al/repo/2015
python .github/scripts/analizar_requerimientos_multi.py
```

### Error: "Permission denied" en GitHub Actions

**Causa:** El workflow no tiene permisos para hacer commit

**Solución:** Esto es normal y esperado. Los reportes se generan como artifacts de todas formas.

### Reportes vacíos o incompletos

**Causa:** Problemas de encoding o rutas

**Solución:**
```bash
# Verificar encoding de archivos
file -i reportes/*.md

# Re-ejecutar con modo verbose
python .github/scripts/analizar_requerimientos_multi.py --verbose
```

### Categorización incorrecta

**Causa:** Keywords insuficientes o demasiado genéricas

**Solución:**
1. Editar `config_categorias.json`
2. Añadir keywords más específicas
3. Re-ejecutar análisis

---

## 📈 Roadmap y Extensiones

### Funcionalidades Futuras

- [ ] Análisis de contenido SQL (no solo nombres)
- [ ] Detección de queries similares (deduplicación)
- [ ] Estimación de tiempo de ejecución
- [ ] Recomendaciones automáticas de optimización
- [ ] Integración con JIRA/Confluence
- [ ] Dashboard web interactivo
- [ ] Alertas automáticas de nuevos scripts

### Cómo Contribuir

1. Fork del repositorio
2. Crear branch para nueva funcionalidad
3. Implementar cambios
4. Añadir tests si aplica
5. Crear Pull Request

---

## 📞 Soporte

### Preguntas Frecuentes

**P: ¿Necesito acceso a las bases de datos?**  
R: No. El análisis funciona solo con nombres y estructura de archivos.

**P: ¿Puedo usar esto en otros repositorios?**  
R: Sí. Modifica `config_categorias.json` para adaptarlo.

**P: ¿Los reportes se actualizan automáticamente?**  
R: Solo cuando ejecutas el análisis manualmente o vía GitHub Actions.

**P: ¿Puedo exportar a Excel?**  
R: Sí. `analisis_detallado.csv` se abre directamente en Excel.

### Contacto

Para soporte adicional:
- 📧 Email: [contacto del equipo]
- 💬 Slack: [canal del proyecto]
- 🐛 Issues: [GitHub Issues](https://github.com/u2008113935/2015/issues)

---

## 📝 Notas de Versión

### v1.0.0 (2026-02-11)

**Funcionalidades:**
- ✅ Análisis de archivos SQL en múltiples repositorios
- ✅ Categorización automática por keywords
- ✅ Generación de 4 tipos de reportes
- ✅ GitHub Action para ejecución automatizada
- ✅ Configuración externa en JSON

**Categorías soportadas:**
- Cartera, Expedientes, Créditos, Garantías
- Morosidad, Reportes SBS, Clientes, RCC
- Análisis Geográfico, Promotor Inmobiliario
- Análisis Financiero, Otros

---

## 📄 Licencia

Este proyecto es de uso interno de la organización.

---

## 🙏 Agradecimientos

Desarrollado para evidenciar y valorar el trabajo manual del equipo de Data Analytics.

**Equipo:** [Nombres del equipo]  
**Última actualización:** 2026-02-11

---

*Para más información sobre cada reporte, consulta los archivos generados en el directorio `reportes/`*
