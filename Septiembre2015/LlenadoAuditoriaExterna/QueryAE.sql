
	/*
		El listado de deudores de la cartera con excepciones, conteniendo 
		tipo de crédito, Número de cuotas, calificación (Inicial, SBS-externa, final-alineada)
		, provisión, días de atraso	, Número de cuotas pagadas, Número de cuota a pagar
		, saldo capital (convertido a soles), saldo vigente, saldo vencido
		, saldo refinanciado, saldo judicial, estado contable del crédito
		, condición del crédito
		
			, tipo de garantías
			, monto que cobertura la garantía y valor de realización de la garantía
			, nº de excepciones, tipo de excepción. Reportes se solicitan al 30.SET.2015

	*/

	/*
		Select * from ExcepAgo15
	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-09-01'				
				)

	select * into #tab01 from (
			Select 		
				/*
					ROW_NUMBER() 
					OVER(PARTITION BY CRE.cCodUsuAna
							ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
				*/
				/*
					,CRE.cCodUsuAna AS 'CodAsesorActual'
					,SP.cNomPerson AS 'NombreAsesorActual'	
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
					,DireccionReferencia = DC.cDirCliRef
					,Zona = cNomZona
					,DIS1.cNomDistri as 'Distrito'		 					 			
					,PRO1.cNomProvin AS 'Provincia' 			
					,DEP1.cNomDepart AS 'Departamento'	
				*/
					--Datos del credito			
					CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre			
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
					,NumeroCuotas= CRE.nNumCuoApr
					-- ,CalificSBS =   -- (Inicial, SBS-externa, final-alineada)
					,CalifRCC = isnull(B.CCLAFIN,'0')
					,CalifRCCDet =
						Case  B.CCLAFIN
						When '0' then 'NORMAL'
						When '1' then 'CPP'
						When '2' then 'DEFICIENTE'
						When '3' then 'DUDOSO'
						When '4' then 'PERDIDA'
						ELSE '0' END
					-- ,Provision = 
					,DiasAtraso = CRE.nDiaAtrCre
					--,Número de cuotas pagadas, Número de cuota a pagar
					,CRE.nMonCapDes as 'MontoDesembolso' 
					--,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,TipoCambio = @nTipCambio
					,MontoDesembolsoenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
						END					
					/*
					,SaldoCapitalenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
						END								
					*/
					-- ,TEM=CRE.nTasintCom	
					,SaldoCapital = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
											THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
													* CASE WHEN CRE.cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
											ELSE 0 END)
					,SaldoVigente = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
											THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
											ELSE 0 END)
					,SaldoVencido = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
											THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
												ELSE 0 END)
					,SaldoJudicial = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2'
											THEN @nTipCambio ELSE 1 END
											ELSE 0 END)
					,SaldoRefinan = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 AND CRE.cCodRefina = 'S'
											THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
											ELSE 0 END)
					--,cCodModCre = 'KPY'						
					,EstadoContableCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END		
					 ,CRE.cEstCreCon
					,EC.cDescriEst AS 'CondicionCredito'								
					/*						 
						,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
						,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
						,NombreMes =DATENAME(month, CRE.DFECDESCRE)				
						,Oficina = O.cDesOficin										
						,Zona = ZON.cDesZona											
					*/
			FROM [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
						ON CLIM.cCodCliente = CLI.cCodCliente
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[KPYTSUBTIPCRE] STC
						ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
						AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.KPYTEstCreCon EC 
						ON EC.cEstCreCon = CRE.cEstCreCon
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GENTOficinas] O 
						ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[Gentofizonas] GOZ
						ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GentZonas] ZON
						ON ZON.nCodZona = GOZ.nCodZona	
					inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[sipmpersonal] SP 
						ON SP.cCodPerson = CRE.cCodUsuAna	
					--condicion credito 
					 INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon			 

					left join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
						on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'
			
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GenTDepartame] DEP1
						ON DEP1.cCodDepart = DC.cCodDepart
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GentProvincia] PRO1
						ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[GentDistrito] DIS1
						ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
							and dis1.cCodDepart = DC.cCodDepart					
			
					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.GENTZona Z
						ON Z.cCodZona = DC.cCodZona 
							and Z.cCodDepart = DC.cCodDepart
							and Z.cCodProvin = DC.cCodProvin
							and Z.cCodDistri = DC.cCodDistri						 			
					inner join [HYO00402].CRICMACHYO_DIARIO.dbo.urirccmae B			
								on B.cCodSbs = CLIM.CCODSBS
											
					inner join ExcepAgo15 EX -- (1446 row(s) affected)
						on EX.CodigoCredito COLLATE SQL_Latin1_General_CP1_CI_AS = CRE.cCodCtaCre

				WHERE -- CRE.cEstCreCon in ('F','H')					
					 -- and CRE.cCodOficin = '058'	
					CRE.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	
						in (Select rtrim(CodigoCredito) from ExcepAgo15)
						) as tmp

		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)	

		/*
			Select * from #tab01

		*/

		-- 02 Cuotas Pendientes
		ALTER TABLE #tab01
		Add CuotaPag INT , CuotaPend INT
			--Drop column CuotaPag, CuotaPend
		------------------------CURSOR-----------------------------------
		Declare @codlincre1 varchar(18), @CuotaPag INT, @CuotaPend INT, @CuotasAprob int 		
			
			Declare cNose CURSOR FOR	
				Select distinct CodigoCredito from #tab01 (NOLOCK) 	

			OPEN cNose
				FETCH cNose into @codlincre1
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @CuotasAprob = (select NumeroCuotas from #tab01 
									where CodigoCredito=@codlincre1)
				set @CuotaPag = 
						(select top 1 count(distinct cNumCuoPla) 							
							from [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[KPYDPLANPAGCRE] 
							where cCodCtaCre = @codlincre1 
								and cCodEstCuo = 'P'
								AND cCodPlaPag in 
								(select top 1 max(cCodPlaPag) 
							  	 from [HYO00409\HISTORICO].SOFCMACHYO_201508.DBO.[KPYDPLANPAGCRE] 
								 WHERE cCodCtaCre = @codlincre1 
												and cCodEstCuo = 'P'))

				Set @CuotaPend = (@CuotasAprob - @CuotaPag )					
				
				UPDATE #tab01
				SET CuotaPag = @CuotaPag
				WHERE CodigoCredito = @codlincre1	
				
				UPDATE #tab01
				SET CuotaPend = @CuotaPend
				WHERE CodigoCredito = @codlincre1																				
				
				FETCH cNose INTO @codlincre1
				END
				CLOSE cNose
				DEALLOCATE cNose
		-------------------------------------------------------------------

		Select * from #tab01
		where CuotaPag is not null or CuotaPend is not null
