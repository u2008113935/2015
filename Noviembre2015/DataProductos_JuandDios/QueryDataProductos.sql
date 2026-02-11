

		/*
			BUENAS TARDES, 
			SOLICITO LA DATA DE LOS PRODUCTOS:
				1. CREDIVIP EMPRESA.
				2. CREDICASA HABITACIONAL Y COMERCIAL.
				CON LOS SIGUIENTES CAMPOS:
				- SALDO DE CAPITAL
				- TEA
				- AGENCIA
				- PLAZO
				- FECHA DE DESEMBOLSO
				- FECHA DE CANCELACIÓN
				-  ZONA
				- ASESOR
				- TIPO DE CRÉDITO
				- SUB PRODUCTO
				- MONEDA
				- CALIFICACIÓN
				- ESTADO
				DESDE EL AÑO 2010 A LA FECHA.
		*/


	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01'				
				)
	-- Select @nTipCambio

	Select * into #tab01 from (

		Select 						
				/*
				ROW_NUMBER() 
				OVER(PARTITION BY CRE.cCodOficin
						ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 
				*/
				Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)											
				,CLIM.cCodSbs
				,CLI.cCodCliente AS 'CodigoCliente'		
				,CLIM.cNomCliente AS 'NombreCliente'				
				--Datos del credito			
				,CRE.cCodCtaCre AS 'CodigoCredito'				
				,STC.cDesTipCre AS 'TipoCredito'
				,STC.cDesSubTip AS 'SubTipoCredito'			 
				,STC.cDesProCre AS 'ProductoCrediticio' 			 
				,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
				,CRE.nMonCapDes as 'MontoDesembolso' 
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'	
				,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
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
				,SaldoCapitalenSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
					WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
					END	
				,left(cast(CRE.dFecCulCre as date),10) as 'FechaCancelacion'							
				,TEM=CRE.nTasintCom					
				
				,PlazoCuotaEnDias = CRE.nNumDiaApr
				,CuotasAprobadas = CRE.nNumCuoApr
				,DiasGracia = CRE.nNumDiaGra
				,PlazoTotalEnDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
				
				,EstadoCredito =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END
				,DiasdeMora = CRE.nDiaAtrCre 														 								
				--,CRE.cEstCreCon
				--,EC.cDescriEst AS 'EstadoCredito'									
				,CRE.cCodUsuAna AS 'CodAsesorActual'
				,SP.cNomPerson AS 'NombreAsesorActual'					
				,Oficina = O.cDesOficin										
				,Zona = ZON.cDesZona
										
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
				left JOIN KPYTEstCreCon EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				inner JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna	
				--condicion credito 
				left JOIN [KPYTConCredit] D
					ON D.cCondicCon = CLI.cCondicCon			 					
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre					
													
			WHERE CRE.cEstCreCon in ('F','H','I','G')									
				and left(cast(CRE.dFecDesCre as date),10) >= '2010-01-01'
				and (STC.cDesSubCre like '%credivip%' or STC.cDesSubCre Like '%credicasa%habi%comer%')
				

			) as tmp


			-- Select * from #tab01
				-- (58,069 row(s) affected)

			Update #tab01
			Set FechaCancelacion = ''
			where FechaCancelacion is NULL	


	--02

	
		Select * into #sbs01 from (
				Select A.CCODSBS, A.CAPEPAT, A.CAPEMAT, A.CAPECAS,A.CPRINOM,A.CSEGNOM,A.CNUDOCI, A.NCANENT
					,A.NPORCAL0, A.NPORCAL1, A.NPORCAL2, A.NPORCAL3, A.NPORCAL4, A.CCLAFIN
					,B.CCODEMP, B.CTIPCRE, B.CCTACON, B.NSALDOS, B.CCALEMP				
					,C.cCodIFI, C.cNomIFI
				From [HYO00402].CRICMACHYO_DIARIO.dbo.urirccmae A	
					INNER JOIN [HYO00402].CRICMACHYO_DIARIO.dbo.urirccsal B	
						ON A.CCODSBS = B.CCODSBS
					inner join [HYO00402].CRICMACHYO_DIARIO.dbo.URIRCCMIFI C	
						on C.cCodIFI = B.cCodEmp and C.lConEstado = 1	
				Where LEFT(B.Cctacon, 4) 
						in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')					
					and A.CCODSBS 
						in (Select distinct(cCodSbs) from #tab01 )	
					
				--Order by A.CCODSBS
				) as tmp

			CREATE NONCLUSTERED INDEX #sbs01_CCODSBS_IXN ON #sbs01(CCODSBS)

			-- Select * from #sbs01 order by CCODSBS

			--  DROP TABLE #sbs02
			Select * into #sbs02 from (Select top 1 * from #sbs01) as tmp
			Delete from #sbs02			
			-- Select * from #sbs02

	--03 INSERTANDO UN SOLO CREDITO
	------------------------CURSOR SOLO UN CREDITO -----------------------------------
		Declare @CCODSBS char(10)			  		
			
			Declare cCursor01 CURSOR FOR	
			
			Select distinct CCODSBS from #sbs01 (NOLOCK) 					

			OPEN cCursor01
			FETCH cCursor01 into @CCODSBS
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #sbs02
				
				Select top 1 					
					*
				from #sbs01
				where CCODSBS = @CCODSBS																			
				
			FETCH cCursor01 INTO @CCODSBS
			END
			CLOSE cCursor01
			DEALLOCATE cCursor01

		-----------------------------------------------------------------------------
			
		CREATE NONCLUSTERED INDEX #sbs02_CCODSBS_IXN ON #sbs02(CCODSBS)

		-- Select * from #sbs02 order by CCODSBS


		/*
				Select * from #sbs02
				Order By CCODSBS

				Select CCODSBS,count(CCODSBS) from #sbs02
				Group By CCODSBS
				Having count(CCODSBS) > 1
				Order By CCODSBS
		*/

			--  drop table #tab02
			SELECT * into #tab02 from (
					Select 
						A.* 
						,CantEnt = isnull(B.NCANENT,0)
						, CalifSBS = 
							Case B.CCLAFIN
							when '0' then 'NORMAL'
							when '1' then 'CPP'
							when '2' then 'DEFICIENTE'
							when '3' then 'DUDOSO'
							when '4' then 'PERDIDA'
							ELSE 'NO REGISTRA' END							
					From #tab01 A
						left join #sbs02 B
							on A.cCodSBS = B.cCodSBS
					--Order By CodigoCliente
						) as tmp

					-- (58,069 row(s) affected)
		/*
			Select * from #tab02
			Order By Secuencia 
		*/

			Drop table #tab01
			Drop table #tab02
			Drop table #sbs01
			Drop table #sbs02

			Select * from #tab02
			Order BY Anio,Mes


			/*

			1. CREDIVIP EMPRESA.
			2. CREDICASA HABITACIONAL Y COMERCIAL.


			Select *
			FRom [KPYTSUBTIPCRE] STC
			Where STC.lEstado = '1'
				and cDesSubCre like '%credicasa%habi%comer%'
			*/