sp_helptext Kpy_DevGarCli_sp


/*********************************************************************************************************
*	Copyright © 2011 CMAC Huancayo -. All rights reserved.                                       
*	Objetivo: Consulta datos de las Garantias de los Clientes
*  
*	Escrito por: 			GLOPEZ
*	Email/Movil/Phone:		GLOPEZ@CMAC-HUANCAYO.COM.PE
*	Fecha creación: 2003.06.30
*	Sistema / Modulo:	VITALIS / CREDITOS
	Modificaciones:
*	Fecha   		Responsable   	Motivo
*   2005.10.20		GLOPEZ			se modifica para uso de nueva tabla de Garantias
*	2005.02.10		GLOPEZ			se cambia el campo ccodgengar
*	2006.09.29		GLOPEZ			se modifica el campo: nMonGarOri y el campo: nTipCamGar
*	2006.11.16		GLOPEZ			se modifican los campos de dirección
*	2007.01.18		glopez			se añade campos para # de placa y Año de fabricación
*	2007.03.17		GLOPEZ			se añade el campo nPlaOtorga: Plazo de la Cta de Ahorros
*	2007.09.29		GLOPEZ			Centralización de BD.
*	2008.11.18		OPEREZ			Se agregó las campos de registros y modificacion de la garantia.
*	2008.12.26		OPEREZ			Se agregó los campos relacionados a las garantias autoliquidables y de Carta Fianza. 
*	2009.01.23		OPEREZ			Se agrego el campo de valor nuevo de garantia.
*	2009.02.16		OPEREZ			Se agregó el campo de Preferencia de la garantia.
*	2009.05.12		OPEREZ			Se agregó el el codigo completo de la garantia. 
*	2011.09.09      CMALPI			Se modificó el cálculo para el Valor de Realización.
*	2012.01.13		OPEREZ			Se agrego el campo de oficina que modifico. 
*	2012.12.12		YGONZA			Se agregó campo de porcentaje de cobertura y tipo de documento dejado. 
*	2013.01.15		FASTUH			Se modifico de acuerdo a la nueva estructura de garantias.
*	2013.09.03		CMUCHA			Se añade campo de cobertura de plazo fijo.
*	2013.10.15		EMEZAP			Se añade campo cDirCliUcv,cDirCliZon
*	2014.01.29		FASTUH			Se modifico campos y  ordeno consulta de datos.
*	2014.05.15		DFERNA			Adición de campos de prendas para credijoyas
*	2014.10.15		DFERNA			Adecuación para garantias de crédito prendario (KPR)
*	2015.02.23		FASTUH			Se agrego calculo para cuentas CTS
*
*	Sintaxis de ejemplo:

		EXEC Kpy_DevGarCli_sp '107013698619','002'
***********************************************************************************************************/

CREATE PROCEDURE [dbo].[Kpy_DevGarCli_SP]
	@x_cCodCliente CHAR(14),
	@x_cCodOficin CHAR(3)
