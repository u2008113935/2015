#!/usr/bin/env python3
"""
Sistema de Análisis de Requerimientos de Data - Multi-Repositorio
Analiza scripts SQL en múltiples repositorios y genera reportes detallados
"""

import os
import json
import csv
from datetime import datetime
from pathlib import Path
from collections import defaultdict
import re
import sys

class AnalizadorMultiRepo:
    def __init__(self, config_path=None):
        """Inicializa el analizador con la configuración"""
        if config_path is None:
            config_path = Path(__file__).parent / "config_categorias.json"
        
        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        self.categorias = self.config['categorias']
        self.repositorios = self.config['repositorios']
        
        # Estructuras de datos para almacenar resultados
        self.archivos_analizados = []
        self.stats_por_repo = defaultdict(lambda: {'total': 0, 'categorias': defaultdict(int)})
        self.stats_por_categoria = defaultdict(int)
        self.stats_por_mes = defaultdict(int)
        
    def categorizar_archivo(self, nombre_archivo, ruta_completa):
        """Categoriza un archivo SQL basado en palabras clave"""
        nombre_lower = nombre_archivo.lower()
        ruta_lower = ruta_completa.lower()
        texto_busqueda = f"{nombre_lower} {ruta_lower}"
        
        categorias_encontradas = []
        keywords_encontradas = []
        
        for categoria, info in self.categorias.items():
            if categoria == "Otros":
                continue
            
            for keyword in info['keywords']:
                if keyword.lower() in texto_busqueda:
                    categorias_encontradas.append(categoria)
                    keywords_encontradas.append(keyword)
                    break
        
        # Si no se encontró ninguna categoría, asignar a "Otros"
        if not categorias_encontradas:
            return "Otros", []
        
        # Retornar la primera categoría encontrada
        return categorias_encontradas[0], keywords_encontradas
    
    def extraer_mes_de_ruta(self, ruta):
        """Extrae el mes de la ruta del archivo"""
        meses = {
            'enero': '01', 'febrero': '02', 'marzo': '03', 'abril': '04',
            'mayo': '05', 'junio': '06', 'julio': '07', 'agosto': '08',
            'septiembre': '09', 'octubre': '10', 'noviembre': '11', 'diciembre': '12'
        }
        
        ruta_lower = ruta.lower()
        for mes_nombre, mes_numero in meses.items():
            if mes_nombre in ruta_lower:
                return mes_nombre.capitalize()
        
        return "Sin mes"
    
    def extraer_anio_de_ruta(self, ruta):
        """Extrae el año de la ruta del archivo"""
        # Buscar patrones como 2015, 2016, 2017, 2018
        match = re.search(r'20(15|16|17|18)', ruta)
        if match:
            return match.group(0)
        return "Sin año"
    
    def analizar_repositorio(self, ruta_repo, nombre_repo):
        """Analiza todos los archivos SQL en un repositorio"""
        print(f"\n📂 Analizando repositorio {nombre_repo}...", end=' ')
        
        archivos_encontrados = []
        
        # Buscar todos los archivos .sql recursivamente
        for root, dirs, files in os.walk(ruta_repo):
            for file in files:
                if file.endswith('.sql'):
                    ruta_completa = os.path.join(root, file)
                    archivos_encontrados.append(ruta_completa)
        
        print(f"✓ {len(archivos_encontrados)} scripts encontrados")
        
        # Analizar cada archivo
        for ruta_completa in archivos_encontrados:
            nombre_archivo = os.path.basename(ruta_completa)
            ruta_relativa = os.path.relpath(ruta_completa, ruta_repo)
            
            # Categorizar
            categoria, keywords = self.categorizar_archivo(nombre_archivo, ruta_completa)
            
            # Extraer mes y año
            mes = self.extraer_mes_de_ruta(ruta_completa)
            anio = self.extraer_anio_de_ruta(ruta_completa)
            
            # Obtener tamaño del archivo
            try:
                tamanio = os.path.getsize(ruta_completa)
            except:
                tamanio = 0
            
            # Guardar información del archivo
            info_archivo = {
                'repositorio': nombre_repo,
                'anio': anio,
                'mes': mes,
                'categoria': categoria,
                'nombre': nombre_archivo,
                'ruta': ruta_relativa,
                'ruta_completa': ruta_completa,
                'tamanio': tamanio,
                'keywords': keywords
            }
            
            self.archivos_analizados.append(info_archivo)
            
            # Actualizar estadísticas
            self.stats_por_repo[nombre_repo]['total'] += 1
            self.stats_por_repo[nombre_repo]['categorias'][categoria] += 1
            self.stats_por_categoria[categoria] += 1
            
            if mes != "Sin mes":
                clave_mes = f"{anio}-{mes}"
                self.stats_por_mes[clave_mes] += 1
        
        return len(archivos_encontrados)
    
    def generar_reporte_ejecutivo(self, ruta_salida):
        """Genera el reporte ejecutivo en Markdown"""
        total_scripts = len(self.archivos_analizados)
        total_categorias = len([c for c in self.stats_por_categoria.keys() if self.stats_por_categoria[c] > 0])
        
        # Ordenar categorías por frecuencia
        categorias_ordenadas = sorted(
            self.stats_por_categoria.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        # Calcular top 10
        top_10 = categorias_ordenadas[:10]
        
        contenido = f"""# 📊 REPORTE EJECUTIVO - Análisis Multi-Repositorio de Requerimientos de Data

**Fecha de análisis:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Período analizado:** 2015-2018  
**Total de repositorios:** {len(self.repositorios)}

---

## 📈 Resumen Ejecutivo

### Métricas Clave

- **Total de scripts SQL analizados:** {total_scripts}
- **Categorías identificadas:** {total_categorias}
- **Repositorios analizados:** {len(self.stats_por_repo)}
- **Período de análisis:** 2015-2018

---

## 📊 Distribución por Repositorio/Año

"""
        
        # Tabla de distribución por repositorio
        for repo, stats in sorted(self.stats_por_repo.items()):
            contenido += f"### {repo}\n"
            contenido += f"- **Total de scripts:** {stats['total']}\n"
            contenido += f"- **Categorías principales:**\n"
            
            categorias_repo = sorted(stats['categorias'].items(), key=lambda x: x[1], reverse=True)[:5]
            for cat, count in categorias_repo:
                porcentaje = (count / stats['total'] * 100) if stats['total'] > 0 else 0
                contenido += f"  - {cat}: {count} scripts ({porcentaje:.1f}%)\n"
            contenido += "\n"
        
        contenido += "---\n\n"
        contenido += "## 🏆 Top 10 Tipos de Atención\n\n"
        contenido += "| # | Categoría | Cantidad | Porcentaje |\n"
        contenido += "|---|-----------|----------|------------|\n"
        
        for i, (categoria, cantidad) in enumerate(top_10, 1):
            porcentaje = (cantidad / total_scripts * 100) if total_scripts > 0 else 0
            contenido += f"| {i} | {categoria} | {cantidad} | {porcentaje:.1f}% |\n"
        
        contenido += "\n---\n\n"
        contenido += "## 📊 Gráfico de Distribución (ASCII)\n\n"
        contenido += "```\n"
        
        # Generar gráfico ASCII de barras
        max_cantidad = max([c for _, c in top_10]) if top_10 else 1
        for categoria, cantidad in top_10:
            barra_length = int((cantidad / max_cantidad) * 50)
            barra = "█" * barra_length
            contenido += f"{categoria:25} | {barra} {cantidad}\n"
        
        contenido += "```\n\n"
        
        contenido += "---\n\n"
        contenido += "## 💡 Conclusiones y Recomendaciones\n\n"
        contenido += f"1. **Volumen de Trabajo:** Se han identificado {total_scripts} scripts SQL que representan requerimientos de data atendidos manualmente.\n\n"
        contenido += f"2. **Áreas de Mayor Demanda:** La categoría '{categorias_ordenadas[0][0]}' concentra el mayor número de requerimientos ({categorias_ordenadas[0][1]} scripts), "
        contenido += f"lo que sugiere una necesidad de automatización en esta área.\n\n"
        contenido += f"3. **Diversidad de Atenciones:** Con {total_categorias} categorías diferentes, se evidencia una amplia variedad de necesidades de información.\n\n"
        contenido += "4. **Recomendaciones:**\n"
        contenido += "   - Priorizar la automatización de las categorías con mayor frecuencia\n"
        contenido += "   - Implementar dashboards o reportes automáticos para reducir trabajo manual\n"
        contenido += "   - Documentar patrones comunes para crear templates reutilizables\n"
        contenido += "   - Evaluar la creación de un data warehouse o data mart para consultas frecuentes\n\n"
        
        contenido += "---\n\n"
        contenido += "## 📅 Distribución Temporal\n\n"
        
        if self.stats_por_mes:
            contenido += "| Período | Scripts |\n"
            contenido += "|---------|----------|\n"
            for periodo, cantidad in sorted(self.stats_por_mes.items()):
                contenido += f"| {periodo} | {cantidad} |\n"
        else:
            contenido += "*No se pudo determinar la distribución temporal precisa*\n"
        
        contenido += "\n---\n\n"
        contenido += "*Este reporte fue generado automáticamente por el Sistema de Análisis Multi-Repositorio*\n"
        
        with open(ruta_salida, 'w', encoding='utf-8') as f:
            f.write(contenido)
        
        print(f"  📄 {ruta_salida}")
    
    def generar_metricas_json(self, ruta_salida):
        """Genera el archivo JSON con métricas completas"""
        # Preparar detalle de archivos
        detalle_archivos = []
        for archivo in self.archivos_analizados:
            detalle_archivos.append({
                'repositorio': archivo['repositorio'],
                'anio': archivo['anio'],
                'mes': archivo['mes'],
                'categoria': archivo['categoria'],
                'nombre': archivo['nombre'],
                'ruta': archivo['ruta'],
                'tamanio_bytes': archivo['tamanio'],
                'keywords_detectadas': archivo['keywords']
            })
        
        # Preparar por repositorio
        por_repositorio = {}
        for repo, stats in self.stats_por_repo.items():
            por_repositorio[repo] = {
                'total': stats['total'],
                'categorias': dict(stats['categorias'])
            }
        
        metricas = {
            'fecha_analisis': datetime.now().isoformat(),
            'resumen_general': {
                'total_scripts': len(self.archivos_analizados),
                'total_repositorios': len(self.stats_por_repo),
                'total_categorias': len([c for c in self.stats_por_categoria.keys() if self.stats_por_categoria[c] > 0]),
                'periodo': '2015-2018'
            },
            'por_repositorio': por_repositorio,
            'por_categoria': dict(self.stats_por_categoria),
            'por_mes': dict(self.stats_por_mes),
            'detalle_archivos': detalle_archivos
        }
        
        with open(ruta_salida, 'w', encoding='utf-8') as f:
            json.dump(metricas, f, indent=2, ensure_ascii=False)
        
        print(f"  📊 {ruta_salida}")
    
    def generar_csv_detallado(self, ruta_salida):
        """Genera el CSV con análisis detallado"""
        with open(ruta_salida, 'w', newline='', encoding='utf-8') as f:
            campos = [
                'Repositorio/Año',
                'Mes',
                'Categoría',
                'Nombre del archivo',
                'Ruta completa',
                'Tamaño del archivo (bytes)',
                'Palabras clave detectadas'
            ]
            
            writer = csv.DictWriter(f, fieldnames=campos)
            writer.writeheader()
            
            for archivo in self.archivos_analizados:
                writer.writerow({
                    'Repositorio/Año': archivo['repositorio'],
                    'Mes': archivo['mes'],
                    'Categoría': archivo['categoria'],
                    'Nombre del archivo': archivo['nombre'],
                    'Ruta completa': archivo['ruta'],
                    'Tamaño del archivo (bytes)': archivo['tamanio'],
                    'Palabras clave detectadas': ', '.join(archivo['keywords'])
                })
        
        print(f"  📋 {ruta_salida}")
    
    def generar_presentacion(self, ruta_salida):
        """Genera el archivo de presentación en Markdown"""
        total_scripts = len(self.archivos_analizados)
        
        # Ordenar categorías
        categorias_ordenadas = sorted(
            self.stats_por_categoria.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        contenido = f"""# 🎯 Presentación: Análisis de Requerimientos de Data 2015-2018

---

## Slide 1: Portada

# Sistema de Análisis de Requerimientos de Data
## Multi-Repositorio 2015-2018

**Evidencia del trabajo manual realizado**

---

## Slide 2: Contexto

### 📌 Situación Actual

- Múltiples requerimientos de data atendidos manualmente
- Scripts SQL distribuidos en 4 repositorios (2015-2018)
- Necesidad de evidenciar y cuantificar el trabajo realizado

---

## Slide 3: Números Clave

### 📊 Métricas Principales

```
╔════════════════════════════════════════╗
║  Total de Scripts SQL: {total_scripts:>10}     ║
║  Repositorios Analizados: {len(self.stats_por_repo):>7}      ║
║  Categorías de Atención: {len([c for c in self.stats_por_categoria.keys() if self.stats_por_categoria[c] > 0]):>8}      ║
║  Período: 2015-2018                    ║
╚════════════════════════════════════════╝
```

---

## Slide 4: Distribución por Año

### 📅 Scripts por Repositorio

"""
        
        # Añadir distribución por año
        for repo, stats in sorted(self.stats_por_repo.items()):
            anio = re.search(r'20(15|16|17|18)', repo)
            anio_str = anio.group(0) if anio else repo
            porcentaje = (stats['total'] / total_scripts * 100) if total_scripts > 0 else 0
            barra = "█" * int(porcentaje / 2)
            contenido += f"**{anio_str}:** {stats['total']:>3} scripts  {barra} {porcentaje:.1f}%\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 5: Top 5 Categorías\n\n"
        contenido += "### 🏆 Áreas de Mayor Demanda\n\n"
        
        top_5 = categorias_ordenadas[:5]
        for i, (categoria, cantidad) in enumerate(top_5, 1):
            porcentaje = (cantidad / total_scripts * 100) if total_scripts > 0 else 0
            contenido += f"**{i}. {categoria}**\n"
            contenido += f"   - {cantidad} scripts ({porcentaje:.1f}%)\n"
            contenido += f"   - {self.categorias.get(categoria, {}).get('descripcion', '')}\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 6: Gráfico Visual\n\n"
        contenido += "```\n"
        contenido += "DISTRIBUCIÓN DE REQUERIMIENTOS POR CATEGORÍA\n\n"
        
        max_cantidad = max([c for _, c in categorias_ordenadas]) if categorias_ordenadas else 1
        for i, (categoria, cantidad) in enumerate(categorias_ordenadas[:8]):
            barra_length = int((cantidad / max_cantidad) * 40)
            barra = "█" * barra_length
            contenido += f"{categoria[:20]:20} │ {barra} {cantidad}\n"
        
        contenido += "```\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 7: Impacto y Valor\n\n"
        contenido += "### 💼 Valor del Trabajo Realizado\n\n"
        contenido += f"- **{total_scripts} requerimientos** atendidos manualmente\n"
        contenido += f"- **{len([c for c in self.stats_por_categoria.keys() if self.stats_por_categoria[c] > 0])} áreas diferentes** de atención\n"
        contenido += "- **4 años** de datos históricos documentados\n"
        contenido += "- Base para justificar proyectos de **automatización**\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 8: Oportunidades de Mejora\n\n"
        contenido += "### 🚀 Recomendaciones\n\n"
        contenido += "1. **Automatización:** Priorizar las categorías con mayor frecuencia\n"
        contenido += "2. **Dashboards:** Implementar visualizaciones automáticas\n"
        contenido += "3. **Self-Service:** Habilitar consultas para usuarios finales\n"
        contenido += "4. **Data Warehouse:** Centralizar datos para acceso rápido\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 9: Conclusiones\n\n"
        contenido += "### ✅ Puntos Clave\n\n"
        contenido += f"- Evidencia clara del **volumen de trabajo manual** ({total_scripts} scripts)\n"
        contenido += f"- La categoría **{categorias_ordenadas[0][0]}** es la de mayor demanda ({categorias_ordenadas[0][1]} scripts)\n"
        contenido += "- Existe una **necesidad clara** de automatización y optimización\n"
        contenido += "- Los datos históricos permiten **tomar decisiones informadas**\n\n"
        
        contenido += "---\n\n"
        contenido += "## Slide 10: Siguiente Pasos\n\n"
        contenido += "### 📋 Plan de Acción\n\n"
        contenido += "1. Revisar análisis detallado con stakeholders\n"
        contenido += "2. Priorizar categorías para automatización\n"
        contenido += "3. Definir roadmap de implementación\n"
        contenido += "4. Establecer métricas de éxito\n\n"
        contenido += "---\n\n"
        contenido += "*Generado automáticamente por el Sistema de Análisis Multi-Repositorio*\n"
        
        with open(ruta_salida, 'w', encoding='utf-8') as f:
            f.write(contenido)
        
        print(f"  🎯 {ruta_salida}")
    
    def generar_reportes(self, directorio_salida):
        """Genera todos los reportes"""
        os.makedirs(directorio_salida, exist_ok=True)
        
        print("\nGenerando reportes:")
        
        self.generar_reporte_ejecutivo(
            os.path.join(directorio_salida, 'REPORTE_EJECUTIVO.md')
        )
        
        self.generar_metricas_json(
            os.path.join(directorio_salida, 'metricas_completas.json')
        )
        
        self.generar_csv_detallado(
            os.path.join(directorio_salida, 'analisis_detallado.csv')
        )
        
        self.generar_presentacion(
            os.path.join(directorio_salida, 'presentacion_metricas.md')
        )


def main():
    """Función principal"""
    print("=" * 80)
    print("   ANÁLISIS MULTI-REPOSITORIO DE REQUERIMIENTOS DE DATA (2015-2018)")
    print("=" * 80)
    
    # Inicializar analizador
    analizador = AnalizadorMultiRepo()
    
    # Determinar rutas de repositorios
    # Por defecto, buscar en el directorio actual (repo 2015)
    # Para otros repos, necesitarían estar clonados o accesibles
    
    repos_a_analizar = []
    
    # Buscar repositorio actual
    repo_actual = os.getcwd()
    if os.path.exists(repo_actual):
        # Detectar el año del repositorio actual
        repo_nombre = os.path.basename(repo_actual)
        if not re.search(r'20(15|16|17|18)', repo_nombre):
            # Si no tiene año en el nombre, buscar en la ruta
            match = re.search(r'20(15|16|17|18)', repo_actual)
            if match:
                repo_nombre = match.group(0)
            else:
                repo_nombre = "2015"  # Por defecto
        
        repos_a_analizar.append((repo_actual, repo_nombre))
    
    # Intentar encontrar otros repositorios hermanos
    repo_parent = os.path.dirname(repo_actual)
    for anio in ['2015', '2016', '2017', '2018']:
        ruta_hermano = os.path.join(repo_parent, anio)
        if os.path.exists(ruta_hermano) and ruta_hermano != repo_actual:
            repos_a_analizar.append((ruta_hermano, anio))
    
    # Analizar cada repositorio encontrado
    total_scripts = 0
    for ruta, nombre in repos_a_analizar:
        scripts_encontrados = analizador.analizar_repositorio(ruta, nombre)
        total_scripts += scripts_encontrados
    
    # Mostrar resumen
    print("\n" + "=" * 80)
    print("   RESUMEN GENERAL")
    print("=" * 80)
    print()
    print(f"✅ Total de scripts analizados: {total_scripts}")
    print(f"📊 Categorías identificadas: {len([c for c in analizador.stats_por_categoria.keys() if analizador.stats_por_categoria[c] > 0])}")
    print(f"📅 Período analizado: 2015-2018")
    
    if analizador.stats_por_categoria:
        categoria_top = max(analizador.stats_por_categoria.items(), key=lambda x: x[1])
        print(f"🏆 Categoría más frecuente: {categoria_top[0]} ({categoria_top[1]} scripts)")
    
    # Generar reportes
    directorio_reportes = os.path.join(repo_actual, 'reportes')
    analizador.generar_reportes(directorio_reportes)
    
    print()
    print("=" * 80)
    print("✓ Análisis completado exitosamente")
    print("=" * 80)


if __name__ == '__main__':
    main()
