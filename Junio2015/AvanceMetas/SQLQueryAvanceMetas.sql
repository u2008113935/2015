--EXEC Kpy_SalOfiMonSit_SP @cUsuWin

--sp_helptext Kpy_SalOfiMonSit_SP

---
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
* Sintaxis de ejemplo:
*	EXEC Kpy_SalOfiMonSit_SP 'cmachyo\UMASTERSQL'
**************************************************************************************************/ 
	/*
		CREATE PROCEDURE [dbo].[Kpy_SalOfiMonSit_SP]
			@cUsuWin VARCHAR(50) = ''
		AS
		BEGIN
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


			SELECT @nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE dFecTipCam = @dFecTipCam	

			-- DATOS DE CREDITOS CONVENCIONALES

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(CASE WHEN cEstCreCon IN ('F', 'H')
									THEN (nMonCapDes - nMonCapPag) * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = SUM(CASE WHEN cEstCreCon = 'F' AND cCodRefina = 'N'
									THEN nMonSalNor * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN cEstCreCon = 'F' and nMonSalVen > 0
									THEN nMonSalVen * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
										ELSE 0 END),
					nSaldoJud = SUM(CASE WHEN cEstCreCon = 'H' THEN nMonSalVen * CASE WHEN cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = SUM(CASE WHEN cEstCreCon = 'F' AND nMonSalNor > 0 AND cCodRefina = 'S'
									THEN nMonSalNor	* CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
				INTO #KPYMCreConven
			FROM KPYMCREconven
			WHERE CESTCRECON IN ('F','H')
				AND cCodOficin = CASE WHEN @cCodOficin = '000' 
									THEN cCodOficin ELSE @cCodOficin END
			GROUP BY cCodOficin, cCodTipMon

			UNION ALL

			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT cCodOficin, cCodTipMon,
					nSaldoCapi = SUM(nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = SUM(CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
			FROM	KPRMCrePrenda
			WHERE	cCodEstKpr IN ('A','D','G','H','R')
				AND cCodOficin = CASE WHEN @cCodOficin = '000' 
									THEN cCodOficin ELSE @cCodOficin END
			GROUP BY cCodOficin, cCodTipMon

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(nSaldoCapi),nSaldoVig = SUM(nSaldoVig),
				nSaldoVen = SUM(nSaldoVen), nSaldoJud = SUM(nSaldoJud), nSaldoRef = SUM(nSaldoRef)
			  INTO #TMPFINAL
			FROM #KPYMCreConven
			GROUP BY cCodOficin, cCodTipMon

			SELECT C.cNomZonCom, Oficina = B.cCodOficin +	' - ' + B.cDesOficin, A.cCodTipMon, D.cDesTipMon,
				A.nSaldoVig, A.nSaldoVen, A.nSaldoJud, A.nSaldoRef, A.nSaldoCapi
			FROM #TMPFINAL A
				INNER JOIN GENTOficinas B
					ON A.cCodOficin = B.cCodOficin
				INNER JOIN GENTZonCom C
					ON B.cCodZonCom = C.cCodZonCom
				INNER JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon
			ORDER BY A.cCodOficin, A.cCodTipMon

			DROP TABLE #KPYMCreConven
			DROP TABLE #TMPFINAL
		END
		*/

---------------------------------------------------------------------------------------------------
	DECLARE @nTipCambio MONEY, @dFecTipCam DATE, @dFecProces DATE, @Cont INT
			,@cCodOficin CHAR(3), @cUsuWin VARCHAR(50)
		--set @cUsuWin = 'gpenag'

		--	SET @cCodOficin = CASE WHEN @cUsuWin = '' THEN '000' ELSE @cCodOficin END
		--	SET @Cont = CHARINDEX('_',DB_NAME())

		--	IF @Cont > 0
		--	BEGIN
		--		SELECT @dFecTipCam = DATEADD(MONTH, 1, CAST(RIGHT(DB_NAME(), 6) + '01' AS DATE))
		--		SET @dFecProces = DATEADD(DAY, -1, @dFecTipCam)
		--	END
		--	ELSE
		--	BEGIN
		--		SET @dFecTipCam = GETDATE()
		--		SET @dFecProces = GETDATE()
		--	END
		--select  convert (date,GETDATE())

		SELECT @nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE dFecTipCam = convert (date,GETDATE()) --@dFecTipCam	

			-- Select @nTipCambio
			-- DATOS DE CREDITOS CONVENCIONALES

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(CASE WHEN cEstCreCon IN ('F', 'H')
									THEN (nMonCapDes - nMonCapPag) * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = SUM(CASE WHEN cEstCreCon = 'F' AND cCodRefina = 'N'
									THEN nMonSalNor * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN cEstCreCon = 'F' and nMonSalVen > 0
									THEN nMonSalVen * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
										ELSE 0 END),
					nSaldoJud = SUM(CASE WHEN cEstCreCon = 'H' THEN nMonSalVen * CASE WHEN cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = SUM(CASE WHEN cEstCreCon = 'F' AND nMonSalNor > 0 AND cCodRefina = 'S'
									THEN nMonSalNor	* CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
				INTO #KPYMCreConven
			FROM KPYMCREconven
			WHERE CESTCRECON IN ('F','H')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--				THEN cCodOficin ELSE @cCodOficin END
			GROUP BY cCodOficin, cCodTipMon

			UNION ALL

			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT cCodOficin, cCodTipMon,
					nSaldoCapi = SUM(nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = SUM(CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
			FROM	KPRMCrePrenda
			WHERE	cCodEstKpr IN ('A','D','G','H','R')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--					THEN cCodOficin ELSE @cCodOficin END
			GROUP BY cCodOficin, cCodTipMon

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(nSaldoCapi),nSaldoVig = SUM(nSaldoVig),
				nSaldoVen = SUM(nSaldoVen), nSaldoJud = SUM(nSaldoJud), nSaldoRef = SUM(nSaldoRef)
			  INTO #TMPFINAL
			FROM #KPYMCreConven
			GROUP BY cCodOficin, cCodTipMon

			SELECT C.cNomZonCom, Oficina = B.cCodOficin +	' - ' + B.cDesOficin, A.cCodTipMon, D.cDesTipMon,
				A.nSaldoVig, A.nSaldoVen, A.nSaldoJud, A.nSaldoRef, A.nSaldoCapi
			FROM #TMPFINAL A
				INNER JOIN GENTOficinas B
					ON A.cCodOficin = B.cCodOficin
				INNER JOIN GENTZonCom C
					ON B.cCodZonCom = C.cCodZonCom
				INNER JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon	
			ORDER BY A.cCodOficin , A.cCodTipMon
		



