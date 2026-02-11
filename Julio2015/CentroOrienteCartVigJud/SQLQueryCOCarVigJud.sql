
	--sp_helptext Kpy_SalOfiMonSit_SP

	
/* ************************************************************************************************

* Objetivo: SALDOS DE CREDITOS POR OFICINA, SITUACION Y MONEDA
* Escrito por:          CHACHI GAGO Roberto      
* Email/Movil/Phone:    rchachi@cajahuancayo.com.pe      
* Fecha creación: 2014/05/02
* Sistema / Modulo:            CREDITOS /
* Modificaciones:
*	Fecha			Responsable		Descripción del cambio
*	2014.09.29		ASALAZAR		ADICIONO AREA DE CONTRATOS
*	2014.10.01		ASALAZAR		ADICIONO AREA DE GERENCIA
*	2015.03.18		RCHACHI			Se agregaron los campos Nro.Cliente y Nro.Cuentas

* Sintaxis de ejemplo:
	EXEC Kpy_SalOfiMonSit_SP 'cmachyo\rchachi'

**************************************************************************************************/ 
		/*
		CREATE PROCEDURE [dbo].[Kpy_SalOfiMonSit_SP]
			@cUsuWin VARCHAR(50) = ''
		AS
		BEGIN
			SET NOCOUNT ON

			DECLARE @nTipCambio MONEY,
					@dFecTipCam DATE,
					@dFecProces DATE,
					@Cont INT,
					@cCodOficin CHAR(3)

			SELECT @cCodOficin = CASE WHEN B.cCodAreaCmac IN ('DTI','SGN','ACT','GER') 
									THEN '000' ELSE B.cCodOficin END
			FROM ADMMUSUARIO A
				INNER JOIN SIPMPERSONAL B
					ON A.CCODUSUADM = B.CCODPERSON
			WHERE 'CMACHYO\' + CCODUSUWIN = @cUsuWin
				AND B.cCodEstPer = 'A'
		
			SET @cCodOficin = CASE WHEN @cUsuWin = '' THEN '000' ELSE @cCodOficin END
	
			SET @Cont = CHARINDEX('_',DB_NAME())
	
			IF @Cont > 0
			BEGIN
				SELECT @dFecTipCam = DATEADD(MONTH, 1, CAST(RIGHT(DB_NAME(), 6) + '01' AS DATE))
				SET @dFecProces = DATEADD(DAY, -1, @dFecTipCam)
			END
			ELSE
			BEGIN
				SET @dFecTipCam = GETDATE()
				SET @dFecProces = GETDATE()
			END
			*/
			DECLARE @nTipCambio MONEY,
					@dFecTipCam DATE
			SET @dFecTipCam = GETDATE()
			SELECT @nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE dFecTipCam = @dFecTipCam	
			SELECT @nTipCambio

			-- DATOS DE CREDITOS CONVENCIONALES
			SELECT cCodOficin, A.cCodCtaCre, B.cCodCliente, cCodTipMon, 
					nSaldoCapi = (CASE WHEN cEstCreCon IN ('F', 'H')
									THEN (nMonCapDes - nMonCapPag) * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = (CASE WHEN cEstCreCon = 'F' AND cCodRefina = 'N'
									THEN nMonSalNor * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = (CASE WHEN cEstCreCon = 'F' and nMonSalVen > 0
									THEN nMonSalVen * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
										ELSE 0 END),
					nSaldoJud = (CASE WHEN cEstCreCon = 'H' THEN nMonSalVen * CASE WHEN cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = (CASE WHEN cEstCreCon = 'F' AND nMonSalNor > 0 AND cCodRefina = 'S'
									THEN nMonSalNor	* CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
			INTO #KPYMCreConven
			FROM KPYMCREconven A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaCre = B.cCodCtaCre
			WHERE CESTCRECON IN ('F','H')
				AND cCodOficin in ()	
									/*
									CASE WHEN @cCodOficin = '000' 
									THEN cCodOficin ELSE @cCodOficin END
									*/

			UNION ALL

			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT cCodOficin, A.cCodCtaKpr, B.cCodCliente, cCodTipMon,
					nSaldoCapi = (nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = (CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = (CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
			FROM	KPRMCrePrenda A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre
			WHERE	cCodEstKpr IN ('A','D','G','H','R')
				AND cCodOficin = CASE WHEN @cCodOficin = '000' 
									THEN cCodOficin ELSE @cCodOficin END
							
			CREATE CLUSTERED INDEX KPYMCreConven_cCodOficin_cCodTipMon ON #KPYMCreConven(cCodOficin, cCodTipMon)

			SELECT B.cCodZonCom, A.cCodOficin, cCodTipMon, nSaldoCapi = SUM(nSaldoCapi),nSaldoVig = SUM(nSaldoVig),
				nSaldoVen = SUM(nSaldoVen), nSaldoJud = SUM(nSaldoJud), nSaldoRef = SUM(nSaldoRef),
				nNumCli = COUNT(DISTINCT(cCodCliente)), nNumCta = COUNT(DISTINCT(cCodCtaCre))
			INTO #TMPFINAL
			FROM #KPYMCreConven A
				INNER JOIN GENTOficinas B
					ON A.cCodOficin = B.cCodOficin
			WHERE A.nSaldoCapi > 0
			GROUP BY GROUPING SETS((B.cCodZonCom, A.cCodOficin, cCodTipMon),
									(B.cCodZonCom, A.cCodOficin),
									(B.cCodZonCom, A.cCodTipMon),
									(B.cCodZonCom),
									(A.cCodTipMon),
									())
							
			SELECT cNomZonCom = ISNULL(C.cNomZonCom, 'INTITUCIONAL'), Oficina = ISNULL(B.cCodOficin +	' - ' + B.cDesOficin, 'CONSOLIDADO'),
				cCodTipMon = ISNULL(A.cCodTipMon, '3'), cDesTipMon = ISNULL(D.cDesTipMon, 'CONSOLIDADO'),
				A.nSaldoVig, A.nSaldoVen, A.nSaldoJud, A.nSaldoRef, A.nSaldoCapi, A.nNumCli, A.nNumCta
			FROM #TMPFINAL A
				LEFT JOIN GENTOficinas B
					ON A.cCodOficin = B.cCodOficin
				LEFT JOIN GENTZonCom C
					ON A.cCodZonCom = C.cCodZonCom
				LEFT JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon
			ORDER BY A.cCodOficin, A.cCodTipMon
	
			DROP TABLE #KPYMCreConven
			DROP TABLE #TMPFINAL

		END


