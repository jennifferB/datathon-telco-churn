# 📊 Campos Calculados de Tableau — Telco (Grupo 2)

* **Fuente de datos:** Modelo dimensional  `telco_g2` (Conexión en vivo).
* **Tablas relacionadas:** `fact_contracts_telco_g2` + `dim_customer_telco_g2` + `dim_contract_telco_g2` + `dim_service_telco_g2`.

> ⚠️ **Nota sobre nombres:** En el panel de datos, los campos calculados siguen exactamente la nomenclatura en minúsculas y guiones bajos (`snake_case`) mostrada en Tableau (por ejemplo, `segmento`, `nombre_segmento`, `churn_porcentaje`). Todas las fórmulas hacen referencia a estos identificadores exactos.

## 📌 Regla Importante sobre el Conteo de Clientes

* ❌ **No usar `COUNT([customer_key])`:** El campo existe en dos tablas y puede generar ambigüedad.
* ✅ **Usar `COUNT([churn_flag])`:** Solo existe en la tabla de hechos y nunca es nulo (equivale exactamente al número de clientes: 1 fila por cliente).

> **Paso a paso en Tableau:** Crear desde **Análisis → Crear campo calculado**, respetando el orden numérico descrito a continuación.

---

## 1. `segmento` (Dimensión)

Cada cliente cae en el **primer** criterio que cumple.

```sql
IF [contract_type]='Month-to-month' AND [internet_service]='Fiber optic' AND [service_level]='Basico' THEN 'SEG-01'
ELSEIF [contract_type]='Month-to-month' AND [tenure_months]<=12 THEN 'SEG-02'
ELSEIF [contract_type]='Month-to-month' AND [payment_method]='Electronic check' THEN 'SEG-03'
ELSE 'SEG-04' 
END
```

💡 *Tip:* Arrastrar los campos directamente desde el panel al editor para evitar errores de sintaxis o tipografía (ej. `[tenure_months]` sin comilla).

---

## 2. `nombre_segmento` (Dimensión)

Versión descriptiva con código incluido (utilizada en los gráficos del Dashboard):

```sql
CASE [segmento]
WHEN 'SEG-01' THEN 'SEG-01 · Fibra básica mes a mes'
WHEN 'SEG-02' THEN 'SEG-02 · Nuevos mes a mes'
WHEN 'SEG-03' THEN 'SEG-03 · Cheque electrónico'
ELSE 'SEG-04 · Resto de clientes' 
END
```

---

## 3. Medidas Base

| Campo Calculado | Fórmula | Descripción / Formato |
| :--- | :--- | :--- |
| `clientes` | `COUNT([churn_flag])` | Conteo total de registros. |
| `abandonos` | `SUM([churn_flag])` | Suma de registros con churn. |
| `churn_porcentaje` | `SUM([churn_flag]) / COUNT([churn_flag])` | Tasa de abandono (Porcentaje, 2 decimales). |
| `churn_global` | `{ FIXED : SUM([churn_flag]) / COUNT([churn_flag]) }` | Tasa fija general (Porcentaje, 2 decimales). |
| `razon_vs_global` | `[churn_porcentaje] / [churn_global]` | Comparativa relativa. |
| `porcentaje_abandonos` | `SUM([churn_flag]) / SUM({ FIXED : SUM([churn_flag]) })` | Distribución del churn (Porcentaje, 2 decimales). |
| `cargo_mensual_medio` | `AVG([monthly_charges])` | Promedio de facturación mensual. |
| `porcentaje_imputados` | `SUM([total_charges_imputed]) / COUNT([churn_flag])` | Proporción de datos imputados (Porcentaje, 2 decimales). |

---

## 4. Parámetro `escenario`

Ruta: Clic derecho en el panel de datos → **Crear parámetro**.

| Propiedad | Valor |
| :--- | :--- |
| **Nombre** | `escenario` |
| **Tipo de datos** | Cadena |
| **Valores permitidos** | Lista: `Conservador`, `Central`, `Optimista` |
| **Valor actual** | `Central` |

*Para mostrarlo en pantalla: Clic derecho sobre el parámetro → **Mostrar parámetro** .*

---

## 5. Factor y Reducción

```sql
// factor_escenario
CASE [escenario] 
WHEN 'Conservador' THEN 0.5 
WHEN 'Central' THEN 1.0 
WHEN 'Optimista' THEN 1.5 
END
```

