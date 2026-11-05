# 🛡️ Reporte de Calidad de Datos (Data Quality - DQ)
**Proyecto:** Datatón Genius Lab III - Telecomunicaciones (IBM Telco Churn)  
**Tabla Auditada:** `DSADEV.raw_telco_g2`  
**Volumen evaluado:** 7,043 registros  
**Umbral Meta de Calidad:** ≥ 99.00%  
**Resultado Global Obtenido:** **100.00% de conformidad** ✅  

---

## 📋 Las 5 Reglas Obligatorias en OpenMetadata

| ID Regla | Columna Evaluada | Dimensión DQ | Tipo de Test en OpenMetadata (`Test Definition`) | Parámetros de Configuración | Resultado / Estado |
|---|---|---|---|---|---|
| **DQ-01** | `customerID` | **Unicidad** | `columnValuesToBeUnique` | *(Ninguno / 0 duplicados tolerados)* | ✅ **Passed (100%)** |
| **DQ-02** | `TotalCharges` | **Completitud** | `columnValuesToBeNotNull` | *(Imputado desde Talend con '0.00')* | ✅ **Passed (100%)** |
| **DQ-03** | `MonthlyCharges` | **Rango** | `columnValuesToBeBetween` | `minValue: 18.00`, `maxValue: 125.00` | ✅ **Passed (100%)** |
| **DQ-04** | `Contract` | **Validez** | `columnValuesToBeInSet` | `allowedValues: ['Month-to-month', 'One year', 'Two year']` | ✅ **Passed (100%)** |
| **DQ-05** | `Churn` | **Consistencia** | `columnValuesToBeInSet` | `allowedValues: ['Yes', 'No']` | ✅ **Passed (100%)** |

---

## 🔍 Detalle Técnico de Configuración en OpenMetadata

### 1. Test DQ-01: Unicidad de Clave Primaria (`customerID`)
* **Objetivo:** Garantizar que no existan clientes duplicados en la ingesta.
* **Métrica evaluada:** `COUNT(DISTINCT customerID) == COUNT(*)`.
* **Configuración OpenMetadata:**
  * **Test Type:** `columnValuesToBeUnique`
  * **Column:** `customerID`

### 2. Test DQ-02: Completitud en Facturación Total (`TotalCharges`)
* **Objetivo:** Verificar que ningún registro quede nulo o en blanco tras la ingesta (resolución de los 11 casos con `tenure = 0`).
* **Configuración OpenMetadata:**
  * **Test Type:** `columnValuesToBeNotNull`
  * **Column:** `TotalCharges`

### 3. Test DQ-03: Rango de Tarifa Mensual (`MonthlyCharges`)
* **Objetivo:** Detectar anomalías de cobro o valores negativos/desproporcionados.
* **Configuración OpenMetadata:**
  * **Test Type:** `columnValuesToBeBetween`
  * **Column:** `MonthlyCharges`
  * **Min Value:** `18.00`
  * **Max Value:** `125.00`

### 4. Test DQ-04: Dominio de Tipos de Contrato (`Contract`)
* **Objetivo:** Asegurar que los contratos pertenezcan a los tres modelos comerciales autorizados.
* **Configuración OpenMetadata:**
  * **Test Type:** `columnValuesToBeInSet`
  * **Column:** `Contract`
  * **Allowed Values:** `Month-to-month`, `One year`, `Two year`

### 5. Test DQ-05: Integridad de Variable Objetivo (`Churn`)
* **Objetivo:** Validar que el target analítico esté debidamente estandarizado en formato binario.
* **Configuración OpenMetadata:**
  * **Test Type:** `columnValuesToBeInSet`
  * **Column:** `Churn`
  * **Allowed Values:** `Yes`, `No`

---

## 📊 Evidencia de Ejecución SQL de Respaldo

Consulta ejecutada desde `sql/04_dq_tests.sql` en SingleStore:

```sql
SELECT 
    COUNT(*) AS total_registros,
    ROUND(COUNT(DISTINCT customerID) * 100.0 / COUNT(*), 2) AS pct_unicidad_customerID,
    ROUND(SUM(CASE WHEN TotalCharges IS NOT NULL AND TRIM(TotalCharges) != '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_completitud_TotalCharges,
    ROUND(SUM(CASE WHEN MonthlyCharges BETWEEN 18.00 AND 125.00 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_rango_MonthlyCharges,
    ROUND(SUM(CASE WHEN Contract IN ('Month-to-month', 'One year', 'Two year') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_validez_Contract,
    ROUND(SUM(CASE WHEN Churn IN ('Yes', 'No') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_consistencia_Churn
FROM DSADEV.raw_telco_g2;
```

**Resultado:**
* `total_registros`: 7043
* `pct_unicidad_customerID`: **100.00%**
* `pct_completitud_TotalCharges`: **100.00%**
* `pct_rango_MonthlyCharges`: **100.00%**
* `pct_validez_Contract`: **100.00%**
* `pct_consistencia_Churn`: **100.00%**
