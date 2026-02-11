--=================================
-- CLASIFICACION DE GARANTIAS 
--=================================

SELECT *
FROM GENTClaGaran
WHERE lconestado = 1

SELECT *
FROM GENTTipGaran
WHERE lEstTipGar = 1

SELECT *
FROM GENTSubTipGar
WHERE lconestado = 1

SELECT B.CCODCLAGAR,B.CCODTIPGAR,ccodsubgar,cdesclagar,CDESTIPGAR,C.cdesdetgar,*
FROM GENTClaGaran A
	INNER JOIN GENTTipGaran B
		ON A.CCODCLAGAR = B.CCODCLAGAR
	INNER JOIN GENTSubTipGar C
		ON A.CCODCLAGAR = C.CCODCLAGAR
			AND B.CCODTIPGAR = C.CCODTIPGAR
WHERE A.lconestado = 1
	AND B.lEstTipGar = 1
	AND C.lconestado = 1

SELECT *
FROM GENDGarantia
WHERE lconestado = 1
		and ccodgarant LIKE '%RPHIP%'


SELECT *
FROM GENDGarantia
WHERE lconestado = 1
	AND CCODCLAGAR + CCODTIPGAR = '0101'

SELECT *
FROM GENDGarantia
WHERE lconestado = 1
	AND ccodgarant IN ('NRDON','NRDOI')
	AND CCODCLAGAR + CCODTIPGAR = '0201'

-- PERSONAL : cCodCliente - 107013587713
-- PLAZO FIJO : cCodCliente - 107017077784

--====================================
-- TABLAS DE REGISTRO DE GARANTIAS 
--====================================

SELECT *
FROM CMACHYOCLI_MANIANA..CLIMGarCliente
WHERE cCodCliente  = '107019678163'
	AND cCodGarCli = '001'


--=======================================
-- GARANTIAS FISICAS - HIPOTECARIAS
--=======================================
SELECT *
FROM CMACHYOCLI_MANIANA..CliMGarFisHipCli
WHERE cCodCliente  = '107011247503'
	AND cCodGarCli = '001'


--=======================================
-- GARANTIAS TITULO VALOR 
--=======================================
SELECT *
FROM CMACHYOCLI_MANIANA..CliMGarTitValCli
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'

--=======================================
-- GARANTIAS PERSONALES
--=======================================
SELECT *
FROM CMACHYOCLI_MANIANA..CliMGarPerCli
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'

--=======================================
-- GARANTIAS PERSONALES
--=======================================
SELECT *
FROM CMACHYOCLI_MANIANA..CLIDDirGarant
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'



--=======================================
-- GARANTIAS PERSONALES
--=======================================
SELECT *
FROM KPYHGarCliente
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'
	

--=======================================
-- BLOQUEO DE CUENTA 
--=======================================

SELECT *
FROM AHOTCtaBloque
WHERE CCODCUENTA = ''

--=======================================
-- BLOQUEO DE CUENTA 
--=======================================

SELECT *
FROM KPYDAnuGarCli
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'

--===================================
-- DATOS ADICIONALES DE GARANTIAS 
--===================================

SELECT *
FROM CMACHYOCLI_MANIANA..CliMGarFisHipCli
WHERE cCodCliente  = '107011247503'
	AND cCodGarCli = '001'

SELECT *
FROM CMACHYOCLI_MANIANA..CliMGarTitValCli
WHERE cCodCliente  = '107010317660'
	AND cCodGarCli = '001'


--===========================================
-- VINCULACION DE GARANTIAS CON EVALUACION 
--===========================================
SELECT *
FROM KPYDRelGarSol
WHERE cCodSolCre = '0020096890'


--===========================================
-- TABLA TOPES Y % DE GARANTIAS 
--===========================================

SELECT *
FROM KPYTValGarant
WHERE lConEstado = 1
	AND cCodGarant = 'RPDPF'
	AND cCodOficin = '002'
	AND cCodTipCre + cCodProduc + cCodSubPro = '020215'

SELECT *
FROM KPYTValGarant
WHERE lConEstado = 1
	AND cCodGarant = 'NRDON'
	AND cCodOficin = '002'
	AND cCodTipCre + cCodProduc + cCodSubPro = '020215'


--===========================================
-- VINCULACIÓN DE CREDITOS Y GARANTIAS 
--===========================================

SELECT *
FROM KPYDGarLinCre
WHERE cCodLinCre = '0020073453'

SELECT CCODTIPCRE,CCODPRODUC,CCODSUBPRO,CCODOFICIN, *
FROM KPYMSolicitud
WHERE CCODSOLCRE = '0020091857'

SELECT *
FROM KPYTVALGARANT
WHERE CCODTIPCRE + CCODPRODUC + CCODSUBPRO + CCODOFICIN = '030301002'
	AND cCodGarant = 'RPHIP'


--- SP DE VALIDACION DE % Y TOPES - KPY_RetCobGarantia_sp 

--===========================================
-- CUENTA DE CREDITO Y GARANTIAS 
--===========================================

SELECT B.CCODLINCRE , A.*
FROM KPYMCRECONVEN A
	INNER JOIN GENMCRECLI B
		ON A.CCODCTACRE = B.CCODCTACRE
WHERE A.CESTCRECON = 'F' 
	AND A.CCODOFICIN = '002'


SELECT B.CCODLINCRE , A.nMonCapDes , A.nMonCapPag,A.nMonCapDes - A.nMonCapPag  , A.*
FROM KPYMCRECONVEN A
	INNER JOIN GENMCRECLI B
		ON A.CCODCTACRE = B.CCODCTACRE
WHERE A.CESTCRECON = 'F' 
	AND B.cCodLinCre = '0020073453'

SELECT nMonGraGar, nMonGraGarSol , nMonGraGar * 3.1260 , *
FROM KPYDGarLinCre
WHERE cCodLinCre = '0020056190'

SELECT B.CCODLINCRE , A.nMonCapDes , A.nMonCapPag,A.nMonCapDes - A.nMonCapPag  , A.*
FROM KPYMCRECONVEN A
	INNER JOIN GENMCRECLI B
		ON A.CCODCTACRE = B.CCODCTACRE
WHERE A.CESTCRECON = 'F' 
	AND B.cCodLinCre = '0020085650'

SELECT nMonGraGar, nMonGraGarSol , nMonGraGar * 3.1260 , *
FROM KPYDGarLinCre
WHERE cCodLinCre = '0020085650'

--================================================
-- LIBERACION DE GARANTIAS AL PAGO DE LA GARANTIA
--================================================

-- KPY_GenCobCredit_sp

-- KPY_LIBGARANTI_SP

--========================================
-- TIPO DE CAMBIO FIJO 
--========================================
SELECT *
FROM ADMMVariable
WHERE cCodOficin = '002'
	AND cNomVarApl = 'gntipcamfij'


--===========================================
-- PROCESOS AUTOMATICOS GARANTIAS 
--===========================================

SELECT *
FROM GENMProcesos
WHERE cCodigoApl = 'KPY'


-- RECLASIFICACION DE ARANTIAS 

--KPY_ReClasGarMenDia_sp
--KPY_RecGarNoPreaPreDia_sP

-- ACTULAIZA MONTOS DE GRAVAMEN 

-- KPY_ActMonGravamen_SP

-- ACTUALIZA TABLA DE MONTOS MAXIMOS DE GARANTIAS SEGUN TIPO DE CAMBIO 

-- KPY_ActTipCamGar_sp
