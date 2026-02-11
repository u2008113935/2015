/* 
Se solicita información al cierre del mes de mayo del 2015, 
por tramos de la cartera vencida en saldo y cuentas así como clientes;
Por agencia( Chosica, Huaycan, Huachipa, Ate, Santa Anita, Abancay, Cto. Grande 
,San Juan de Lurigancho, Cañete, ica, Chincha, Wanchaq, Cerro Colorado, San Sebastian
,Parcona_Ica, Manchay.
*/

		/*
		select --top 5 
				--*
				cCodOficin, cEstCreCon --,cCodCastig
				, case cCodTipMon
					 when '1' then sum(nMonCapDes - nMonCapPag)
					 when '2' then sum(nMonCapDes - nMonCapPag) * 3.147
					 end AS 'Saldo'		
		from [HYO00409\HISTORICO].SOFCMACHYO_201505.DBO.[KPYMCRECONVEN]
		where cEstCreCon = 'I'
				and cCodOficin = '016'
				--and cCodCastig = 'S'
		gROUP BY cCodOficin, cEstCreCon, cCodTipMon --, cCodCastig
		*/

------------------------------------------------------------------------------		

	/* ************************************************************************************************

	* Copyright © 2014 CMAC Huancayo -. All rights reserved 
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

			DECLARE @cCodOficin CHAR(3), @cUsuWin VARCHAR(50)
			SET @cUsuWin = 'gpenag'
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
			----------VARIABLES-------------------
			DECLARE @nTipCambio MONEY			
						-- select * from GENTTipCambio
			 Set @nTipCambio = (SELECT nTipCamFij
								FROM GENTTipCambio
								WHERE dFecTipCam = '2015-06-01') --@dFecTipCam	
				--select @nTipCambio

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
			FROM [KPYMCREconven] 
				--INNER JOIN [GENTOficinas] O 
				--	ON O.cCodOficin = A.cCodOficin AND O.lConEstado = '1' 
				--INNER JOIN [Gentofizonas] GOZ
				--	ON GOZ.cCodOficin = O.cCodOficin AND GOZ.lEstZonOfi = '1'
				--INNER JOIN [GentZonas] ZON
				--	ON ZON.nCodZona = GOZ.nCodZona		
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

				-- select * from #KPYMCreConven order by cCodOficin

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(nSaldoCapi),nSaldoVig = SUM(nSaldoVig),
				nSaldoVen = SUM(nSaldoVen), nSaldoJud = SUM(nSaldoJud), nSaldoRef = SUM(nSaldoRef)
			INTO #TMPFINAL
			FROM #KPYMCreConven
			GROUP BY cCodOficin, cCodTipMon

				-- select * from #TMPFINAL order by cCodOficin

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


		SELECT * FROM GENTZonCom C



