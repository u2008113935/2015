#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema de Análisis Automatizado de Scripts SQL - Repositorio 2015
Analiza 200 scripts SQL del año 2015, categorizándolos por tipo de requerimiento y crédito
"""

import os
import re
import json
import csv
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Set, Tuple

class SQLAnalyzer2015:
    """Analizador de scripts SQL del repositorio 2015"""
    
    def __init__(self, config_path: str):
        """Inicializa el analizador con la configuración"""
        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        self.root_path = Path(__file__).parent.parent.parent
        self.reportes_path = self.root_path / "reportes"
        self.scripts_analizados = []
        self.estadisticas = defaultdict(int)
        
    def extraer_tablas(self, contenido: str) -> Set[str]:
        """Extrae nombres de tablas del contenido SQL"""
        tablas = set()
        contenido_upper = contenido.upper()
        
        # Patrones para detectar tablas
        patrones = [
            r'FROM\s+([A-Z0-9_\.]+)',
            r'JOIN\s+([A-Z0-9_\.]+)',
            r'INTO\s+([A-Z0-9_\.]+)',
            r'UPDATE\s+([A-Z0-9_\.]+)',
            r'INSERT\s+INTO\s+([A-Z0-9_\.]+)',
        ]
        
        for patron in patrones:
            matches = re.findall(patron, contenido_upper)
            for match in matches:
                # Limpiar el nombre de la tabla
                tabla = match.split('.')[-1]  # Tomar solo el nombre de la tabla
                tabla = tabla.strip('[]() \t\n')
                if tabla and not tabla.startswith('#'):  # Ignorar tablas temporales
                    tablas.add(tabla)
        
        return tablas
    
    def extraer_palabras_clave(self, contenido: str) -> Set[str]:
        """Extrae palabras clave relevantes del contenido"""
        palabras = set()
        contenido_upper = contenido.upper()
        
        # Buscar todas las palabras clave de configuración
        for categoria, config in self.config['categorias_requerimiento'].items():
            for palabra in config['palabras_clave']:
                if palabra.upper() in contenido_upper:
                    palabras.add(palabra.upper())
        
        for tipo, config in self.config['tipos_credito'].items():
            for palabra in config['palabras_clave']:
                if palabra.upper() in contenido_upper:
                    palabras.add(palabra.upper())
        
        return palabras
    
    def extraer_comentarios(self, contenido: str) -> List[str]:
        """Extrae comentarios del SQL"""
        comentarios = []
        
        # Comentarios de línea --
        comentarios_linea = re.findall(r'--(.+?)(?:\n|$)', contenido)
        comentarios.extend([c.strip() for c in comentarios_linea if c.strip()])
        
        # Comentarios de bloque /* */
        comentarios_bloque = re.findall(r'/\*(.+?)\*/', contenido, re.DOTALL)
        for bloque in comentarios_bloque:
            lineas = [l.strip() for l in bloque.split('\n') if l.strip()]
            comentarios.extend(lineas)
        
        return comentarios[:10]  # Limitar a primeros 10 comentarios relevantes
    
    def clasificar_tipo_requerimiento(self, tablas: Set[str], palabras_clave: Set[str], 
                                      comentarios: List[str]) -> str:
        """Clasifica el tipo de requerimiento basado en análisis de contenido"""
        puntuaciones = defaultdict(int)
        
        # Analizar tablas
        for categoria, config in self.config['categorias_requerimiento'].items():
            if categoria == 'Otros':
                continue
            
            for tabla_config in config['tablas']:
                for tabla_encontrada in tablas:
                    if tabla_config.upper() in tabla_encontrada.upper():
                        puntuaciones[categoria] += 3
            
            # Analizar palabras clave
            for palabra_config in config['palabras_clave']:
                if palabra_config.upper() in [p.upper() for p in palabras_clave]:
                    puntuaciones[categoria] += 2
        
        # Analizar comentarios
        comentarios_texto = ' '.join(comentarios).upper()
        for categoria, config in self.config['categorias_requerimiento'].items():
            if categoria == 'Otros':
                continue
            for palabra in config['palabras_clave']:
                if palabra.upper() in comentarios_texto:
                    puntuaciones[categoria] += 1
        
        # Retornar la categoría con mayor puntuación
        if puntuaciones:
            return max(puntuaciones.items(), key=lambda x: x[1])[0]
        else:
            return 'Otros'
    
    def clasificar_tipo_credito(self, contenido: str, palabras_clave: Set[str]) -> str:
        """Clasifica el tipo de crédito basado en análisis de contenido"""
        contenido_upper = contenido.upper()
        puntuaciones = defaultdict(int)
        
        for tipo, config in self.config['tipos_credito'].items():
            if tipo == 'Múltiple/General':
                continue
            
            for palabra in config['palabras_clave']:
                # Búsqueda exacta de palabra clave
                if palabra.upper() in contenido_upper:
                    puntuaciones[tipo] += 1
        
        # Si hay múltiples tipos detectados (2 o más), es Múltiple/General
        if len([t for t, p in puntuaciones.items() if p > 0]) >= 2:
            return 'Múltiple/General'
        
        # Retornar el tipo con mayor puntuación
        if puntuaciones:
            return max(puntuaciones.items(), key=lambda x: x[1])[0]
        else:
            return 'Múltiple/General'
    
    def analizar_script_sql(self, ruta_archivo: Path) -> Dict:
        """Analiza un script SQL y extrae toda la información relevante"""
        try:
            # Intentar múltiples encodings
            contenido = None
            for encoding in ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']:
                try:
                    with open(ruta_archivo, 'r', encoding=encoding, errors='ignore') as f:
                        contenido = f.read()
                    break
                except:
                    continue
            
            if not contenido:
                return None
            
            # Obtener estadísticas del archivo
            tamaño_kb = ruta_archivo.stat().st_size / 1024
            lineas_codigo = len(contenido.split('\n'))
            
            # Análisis de contenido
            tablas_detectadas = self.extraer_tablas(contenido)
            palabras_clave = self.extraer_palabras_clave(contenido)
            comentarios = self.extraer_comentarios(contenido)
            
            # Clasificación
            tipo_requerimiento = self.clasificar_tipo_requerimiento(
                tablas_detectadas, palabras_clave, comentarios
            )
            tipo_credito = self.clasificar_tipo_credito(contenido, palabras_clave)
            
            # Extraer mes de la ruta
            mes = None
            for mes_nombre in self.config['meses'].keys():
                if mes_nombre in str(ruta_archivo):
                    mes = mes_nombre
                    break
            
            # Calcular complejidad (basada en número de tablas)
            complejidad = len(tablas_detectadas)
            
            return {
                'archivo': ruta_archivo.name,
                'ruta': str(ruta_archivo.relative_to(self.root_path)),
                'mes': mes,
                'tipo_requerimiento': tipo_requerimiento,
                'tipo_credito': tipo_credito,
                'tablas': list(tablas_detectadas),
                'palabras_clave': list(palabras_clave),
                'comentarios_extraidos': comentarios[:3],  # Primeros 3 comentarios
                'tamaño_kb': round(tamaño_kb, 2),
                'lineas_codigo': lineas_codigo,
                'complejidad': complejidad
            }
        except Exception as e:
            print(f"   ⚠ Error analizando {ruta_archivo.name}: {str(e)}")
            return None
    
    def encontrar_scripts_sql(self) -> List[Path]:
        """Encuentra todos los scripts SQL en el repositorio"""
        scripts = []
        for mes in self.config['meses'].keys():
            mes_path = self.root_path / mes
            if mes_path.exists():
                scripts.extend(list(mes_path.rglob('*.sql')))
        return scripts
    
    def analizar_todos_scripts(self):
        """Analiza todos los scripts SQL del repositorio"""
        print("=" * 80)
        print("   ANÁLISIS PROFUNDO DE SCRIPTS SQL - AÑO 2015")
        print("=" * 80)
        print()
        
        scripts = self.encontrar_scripts_sql()
        total_scripts = len(scripts)
        
        # Analizar por mes
        for mes in self.config['meses'].keys():
            mes_path = self.root_path / mes
            if not mes_path.exists():
                continue
            
            scripts_mes = [s for s in scripts if mes in str(s)]
            if not scripts_mes:
                continue
            
            print(f"📂 Analizando {mes}...")
            
            for script in scripts_mes:
                resultado = self.analizar_script_sql(script)
                if resultado:
                    self.scripts_analizados.append(resultado)
                    print(f"   ✓ {resultado['archivo'][:60]} → "
                          f"Tipo: {resultado['tipo_requerimiento']} | "
                          f"Crédito: {resultado['tipo_credito']}")
            
            print(f"   [{len(scripts_mes)}/{len(scripts_mes)} scripts procesados]")
            print()
        
        print("=" * 80)
        print("   RESUMEN FINAL")
        print("=" * 80)
        print()
        
        self._mostrar_resumen()
    
    def _mostrar_resumen(self):
        """Muestra el resumen del análisis"""
        total = len(self.scripts_analizados)
        print(f"✅ Total procesado: {total} scripts")
        print()
        
        # Resumen por categoría
        print("📊 Categorías identificadas:")
        categorias_count = defaultdict(int)
        for script in self.scripts_analizados:
            categorias_count[script['tipo_requerimiento']] += 1
        
        for categoria in sorted(categorias_count.keys()):
            count = categorias_count[categoria]
            porcentaje = (count / total * 100) if total > 0 else 0
            print(f"   - {categoria}: {count} scripts ({porcentaje:.1f}%)")
        print()
        
        # Resumen por tipo de crédito
        print("💳 Tipos de Crédito:")
        creditos_count = defaultdict(int)
        for script in self.scripts_analizados:
            creditos_count[script['tipo_credito']] += 1
        
        for tipo in sorted(creditos_count.keys()):
            print(f"   - {tipo}: {creditos_count[tipo]} scripts")
        print()
    
    def generar_reportes(self):
        """Genera todos los reportes"""
        # Crear directorio de reportes
        self.reportes_path.mkdir(exist_ok=True)
        
        print("📄 Generando reportes...")
        
        self._generar_reporte_markdown()
        self._generar_reporte_csv()
        self._generar_reporte_json()
        self._generar_presentacion()
        
        print("   ✓ reportes/REPORTE_ANALISIS_2015.md")
        print("   ✓ reportes/analisis_detallado_2015.csv")
        print("   ✓ reportes/metricas_2015.json")
        print("   ✓ reportes/presentacion_metricas_2015.md")
        print()
    
    def _generar_reporte_markdown(self):
        """Genera el reporte principal en Markdown"""
        reporte_path = self.reportes_path / "REPORTE_ANALISIS_2015.md"
        
        total = len(self.scripts_analizados)
        
        # Calcular estadísticas
        por_mes = defaultdict(int)
        por_categoria = defaultdict(int)
        por_credito = defaultdict(int)
        
        for script in self.scripts_analizados:
            if script['mes']:
                por_mes[script['mes']] += 1
            por_categoria[script['tipo_requerimiento']] += 1
            por_credito[script['tipo_credito']] += 1
        
        with open(reporte_path, 'w', encoding='utf-8') as f:
            f.write("# 📊 Análisis de Requerimientos de Data - Año 2015\n\n")
            
            # Resumen Ejecutivo
            f.write("## Resumen Ejecutivo\n\n")
            f.write(f"- **Total de scripts analizados**: {total}\n")
            f.write(f"- **Período**: Marzo - Diciembre 2015\n")
            f.write(f"- **Análisis basado en**: Contenido real de scripts SQL\n")
            f.write(f"- **Fecha de análisis**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            # Distribución Mensual
            f.write("## Distribución Mensual\n\n")
            f.write("| Mes | Scripts | Porcentaje |\n")
            f.write("|-----|---------|------------|\n")
            
            for mes in ['Marzo2015', 'Abril2015', 'Mayo2015', 'Junio2015', 'Julio2015',
                       'Agosto2015', 'Septiembre2015', 'Octubre2015', 'Noviembre2015', 'Diciembre2015']:
                count = por_mes.get(mes, 0)
                porcentaje = (count / total * 100) if total > 0 else 0
                f.write(f"| {mes} | {count} | {porcentaje:.1f}% |\n")
            
            f.write(f"\n**Total**: {total} scripts\n\n")
            
            # Categorización por Tipo de Requerimiento
            f.write("## Categorización por Tipo de Requerimiento\n\n")
            
            for categoria in sorted(por_categoria.keys(), key=lambda x: por_categoria[x], reverse=True):
                count = por_categoria[categoria]
                porcentaje = (count / total * 100) if total > 0 else 0
                
                f.write(f"### {categoria} ({count} scripts - {porcentaje:.1f}%)\n\n")
                
                config = self.config['categorias_requerimiento'].get(categoria, {})
                f.write(f"**Descripción**: {config.get('descripcion', 'N/A')}\n\n")
                
                # Tablas principales
                if config.get('tablas'):
                    f.write(f"**Tablas principales**: {', '.join(config['tablas'])}\n\n")
                
                # Ejemplos de scripts
                ejemplos = [s for s in self.scripts_analizados if s['tipo_requerimiento'] == categoria][:3]
                if ejemplos:
                    f.write("**Ejemplos de scripts**:\n")
                    for ej in ejemplos:
                        f.write(f"- `{ej['ruta']}`\n")
                f.write("\n")
            
            # Categorización por Tipo de Crédito
            f.write("## Categorización por Tipo de Crédito\n\n")
            f.write("| Tipo de Crédito | Cantidad | Porcentaje |\n")
            f.write("|-----------------|----------|------------|\n")
            
            for tipo in sorted(por_credito.keys(), key=lambda x: por_credito[x], reverse=True):
                count = por_credito[tipo]
                porcentaje = (count / total * 100) if total > 0 else 0
                f.write(f"| {tipo} | {count} | {porcentaje:.1f}% |\n")
            
            f.write("\n")
            
            # Top 10 Scripts Más Complejos
            f.write("## Top 10 Scripts Más Complejos\n\n")
            f.write("*Basado en número de tablas consultadas*\n\n")
            f.write("| Ranking | Script | Tablas | Tipo Requerimiento |\n")
            f.write("|---------|--------|--------|--------------------|\n")
            
            scripts_ordenados = sorted(self.scripts_analizados, key=lambda x: x['complejidad'], reverse=True)[:10]
            for i, script in enumerate(scripts_ordenados, 1):
                nombre = script['archivo'][:40]
                f.write(f"| {i} | {nombre} | {script['complejidad']} | {script['tipo_requerimiento']} |\n")
            
            f.write("\n")
            
            # Conclusiones
            f.write("## Conclusiones y Métricas\n\n")
            mes_mayor = max(por_mes.items(), key=lambda x: x[1]) if por_mes else ("N/A", 0)
            categoria_mayor = max(por_categoria.items(), key=lambda x: x[1]) if por_categoria else ("N/A", 0)
            
            f.write(f"- **Mes con mayor actividad**: {mes_mayor[0]} ({mes_mayor[1]} scripts)\n")
            f.write(f"- **Categoría más frecuente**: {categoria_mayor[0]} ({categoria_mayor[1]} scripts)\n")
            f.write(f"- **Complejidad promedio**: {sum(s['complejidad'] for s in self.scripts_analizados) / total:.1f} tablas por script\n")
            f.write(f"- **Tamaño promedio**: {sum(s['tamaño_kb'] for s in self.scripts_analizados) / total:.1f} KB por script\n")
    
    def _generar_reporte_csv(self):
        """Genera el reporte detallado en CSV"""
        csv_path = self.reportes_path / "analisis_detallado_2015.csv"
        
        with open(csv_path, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=[
                'Mes', 'Archivo', 'Ruta', 'Tipo_Requerimiento', 'Tipo_Credito',
                'Tablas_Consultadas', 'Palabras_Clave', 'Tamaño_KB', 'Lineas_Codigo',
                'Complejidad', 'Comentarios_Extraidos'
            ])
            writer.writeheader()
            
            for script in self.scripts_analizados:
                writer.writerow({
                    'Mes': script['mes'] or '',
                    'Archivo': script['archivo'],
                    'Ruta': script['ruta'],
                    'Tipo_Requerimiento': script['tipo_requerimiento'],
                    'Tipo_Credito': script['tipo_credito'],
                    'Tablas_Consultadas': '; '.join(script['tablas']),
                    'Palabras_Clave': '; '.join(script['palabras_clave']),
                    'Tamaño_KB': script['tamaño_kb'],
                    'Lineas_Codigo': script['lineas_codigo'],
                    'Complejidad': script['complejidad'],
                    'Comentarios_Extraidos': ' | '.join(script['comentarios_extraidos'])
                })
    
    def _generar_reporte_json(self):
        """Genera el reporte de métricas en JSON"""
        json_path = self.reportes_path / "metricas_2015.json"
        
        # Calcular resúmenes
        por_mes = defaultdict(int)
        por_categoria = defaultdict(int)
        por_credito = defaultdict(int)
        
        for script in self.scripts_analizados:
            if script['mes']:
                por_mes[script['mes']] += 1
            por_categoria[script['tipo_requerimiento']] += 1
            por_credito[script['tipo_credito']] += 1
        
        metricas = {
            "resumen": {
                "total_scripts": len(self.scripts_analizados),
                "fecha_analisis": datetime.now().isoformat(),
                "por_mes": dict(por_mes),
                "por_tipo_requerimiento": dict(por_categoria),
                "por_tipo_credito": dict(por_credito)
            },
            "detalle_scripts": self.scripts_analizados
        }
        
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(metricas, f, indent=2, ensure_ascii=False)
    
    def _generar_presentacion(self):
        """Genera presentación en formato Markdown"""
        pres_path = self.reportes_path / "presentacion_metricas_2015.md"
        
        total = len(self.scripts_analizados)
        
        # Calcular estadísticas
        por_mes = defaultdict(int)
        por_categoria = defaultdict(int)
        
        for script in self.scripts_analizados:
            if script['mes']:
                por_mes[script['mes']] += 1
            por_categoria[script['tipo_requerimiento']] += 1
        
        with open(pres_path, 'w', encoding='utf-8') as f:
            f.write("---\n")
            f.write("# 📊 Análisis Scripts SQL 2015\n")
            f.write(f"## {total} Scripts SQL Analizados\n\n")
            f.write("- **Período**: Marzo - Diciembre 2015\n")
            f.write("- **10 meses** de operación\n")
            f.write("- Análisis basado en **contenido real**\n\n")
            
            f.write("---\n")
            f.write("# 📈 Distribución Mensual\n\n")
            
            # Gráfico ASCII de barras
            max_count = max(por_mes.values()) if por_mes else 1
            for mes in ['Marzo2015', 'Abril2015', 'Mayo2015', 'Junio2015', 'Julio2015',
                       'Agosto2015', 'Septiembre2015', 'Octubre2015', 'Noviembre2015', 'Diciembre2015']:
                count = por_mes.get(mes, 0)
                barra = '█' * int((count / max_count) * 50)
                f.write(f"{mes[:10]:15} {barra} {count}\n")
            
            f.write("\n---\n")
            f.write("# 🎯 Tipos de Requerimiento\n\n")
            
            # Top 5 categorías
            top_categorias = sorted(por_categoria.items(), key=lambda x: x[1], reverse=True)[:5]
            for categoria, count in top_categorias:
                porcentaje = (count / total * 100) if total > 0 else 0
                f.write(f"## {categoria}\n")
                f.write(f"**{count} scripts** ({porcentaje:.1f}%)\n\n")
            
            f.write("---\n")
            f.write("# ✅ Conclusiones\n\n")
            
            mes_mayor = max(por_mes.items(), key=lambda x: x[1]) if por_mes else ("N/A", 0)
            categoria_mayor = max(por_categoria.items(), key=lambda x: x[1]) if por_categoria else ("N/A", 0)
            
            f.write(f"- **Mes pico**: {mes_mayor[0]} ({mes_mayor[1]} scripts)\n")
            f.write(f"- **Categoría dominante**: {categoria_mayor[0]}\n")
            f.write(f"- **Diversidad**: {len(por_categoria)} tipos de requerimientos\n")
            f.write("- **Calidad**: Análisis basado en contenido real SQL\n\n")


def main():
    """Función principal"""
    # Obtener ruta del script actual
    script_dir = Path(__file__).parent
    config_path = script_dir / "config_analisis.json"
    
    # Crear analizador
    analyzer = SQLAnalyzer2015(str(config_path))
    
    # Analizar scripts
    analyzer.analizar_todos_scripts()
    
    # Generar reportes
    analyzer.generar_reportes()
    
    print("✨ Análisis completado exitosamente!")


if __name__ == "__main__":
    main()
