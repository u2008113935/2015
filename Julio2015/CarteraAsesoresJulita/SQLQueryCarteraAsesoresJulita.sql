	/*
	Solicitar Data de composición de cartera de los asesores de negocios a nivel institucional, 
	con los siguientes campos al cierre de junio.
		* zona
		* agencia
		* asesor
		* categoría
		* tipo de crédito
		* subproducto
		* saldo de colocaciones en microempresa
		* saldo de colocaciones en pequeña empresa
		* saldo de colocaciones en consumo
		* saldo de colocaciones en mediana empresa
		* saldo de colocaciones en hipotecarios
		* Numero de clientes en microempresa
		* Numero de clientes en pequeña empresa
		* Numero de clientes en  consumo
		* Numero de clientes en  mediana empresa
		* Numero de clientes en  hipotecarios
		* saldo vencido en microempresa
		* saldo vencido en pequeña empresa
		* saldo vencido en  mediana empresa
		* saldo vencido en consumo
		* saldo vencido en hipotecarios.
		* tasa activa ponderada promedio en microempresa
		* tasa activa ponderada promedio en pequeña empresa
		* tasa activa ponderada promedio en mediana empresa
		* tasa activa ponderada promedio en consumo
		* tasa activa ponderada promedio en hipotecario
	*/

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

			-----------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------
			DECLARE @nTipCambio MONEY, @dFecTipCam DATE
			SET @dFecTipCam = GETDATE()
			SELECT @nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE dFecTipCam = @dFecTipCam	
			Select @nTipCambio

			/*
			Select nTipCamFij,*
			FROM GENTTipCambio
			WHERE dFecTipCam
			3.1570
			3.1770
			*/

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
			--INTO #KPYMCreConven
			FROM KPYMCREconven
			WHERE CESTCRECON IN ('F','H')
				AND cCodOficin = '002'	--CASE WHEN @cCodOficin = '000' 
										--THEN cCodOficin ELSE @cCodOficin END
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
				AND cCodOficin = '002'	--CASE WHEN @cCodOficin = '000' 
										--THEN cCodOficin ELSE @cCodOficin END
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

		Select 		
			 O.cCodOficin, O.cDesOficin			
			,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 		
			--Datos del credito
			,CRE.cCodCtaCre AS 'CodigoCredito'	
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre			
	
			--Datos del Cliente	
			--,CLI.cCodCliente AS 'CodigoCliente'	
			--,CLIM.cNomCliente AS 'NombreCliente'																			
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'

			--,SOLI.cCodUsuAna AS 'CodAnalistaOrigen'
			--,SP1.cNomPerson AS 'NombreAnalistaOrigen'--NOMBRE ANALISTA 			
			,ZON.nCodZona, ZON.cDesZona	
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_201505.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna			
			/*
			--ANALISTA ORIGEN
			 INNER JOIN [kpymsolicitud] SOLI	
				ON SOLI.cCodSolCre = CRE.cCodSolCre
			 Inner JOIN [sipmpersonal] SP1 
					ON SP1.cCodPerson = SOLI.cCodUsuAna
			*/
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon

		WHERE --CRE.cCodUsuAna IN ('WCASTA','DPAZAR')	
				--SOLI.cCodUsuAna in ('WCASTA','DPAZAR')
				CRE.cCodOficin = '043'
				and CRE.cEstCreCon in ('F','H','I')					
		ORDER BY cEstCreCon 			
			 --) as tmp99