```sql
// reduccion_relativa_central
CASE [segmento] 
WHEN 'SEG-01' THEN 0.20 
WHEN 'SEG-02' THEN 0.15 
WHEN 'SEG-03' THEN 0.12 
ELSE 0.02 
END
```

```sql
// reduccion_relativa_escenario
[reduccion_relativa_central] * [factor_escenario]
```

ℹ️ *Nota metodológica:* Las reducciones (20% / 15% / 12% / 2%) representan **supuestos del equipo**, interpretados como reducción **relativa** y no como puntos porcentuales directos. No constituyen eficacia medida previamente.

---

## 6. KPIs de Escenario

```sql
// abandonos_evitados_equivalentes
SUM([churn_flag] * [reduccion_relativa_escenario])
```

```sql
// Churn_escenario_porcentaje
SUM([churn_flag] * (1 - [reduccion_relativa_escenario])) / COUNT([churn_flag])
```

```sql
// reducción_puntos_porcentuales
[churn_porcentaje] - [Churn_escenario_porcentaje]
```

```sql
// reducción_relativa_porcentaje (KPI estrella)
SUM([churn_flag] * [reduccion_relativa_escenario]) / SUM([churn_flag])
```

> **Atención:** Estos cálculos están escritos a nivel de fila para asegurar que funcionen exactamente igual por segmento y en el total ponderado (evitando promediar tasas entre segmentos).

---

## 7. Textos de Acción (Tabla del Recomendador)

```sql
// accion_propuesta
CASE [segmento]
WHEN 'SEG-01' THEN 'Revisar incidencias; ofrecer soporte y opción anual voluntaria'
WHEN 'SEG-02' THEN 'Acompañamiento de incorporación, uso y facturación'
WHEN 'SEG-03' THEN 'Revisar fricciones de pago y ofrecer pago automático voluntario'
ELSE 'Revisar subgrupos por contrato y servicio; atención preventiva' 
END
```

```sql
// incentivo_a_evaluar
CASE [segmento]
WHEN 'SEG-01' THEN 'Prueba de soporte; descuento sujeto a coste y aprobación'
WHEN 'SEG-02' THEN 'Asistencia inicial y seguimiento'
WHEN 'SEG-03' THEN 'Incentivo de adopción según coste y elegibilidad'
ELSE 'Definir tras revisar necesidad y coste' 
END
```

```sql
// canal_propuesto
CASE [segmento]
WHEN 'SEG-01' THEN 'Contacto por canal consentido'
WHEN 'SEG-02' THEN 'Canal digital consentido'
WHEN 'SEG-03' THEN 'Portal de pagos o canal consentido'
ELSE 'Canal consentido según preferencia' 
END
```

---

## 8. Campos Auxiliares

```sql
// reduccion_supuesta (Para la tabla de acciones; formato % sin decimales)
AVG([reduccion_relativa_escenario])
```

```sql
// nivel_de_riesgo (Opcional: para colorear rojo / gris)
IF [churn_porcentaje] > [churn_global] THEN 'Sobre el promedio' ELSE 'Bajo el promedio' END
```

---

## 🔍 Checkpoints de Validación

### Base del modelo

| Control | Valor Esperado |
| :--- | :--- |
| **`clientes`** | 7.043 |
| **`abandonos`** | 1.869 |
| **`churn_global`** | 26,54 % |
| **Imputaciones de TotalCharges** | 11 |

### Segmentos

| `segmento` | `clientes` | `abandonos` | `churn_porcentaje` |
| :--- | ---: | ---: | ---: |
| **SEG-01** | 1.524 | 925 | 60,70 % |
| **SEG-02** | 1.230 | 467 | 37,97 % |
| **SEG-03** | 451 | 146 | 32,37 % |
| **SEG-04** | 3.838 | 331 | 8,62 % |

### Escenarios (Total Global)

| Escenario | `Churn_escenario_porcentaje` | `abandonos_evitados_equivalentes` | `reducción_relativa_porcentaje` | `reducción_puntos_porcentuales` |
| :--- | ---: | ---: | ---: | ---: |
| **Conservador** | 24,55 % | 139,60 | 7,47 % | 1,98 |
| **Central** | 22,57 % | 279,19 | 14,94 % | 3,96 |
| **Optimista** | 20,59 % | 418,79 | 22,41 % | 5,95 |

---
