	
	/*
	
	Data de clientes que se dediquen al sector transporte con los siguientes datos:

	Apellidos y Nombres,Dirección,Zona,Distrito,Provincia,Teléfono
	,Ultimo Crédito Desembolsado
	,Tipo de Crédito, Producto,Sub Producto
		,Calificación,Número de Entidades
	,Agencia,Asesor

		Todos los clientes deben de considerar las siguientes variables:
		-	Clientes con calificación normal los últimos 3 meses
		-	Endeudamiento máximo en tres instituciones incluyendo la Caja.
		-	Días de atraso máximo 6 en promedio.
			-	(Para el caso de crédito empresariales con un patrimonio mayor a 30,000 Nuevos Soles)

	*/

	--01
	
	/*
	
	Drop table #tab01
	Drop table #tab02
	Drop table #tab03
	Drop table #tab04

	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01')	
	
	-- Drop table #tab01
	Select * into #tab01 from (
			Select

					ROW_NUMBER() 
					OVER(PARTITION BY year(CRE.DFECDESCRE)
							ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE),NombreMes =DATENAME(month, CRE.DFECDESCRE)
					--Datos del Cliente			
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,CLIM.cCodSbs 				                      
					--,SectorEconomico = isnull(SE.cDesSecEco,'No Registra')
					
					,CodigoCIIUSolicitante = S.cCodCIIUSol, CI1.ccodciiu 					
					,ActividadEconomica =  CI1.cdesactivi
					,CI2.ccodciudet ,GiroNegocio = ISNULL(CI2.cdesactivi,'SIN REGISTRO')					

					,CondicionDomicilio = CD.cDesConDom
					,DireccionCliente = DD.cDireccion 
					,C.cDirCliente AS 'Direccion_Cliente01' 
					,isnull(C.cDirCliRef,'') as 'Direccion_Referencia_Cliente'			
					,DEP.cNomDepart AS 'Departamento_Cliente'
					,pro.cNomProvin AS 'Provincia_Cliente'
					,dis.cNomDistri AS 'Distrito_Cliente'
					,isnull(CLIM.cNroTelPer,'') AS 'Nro_Telefono_Personal'
					
			
					--DATOS DEL CREDITO
					,CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre
					,CRE.nMonCapDes as 'MontoDesembolso' 
					,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,SaldoVencido = CRE.nMonSalVen
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,MontoDesembolsadoenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
						END			
					,SaldoCapitalenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
						END		
					,SaldoVencidoenSoles = CRE.nMonSalVen *	@nTipCambio
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,left(cast(CRE.dFecCulCre as date),10) as 'FechaCancelacionCredito'
					,TEM=CRE.nTasintCom	
					,PlazoInicial = CRE.nNumDiaApr
					,NumeroCuotas=CRE.nNumCuoApr					 					
					,DiasGracia = CRE.nNumDiaGra
					,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)					
					,CRE.cEstCreCon
					--,EC.cDescriEst AS 'EstadoCredito'
					,SituacionCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					 ,DiasAtraso = 
						Case when CRE.nDiaAtrCre < 0 then 0 else CRE.nDiaAtrCre end 
					--,CRE.cCodTipCre
					 ,STC.cDesTipCre AS 'TipoCredito'
					 ,STC.cDesSubTip AS 'SubTipoCredito'
					 --,CRE.cCodProduc
					 ,STC.cDesProCre AS 'ProductoCrediticio' 
					 --,CRE.cCodSubPro	
					 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
					
					,Oficina = O.cDesOficin								
					,Zona = ZON.cDesZona				
					,CRE.cCodUsuAna AS 'CodAsesorActual'
					,SP.cNomPerson AS 'NombreAsesorActual'		
	
			FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
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
					--condicion credito 
					 INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon				
					--SECTOR ECONOMICO
					/*
						LEFT JOIN Gentsececon SE
							ON SE.cCodSecEco = CLIM.cCodSecEco
					*/

					--UBIGEO DEL CLIENTE
					LEFT JOIN [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMDirecc] C
							ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
					INNER JOIN [GenTDepartame] dep
							ON DEP.cCodDepart = C.cCodDepart
					INNER JOIN [GentProvincia] pro
							ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
					INNER JOIN [GentDistrito] dis
							ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
							and dis.cCodDepart = C.cCodDepart			
				
					INNER JOIN KPYMSolicitud S
						ON S.cCodLinCre = CLI.cCodLinCre
					inner join GENTCodCiiu CI1
						on CI1.ccodciiu	= S.cCodCIIUSol 
							and CI1.ccodcatego in ('0','I')
					left join GENDCodCiiu CI2
						on CI2.ccodciiu = CI1.ccodciiu	
							and CI2.ccodciudet = CLIM.ccodciudet
							
					inner join [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDDireccion DD
						on DD.cCodCliente = CLI.cCodCliente
					inner join GENTConDomici CD
						on CD.cCodConDom = DD.cCodConDom
					
					Where CRE.cEstCreCon in ('F','G')
						and CRE.nDiaAtrCre < = 10												
			) as tmp

		--02
			/*

			 Select * from [sipmpersonal] SP 
			
			SELECT TOP 10 cCodConDom,*
			FROM CMACHYOCLI..CLIDDireccion
 
			SELECT *
			FROM GENTConDomici
			WHERE lConEstado = 1


			Select * From #tab01

			Select ccodciiu From #tab01
			Group By ccodciiu			


			Select * from KPYMSolicitud S
									 
			SELECT TOP 10 cCodConDom,*
			FROM CMACHYOCLI..CLIDDireccion
 
			SELECT *
			FROM GENTConDomici
			WHERE lConEstado = 1
			
			Select * from GENTCodCiiu CI1				
				where -- ccodciiu like '%CC%' -- ='I' 
					ccodcatego in ('0','I')

					
			Select * from GENDCodCiiu CI2
				where ccodciiu = 'CCCC' --ccodcatego = 'I'



			Select * from Gentsececon

			Select * from KPYTEstCreCon where cEstCreCon in ('F','H','I','G')

			Select * From #tab01
			Select len(CodigoCredito) From #tab01
			Select len(CodigoCliente) From #tab01
			
			--No se repiten los códigos de creditos
			Select CodigoCredito, count(CodigoCredito) From #tab01
			Group By CodigoCredito Having count(CodigoCredito) > 1

			--No se repiten los códigos de clientes
			Select CodigoCliente, count(CodigoCliente) From #tab01
			Group By CodigoCliente Having count(CodigoCliente) > 1 order by count(CodigoCliente) desc

			
			Select * From #tab01 
			where CodigoCliente = '107010387259'
			Select * From #tab01 
			where CodigoCliente = '107010387259'
				and FechaDesembolsoCredito = ( Select max(FechaDesembolsoCredito) From #tab01 
												where CodigoCliente = '107010387259')			
			
				Select * from #tab02				
				
				Select * from #tab01

			Select * from #tab01 where cEstCreCon = 'H' -- 38 
			*/

			
		--***************************INDEXANDO*********************************************************
		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01 (CodigoCredito)
		CREATE NONCLUSTERED INDEX #tab01_CodigoCliente_IXN ON #tab01 (CodigoCliente)				
		---********************************************************************************************

			Select * into #tab02 from (Select top 1 * from #tab01) as tmp
			Delete from #tab02
			-- Drop table #tab02

			--------------CURSOR ULTIMO CREDITO -------------------------------
			Declare @codcli char(12)
			--Set @codcli = '107011328585' --'107010387259'						
	
			Declare cUC CURSOR FOR	
				Select DISTINCT CodigoCliente from #tab01 (NOLOCK) 					
			
			OPEN cUC
				FETCH cUC into @codcli
				WHILE (@@FETCH_STATUS=0)
				BEGIN													
									
				Insert Into #tab02
						Select * From #tab01 
						where CodigoCliente = @codcli
							and FechaDesembolsoCredito = (	Select max(FechaDesembolsoCredito) From #tab01 
															where CodigoCliente = @codcli)														
				
				FETCH cUC INTO @codcli
				END
				CLOSE cUC
				DEALLOCATE cUC				
		------------------------------------------------------------

		--***************************INDEXANDO*********************************************************
		CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02 (CodigoCredito)
		CREATE NONCLUSTERED INDEX #tab02_CodigoCliente_IXN ON #tab02 (CodigoCliente)				
		---********************************************************************************************
		
		/*
		
		Select * from #tab02 -- (1274 row(s) affected)		
		Select * from #tab02 where cEstCreCon = 'F' -- 511
		Select * from #tab02 where cEstCreCon = 'G' -- 763

		
		Select * from #tab02
		where CodigoCliente = '107011328585'

			--No se repiten los códigos de clientes
			Select CodigoCliente, count(CodigoCliente) From #tab02
			Group By CodigoCliente Having count(CodigoCliente) > 1 order by count(CodigoCliente) desc
		*/

		--03
		Alter table #tab02
		Add PromedioDiasAtraso numeric(10,5)
		--Drop column PromedioDiasAtraso

		/*
		Select * From #tab02

		Select TipoCredito From #tab02
		Group by TipoCredito

		TipoCredito
		HIPOTECARIOS PARA VIVIENDA
		CRÉDITO A MEDIANAS EMPRESAS
		CONSUMO 
		CRÉDITO A GRANDES EMPRESAS
		CRÉDITO A PEQUEÑA EMPRESAS
		CRÉDITOS A MICROEMPRESAS

		Select NombreCliente,CodigoCredito  From #tab02 where TipoCredito = 'CRÉDITOS A MICROEMPRESAS'

		Select NombreCliente,CodigoCredito  From #tab02 where TipoCredito = 'CRÉDITOS A MICROEMPRESAS'

		Select NombreCliente,CodigoCredito  From #tab02 where CodigoCredito='107016101002145525'

		Select  Case when P.NDIAVENCUO < 0 then 0 else P.NDIAVENCUO end,*
		from [KPYDPLANPAGCRE] P
		where P.cCodCtaCre = '107018101002882553' 
				AND cCodPlaPag in  	(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
										where cCodCtaCre = '107018101002882553')

			(Select 
					avg ( Case when P.NDIAVENCUO < 0 then 0 else P.NDIAVENCUO end )					
					from [KPYDPLANPAGCRE] P
					where P.cCodCtaCre = '107018101002882553'
						AND cCodPlaPag in  
							(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
								where cCodCtaCre = '107018101002882553'))	

			Select * from #tab02

		*/

		-----------CURSOR PROMEDIO DE DIAS DE ATRASO--------------------------
			Declare @codcred varchar(18), @promdiaatr NUMERIC (10, 2)
			
			Declare cPromDiaAtr CURSOR FOR	
			SELECT CodigoCredito FROM #tab02 (NOLOCK) where cEstCreCon in ('G','F')

			OPEN cPromDiaAtr
				FETCH cPromDiaAtr into @codcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @promdiaatr =  	
					(
					Select 
						avg ( Case when NDIAVENCUO < 0 then 0.00 else cast (NDIAVENCUO as numeric (10,5)) end ) 					
					from [KPYDPLANPAGCRE] 
					where cCodCtaCre = @codcred
						and cCodPlaPag =  
							(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
								where cCodCtaCre = @codcred)
						and dFecPagCuo is not null 	
					)																																																										

				UPDATE #tab02
				SET PromedioDiasAtraso = @promdiaatr
				WHERE CodigoCredito = @codcred	

				FETCH cPromDiaAtr INTO @codcred
				END
				CLOSE cPromDiaAtr
				DEALLOCATE cPromDiaAtr
			-----------------------------------------------------------
				/*
				Select * From #tab02 
				Where PromedioDiasAtraso is null
					and SituacionCredito = 'VIGENTE' 

				Select nDiaAtrCre,*
				FROM [KPYMCRECONVEN] CRE (NOLOCK)
				Where cCodCtaCre='107066101000152114'

				Select * From #tab02 
				*/

				Update #tab02
				Set PromedioDiasAtraso = DiasAtraso
				Where PromedioDiasAtraso is null 
						
				Select * into #tab03 from (
					Select * From #tab02 
					Where PromedioDiasAtraso < 7 
					) as tmp 
							
				/*
				
				Select * From #tab03 
				Order By Anio,Mes

				*/
			
		--***************************INDEXANDO*********************************************************
		CREATE NONCLUSTERED INDEX #tab03_cCodSbs_IXN ON #tab03 (cCodSbs)
				
		---********************************************************************************************

			Select * into #tab04 from 
					(
					Select A.*
						,Jun2015=B.CMESPRO , CalJun2015=B.CCLAFIN
						--,May2015=B1.CMESPRO, CalMay2015=B1.CCLAFIN
						--,Abr2015=B2.CMESPRO, CalAbr2015=B2.CCLAFIN
					From [#tab03] A 
						left join HYO00410.URIESGOS.dbo.URIRCCMAE808 B
							on A.cCodSbs COLLATE SQL_Latin1_General_CP1_CI_AS 
								= B.CCODSBS						
						/*
						left join HYO00410.URIESGOS.dbo.URIRCCMAE808_MAY15 B1
							on A.cCodSbs COLLATE SQL_Latin1_General_CP1_CI_AS
							 = B1.CCODSBS
						left join HYO00410.URIESGOS.dbo.URIRCCMAE808_ABR15 B2
							on A.cCodSbs COLLATE SQL_Latin1_General_CP1_CI_AS
							 = B1.CCODSBS													 
						*/
					Where B.CCLAFIN = '0' 
						--and B1.CCLAFIN = '0' and B2.CCLAFIN = '0'
					) as tmp

					Select * from #tab04
			


			