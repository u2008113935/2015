	
	/*
		requiero saber cuántos clientes de la ZONA CENTRO ORIENTE por agencia, 
		cuentan con endeudamiento como máximo hasta 10 mil.
	*/

	SET LANGUAGE spanish;
	--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-12-01'				
				)

	-- Select * into #tab01 from (

		Select 		
				/*
				ROW_NUMBER() 
				OVER(PARTITION BY O.cDesOficin	
						ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 						
				*/				
				Zona = ZON.cDesZona
				,CRE.cCodOficin
				,Oficina = O.cDesOficin										
				,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
				,CLI.cCodCliente AS 'CodigoCliente'						
				--Datos del credito			
				,CRE.cCodCtaCre AS 'CodigoCredito'				
				,CRE.cCodTipCre
				,STC.cDesTipCre AS 'TipoCredito'				  
				,STC.cDesSubTip AS 'SubTipoCredito'			 
				,CRE.cCodProduc
				,STC.cDesProCre AS 'ProductoCrediticio' 			 
				,CRE.cCodSubPro
				,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
				,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'				
				,TipoCambio = @nTipCambio				
				,nSaldoCapi = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
									THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
										* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoVig = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
									THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoVen = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
									THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END)
				,nSaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
										* CASE WHEN CRE.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
										AND CRE.cCodRefina = 'S'
									THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)		
				/*
				,SaldoCapitalenSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
					WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
					END								
				*/
				,TEM = CRE.nTasintCom									
				,EstadoCredito =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END				
				,FechaDesembolso	=	LEFT(CAST(CRE.dFecDesCre AS DATE),10)				
				--,CRE.cEstCreCon
				--,EC.cDescriEst AS 'EstadoCredito'													
			INTO #Tmp01							
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre				
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona					
				--condicion credito 
				LEFT JOIN [KPYTConCredit] D
					ON D.cCondicCon = CLI.cCondicCon		 				
										
			WHERE CRE.cEstCreCon in ('F','H')					
				AND ZON.nCodZona	=	'3'					
			--ORDER BY CRE.cCodOficin

			-- (33,284 row(s) affected)
			
			SELECT 
					Zona,cCodOficin,Oficina,CodigoCliente,--CodigoCredito,
					cCodTipCre,TipoCredito
					--SubTipoCredito,cCodProduc,ProductoCrediticio,cCodSubPro,SubProductoCrediticio
					--nSaldoCapi	nSaldoVig	nSaldoVen	nSaldoJud	nSaldoRef				
				INTO #Tmp02
			FROM #Tmp01
			WHERE nSaldoCapi	>	0
				AND nSaldoCapi  <=	10000
			--ORDER BY cCodOficin
			-- (33,154 row(s) affected)

			SELECT  CantCliente	=	COUNT(DISTINCT (CodigoCliente))
			FROM #Tmp02

			SELECT  Zona,
					Oficina		=	cCodOficin + ' - ' + Oficina,
					--cCodTipCre,
					TipoCredito, 
					CantCliente	=	COUNT(DISTINCT (CodigoCliente))
			FROM #Tmp02
			GROUP BY Zona,cCodOficin,Oficina, cCodTipCre,TipoCredito
			ORDER BY cCodOficin, cCodTipCre


			DROP TABLE #Tmp01
			DROP TABLE #Tmp02

	/*				
		SELECT * FROM Gentofizonas
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
		SELECT * FROM GentZonas

		
				(CASE 
						WHEN CRE.cCodTipMon = '2' THEN CRE.nMonSalNor * @nTipCambio
						ELSE CRE.nMonSalNor
					 END)			  			 <= 10000
				AND CRE.nMonSalNor				 > 0		
	*/