AS
SET NOCOUNT ON	
SET DATEFORMAT YMD
BEGIN

	--==========================================
	-- DECLARA VARIABLES
	--==========================================

	DECLARE @ptipcamfij NUMERIC(14,4)
	SELECT @ptipcamfij = cvalvarapl
	FROM ADMMVariable
	WHERE cCodigoApl = 'ADM' 
		AND cNomVarApl = 'gntipcamfij'
		AND cCodOficin = '002' --@x_cCodOficin

	--==========================================
	-- CONSOLIDA DATOS DE TITULOS VALORES
	--==========================================

	SELECT A.cCodTipGar,B.cCodCuenta
	INTO #detCta
	FROM CMACHYOCLI.DBO.CLIMGarCliente A
		INNER JOIN CMACHYOCLI.DBO.CliMGarTitValCli B
			ON A.CCODCLIENTE = B.CCODCLIENTE
				AND A.CCODGARCLI = B.CCODGARCLI
	WHERE A.CCODCLIENTE = @x_cCodCliente 
		AND A.cCodEstGar = 'A'
		AND ISNULL(B.ccodcuenta,'') <> '' 
		AND A.cCodIndTipGar = '2' 
		
	SELECT G.cCodCuenta, G.dFecKardex, G.cCodTipOpe, 
		'nmonape' = CASE WHEN G.cCodTipOpe = '0001'
						THEN G.nMonTotKar
						ELSE 0.00
					END,
		'nmoncap' = CASE WHEN G.cCodTipOpe IN ('0005','0002')
						THEN G.nMonTotKar
						ELSE 0.00
					END,
		'nmonpag' = CASE WHEN G.cCodTipOpe = '0013'
							THEN G.nMonTotKar*(-1)
							ELSE 0.00
						END
	INTO #DetKarAho
	FROM GENMKardex G 
		INNER JOIN #detCta D
			ON G.cCodCuenta = D.cCodCuenta
	WHERE G.cCodTipKar = 'AHO'
			AND G.cCodTipOpe IN ('0001','0005','0013','0002')
			AND (G.cCodKarExt = '' OR G.cCodKarExt IS NULL)	
			AND cCodTipGar <> 'NPCTS'
						

	SELECT	D.cCodCuenta , 
			nmonape = SUM(D.nmonape) , 
			nmoncap = SUM(D.nmoncap) , 
			nmonpag = SUM(D.nmonpag) ,
			P.nPlaOtorga ,
			DFECINI = A.dFecApeCta ,
			DFECFIN = A.dFecApeCta + P.nPlaOtorga,
			P.cCodTipSub
	INTO #CurDatGarAut
	FROM #DetKarAho D
		LEFT JOIN AHODCtaPlaFij P
			ON D.ccodcuenta = P.ccodcuenta
		LEFT JOIN AHOMCuenta A
			ON A.cCodCuenta = P.cCodCuenta 
	GROUP BY D.cCodCuenta, P.nPlaOtorga, A.dFecApeCta, P.cCodTipSub

	UNION 

	SELECT C.cCodCuenta , 0.00 , (B.nMonCapita - B.nMonCapItg) + (B.nMonIntere - B.nMonIntItg),0.00,0,A.dFecApeCta,'',B.cCodTipSub
	FROM AHOMCuenta A
		INNER JOIN AHOMCuentaCts B
			ON A.ccodcuenta = B.ccodcuenta
		INNER JOIN #detCta C
			ON A.ccodcuenta = C.ccodcuenta
	WHERE C.cCodTipGar = 'NPCTS'

	--=====================================================================================================================================================
	-- CONSOLIDA PRENDAS DE CREDITOS PIGNORATICIOS 
	--=====================================================================================================================================================

	SELECT	cCodCliente	=	MAX(A.cCodCliente),
			cCodLotPre	=	MAX(C.cCodCtaKpr),
			nCanPiezas	=	SUM(C.nCanPieKpr),
			nPesGraNet	=	SUM(C.nPesGraNet),
			nPesGraBru	=	SUM(C.nPesGraBru),
			nPrecioTas	=	SUM(C.nPreTasKpr),
			nPreVenKpr	=	SUM(C.nPreVenKpr),
			cCodLinCre	=	MAX(C.cCodLinCre),
			nCodTipPre	=	MAX(C.nCodTipPre),
			C.cCodGarCli
	INTO #CURMDetPrenda
	FROM CMACHYOCLI..CLIMGarCliente A
		INNER JOIN GENMCreCli B
		 	ON B.cCodCliente	=	A.cCodCliente
		INNER JOIN KPRDDetPrenda C	-- EVALUAR SI SERÁ NECESARIO VALIDAR LOS ESTADOS DEL CRÉDITO
			ON C.cCodGarCli	=	A.cCodGarCli
			AND C.cCodCtaKpr	=	B.cCodCtaCre
	WHERE A.cCodCliente	=	@x_cCodCliente
	GROUP BY c.cCodGarCli

	--==========================================
	-- CONSOLIDA DATOS DE GARANTIAS
	--==========================================

	DECLARE @CurDatos TABLE(cCodCliente	CHAR(12),		cCodIndTipGar CHAR(1),		cCodGarCli	CHAR(3),		cCodTipGar	CHAR(5),		cDesGar		VARCHAR (150),	cCodTipMon	CHAR(1),
							nTipCamGar	NUMERIC(14,4),	nTipCamTas	NUMERIC(14,4),	nMonGarOri	NUMERIC(14,2),	nValMerGar	NUMERIC(14,2),	nMonGarDol	NUMERIC(14,2),	nMonGarCon	NUMERIC(14,2),
							nMonTasGar	NUMERIC(14,2),	nMonValEdi	NUMERIC(14,2),	nValNueGar	NUMERIC(14,2),	nMonValCont	NUMERIC(14,2),	nMonGraGar	NUMERIC(14,2),	ccodestgar	CHAR(1), 
							cCodUsuReg	CHAR(6),		cCodUsuMod	CHAR(6),		dFecRegGar	VARCHAR(10),	dFecModifi	VARCHAR(10),	cCodOfiMod	CHAR(3),		cCodOficin	CHAR(3),
							cDesEstGar	VARCHAR(50),	cDesTipGar	VARCHAR(150),	cCodGenGar	CHAR(4),		cCodTotGar	CHAR(6),		cDesCorta	VARCHAR(3),		cCodPais	CHAR(3),
							cCodDepart	CHAR(2),		cCodProvin	CHAR(2),		cCodDistri	CHAR(2),		cCodZona	CHAR(3),		cCodTipVia	CHAR(2),		cCodViaAcc	VARCHAR (4),	
							cDircliNum	VARCHAR(10),	cDirCliInt	VARCHAR (150),	cDirCliMz	VARCHAR(50),	cDircliLt	VARCHAR(50),	cDirCliSct	VARCHAR(50),	cDirCliDpt	VARCHAR(50) ,
							cdirCliBlk	VARCHAR(50),	cDirCliRef	VARCHAR (150),	cDirCliente VARCHAR (150),	cNroTelGar	VARCHAR (15),	cIndPref	CHAR(3),		nNumAñoFra	INT,
							cCodPlaca	VARCHAR(20),	cCodSumini	VARCHAR(20),	cCodCondVivi CHAR(2),		cCodUsoVivi CHAR(2),		nNumAnioCons INT,			cCodTipVeh	CHAR(2),
							cCodUsoVeh	CHAR(2),		lTipCtaGar	BIT,			cCodCuenta	CHAR(18),		nmonape		NUMERIC(14,2),	nmoncap		NUMERIC(14,2),	nPlaOtorga  VARCHAR(50),
							dFecIni		DATETIME,		dFecFin		DATETIME,		cCodCliEmi	CHAR(12),		cNomInsFin	VARCHAR(100),	dFecIniFia	DATETIME,		dFecFinFia	DATETIME,
							cIndReqDatAdi BIT,			lIndDatVeh	BIT,			lIndDatTerr BIT,			lIndDatHip  BIT,			cIndModGar CHAR(1),			nPorCobGar NUMERIC(14,2),
							cDesTipDoc	VARCHAR(200),	nMonTasGarSol DECIMAL(14,2),nMonGarOriCon DECIMAL(14,2),nValMerGarCon DECIMAL(14,2),nMonValEdiCon DECIMAL(14,2),nValNueGarCon DECIMAL(14,2),
							nMonValContCon NUMERIC(14,2),nCobPlaFij NUMERIC(14,2),	cDirCliUcv CHAR(6),			cDirCliZon CHAR(6),			cCodLotPre	VARCHAR(18),			nCanPiezas	int,
							nPesGraNet	DECIMAL(14,2),	nPesGraBru	decimal(14,2),	nPrecioTas	decimal(14,2)
						)

	INSERT @CurDatos						
	SELECT	A.cCodCliente, A.cCodIndTipGar, A.cCodGarCli, A.cCodTipGar, A.cdesgar, A.cCodTipMon,
			nTipCamGar = ISNULL(A.ntipcamgar,0.00),	
			nTipCamTas = ISNULL(A.nTipCamTas,0.00),	
			nMonGarOri = ISNULL(CASE WHEN ISNULL(E.cCodIndTipGar,'0') = '2' 
									THEN nmonape + nmoncap 
									ELSE CASE WHEN A.cCodTipMon = '1' THEN A.nMonGarOriSol ELSE A.nMonGarOri END 
								END,0.00),															
			nValMerGar = ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nValMerGarSol ELSE A.nValMerGar END,0.00), 
			nMonGarDol = ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nMonGarOriSol ELSE A.nMonGarDol END,0.00), 		 
			nMonGarCon = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN A.nMonGarOriSol ELSE A.nMonGarDol END,0.00), 
			nMonTasGar = ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nMonTasGarSol ELSE A.nMonTasGar END,0.00), 																
			nMonValEdi = ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nMonValEdiSol ELSE A.nMonValEdi END,0.00),
			nValNueGar = ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nValNueGarSol ELSE A.nMonValEdi END,0.00),
			nMonValCont= ISNULL(CASE WHEN A.cCodTipMon = '1' THEN A.nMonValConSol ELSE A.nMonValCon END,0.00), 		
			nMonGraGar = dbo.KPY_RetGraGar_FX(A.cCodCliente , A.cCodGarCli , A.cCodTipMon), 
			A.cCodEstGar, 
			cCodUsuReg = ISNULL(A.cCodUsuReg,''),
			cCodUsuMod = ISNULL(A.cCodUsuMod,''),
			dFecRegGar = CONVERT (VARCHAR(10),ISNULL(A.dFecRegGar,''),120),
			dFecModifi = CASE 
						  	WHEN CONVERT (VARCHAR(10),ISNULL(A.dFecModifi,'') ,120) = '1900-01-01'THEN '' 
							ELSE CONVERT (VARCHAR(10),ISNULL(A.dFecModifi,'') ,120) 
						  END,
			cCodOfiMod = ISNULL(A.cCodOfiMod,''),					
			cCodOficin = ISNULL(A.cCodOficin,'') ,
			I.cDesEstGar, E.cDesTipGar,
			cCodGenGar = E.ccodClaGar + E.cCodTipGar  ,
			cCodTotGar = E.ccodClaGar + E.cCodTipGar + E.ccodsubgar,
			F.cDesCorta,
			G.cCodPais, G.cCodDepart, G.cCodProvin,
			G.cCodDistri, G.cCodZona, 
			cCodTipVia	= ISNULL(G.cCodTipVia,''), 
			cCodViaAcc	= ISNULL(G.cCodViaAcc,''),
			cDircliNum	= ISNULL(G.cDircliNum,''), 
			cDirCliInt	= ISNULL(G.cDirCliInt,''), 
			cDirCliMz	= ISNULL(G.cDirCliMz,''), 
			cDircliLt	= ISNULL(G.cDircliLt,''),
			cDirCliSct	= ISNULL(G.cDirCliSct,''), 
			cDirCliDpt	= ISNULL(G.cDirCliDpt,''), 
			cdirCliBlk	= ISNULL(G.cdirCliBlk,''), 
			cDirCliRef	= ISNULL(G.cDirCliRef,''),
			cDirCliente = ISNULL(G.cDirCliente,''),
			cNroTelGar = ISNULL(G.cNroTelGar,''),
			cIndPref =	CASE 
							WHEN A.lIndPriPre = 1 THEN '1RA' 
							WHEN A.lIndSegPre = 1 THEN '2DA'
							ELSE 'NNN'
						END,						
			nNumAñoFra	 = ISNULL(B.nNumAnioFra,0) ,
			cCodPlaca	 = ISNULL(B.cCodPlaca,'')  ,
			cCodSumini	 = ISNULL(B.cCodSumini,'') ,				
			cCodCondVivi = ISNULL(B.cCodCondVivi,''),
			cCodUsoVivi  = ISNULL(B.cCodUsoVivi,''),
			nNumAnioCons = ISNULL(B.nNumAnioCons,''),
			cCodTipVeh	 = ISNULL(B.cCodTipVeh,''),
			cCodUsoVeh	 = ISNULL(B.cCodUsoVeh,''),			
			---	Titulo Valor										
			lTipCtaGar	= ISNULL(C.lTipCtaGar,0),
			cCodCuenta	= ISNULL(C.cCodCuenta,''),
			nmonape		= ISNULL(nmonape,0.00)  , 
			nmoncap		= ISNULL(nmoncap + nmonpag,0.00) ,			
			nPlaOtorga	= ISNULL('Plazo: ' + RTRIM(CAST(nPlaOtorga AS char(5))) + ' Días','')  ,
			DFECINI		= ISNULL(DFECINI,'') ,				
			DFECFIN		= ISNULL(DFECFIN,''),
			cCodCliEmi	= ISNULL(D.cCodCliEmi,''),
			cNomInsFin	= ISNULL(K.CNOMCLIENTE,''),
			dFecIniFia	= ISNULL(D.dFecIniFia,'') ,
			dFecFinFia	= ISNULL(D.dFecFinFia,'') ,			
			cIndReqDatAdi = ISNULL(E.lIndReqDatAdi,0),
			lIndDatVeh	= ISNULL(E.lIndDatVeh,0),
			lIndDatTerr = ISNULL(E.lIndDatTerr,0),
			lIndDatHip	= ISNULL(E.lIndDatHip,0),		
			cIndModGar	= 'M', 	
			------------Personales-----------
			nPorCobGar	= ISNULL(D.nPorCobGar,0.00),
			cDesTipDoc	= ISNULL(D.cDesTipDoc,'') , 
			---------------------------------
			nMonTasGarSol = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN A.nMonTasGarSol ELSE A.nMonTasGar END,0.00) ,		
			nMonGarOriCon = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN nMonGarOriSol ELSE nMonGarOri END,0.00) ,	
			nValMerGarCon = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN nValMerGarSol ELSE nValMerGar END,0.00) ,	
			nMonValEdiCon = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN nMonValEdiSol ELSE nMonValEdi END,0.00) ,  
			nValNueGarCon = ISNULL(CASE WHEN A.cCodTipMon = '2' THEN nValNueGarSol ELSE nMonValEdi END,0.00) ,  
			nMonValContCon= ISNULL(CASE WHEN A.cCodTipMon = '2' THEN A.nMonValConSol ELSE A.nMonValCon END,0.00),
			nCobPlaFij = CASE WHEN ISNULL(C.lTipCtaGar,0) = 1
							  THEN ROUND((ISNULL(nMonTasGar,0.00))* CASE WHEN A.cCodTipMon = '1' 
																	     THEN nTipCamTas
																		 ELSE 1
																	END * CASE WHEN J.cCodTipSub = '05' -- Plazo Fijo
																			   THEN 0.70
																			   ELSE 0.90																	
																		  END,2,2)
							  ELSE 0.00
						 END,
			cDirCliUcv = ISNULL(cDirCliUcv,''),
			cDirCliZon = ISNULL(cDirCliZon,''),
			cCodLotPre	=	cast(CASE WHEN PIG.cCodLotPre IS NULL THEN CAST(PRE.cCodLotPre AS VARCHAR(18)) ELSE PIG.cCodLotPre END as varchar(18)),
			nCanPiezas	=	CASE WHEN PIG.nCanPiezas IS NULL THEN PRE.nCanPiezas ELSE PIG.nCanPiezas END,
			nPesGraNet	=	CASE WHEN PIG.nPesGraNet IS NULL THEN PRE.nPesGraNet ELSE PIG.nPesGraNet END,
			nPesGraBru	=	CASE WHEN PIG.nPesGraBru IS NULL THEN PRE.nPesGraBru ELSE PIG.nPesGraBru END,
			nPrecioTas	=	CASE WHEN PIG.nPrecioTas IS NULL THEN PRE.nPrecioTas ELSE PIG.nPrecioTas END
	FROM CMACHYOCLI.DBO.CLIMGarCliente A  
		LEFT JOIN CMACHYOCLI.DBO.CliMGarFisHipCli B
			ON A.CCODCLIENTE = B.CCODCLIENTE 
				AND A.CCODGARCLI = B.CCODGARCLI
		LEFT JOIN CMACHYOCLI.DBO.CliMGarTitValCli C
			ON A.CCODCLIENTE = C.CCODCLIENTE 
				AND A.CCODGARCLI = C.CCODGARCLI
		LEFT JOIN CMACHYOCLI.DBO.CliMGarPerCli D	 
			ON A.CCODCLIENTE = D.CCODCLIENTE 
				AND A.CCODGARCLI = D.CCODGARCLI		
		LEFT JOIN GENDGarantia E  
			ON A.cCodTipGar = E.cCodGarant
				AND E.lconestado = 1
		LEFT JOIN KPYMLotPrenda PRE 
			ON	PRE.cCodGarCli	=	A.cCodGarCli
			AND PRE.cCodClient	=	@x_cCodCliente
			AND PRE.lExiCustod	=	1
		LEFT JOIN #CURMDetPrenda PIG
			ON	PIG.cCodGarCli	=	A.cCodGarCli
			AND PIG.cCodCliente	=	@x_cCodCliente	
		LEFT JOIN GENTMONEDA F
			ON A.CCODTIPMON = F.CCODTIPMON
		LEFT JOIN CMACHYOCLI..CLIDDirGarant G 
			ON A.ccodcliente = G.ccodcliente
			AND A.cCodGarCli = G.cCodGarCli
		LEFT JOIN SIPMPERSONAL H
			ON A.cCodUsuReg = H.CCODPERSON 
		LEFT JOIN CMACHYOCLI.DBO.CLITEstGarant I
			ON A.cCodEstGar = I.cCodEstGar
		LEFT JOIN #CurDatGarAut J
			ON C.cCodCuenta = J.cCodCuenta	
		LEFT JOIN  CMACHYOCLI..CLIMCLIENTES K
			ON K.CCODCLIENTE = D.cCodCliEmi
	WHERE	A.CCODCLIENTE = @x_cCodCliente 
			AND A.cCodEstGar = 'A'
	ORDER BY A.cCodGarCli

	SELECT DISTINCT * 
	FROM @CurDatos

	DROP TABLE #detCta
	DROP TABLE #DetKarAho
	DROP TABLE #CurDatGarAut
	DROP TABLE #CURMDetPrenda

END


