
			/*
			*************************************************************
			*	Copyright 2008 CMAC Huancayo -. All rights reserved.  
			*                                           
			*	Objetivo : Lista Consolidado de Morosidad Diario por Analista
			*	Escrito por: 			PERCY DAVID MAYHUA TACO
			*	Email/Movil/Phone:		pmayhua@cajahuancayo.com.pe
			*	Fecha creacion: 2008.06.19
			*	Sistema / Modulo:	VITALIS / REPORTES
			*	Modificaciones:    
			*	Fecha	  	Responsable		Descripcion del cambio
			*	2008.11.11	PMAYHUA			Se cambio KPYHSALCARTOT por KPYHSALCARANA 
											como fuente de datos para el reporte.
			*	Sintaxis de ejemplo:  
			*		EXEC RPY_MorAnaDia_SP '2008-09-30', '0'
			*	DROP PROCEDURE RPY_MorAnaDia_SP
			******************************************************
			*/

			--CREATE PROCEDURE [dbo].[RPY_MorAnaDia_SP]
			Declare 
				@x_dFecSol AS DATETIME,
				@x_lConRep AS BIT

				Set @x_dFecSol = '2015-09-30'
			
			
			--AS
			SET NOCOUNT ON

			IF MONTH(@x_dFecSol) != MONTH(@x_dFecSol + 1) AND @x_lconRep = '0'
				SET @x_lconRep = '0'
			ELSE
				SET @x_lconRep = '1'	
			

			SELECT	A.cCodUsuAna, 
					A.cCodOficin,
					nNumCli = COUNT(DISTINCT cCodCliente)
				INTO #CurCliAna	
				
				FROM KPYHSALCARTOT A WITH (NOLOCK) 
					INNER JOIN KPYTCTARELCLI B WITH (NOLOCK)
						ON A.ccodctacre = B.ccodctacre
				WHERE B.ccodaplica = 'KPY'
					AND A.CESTCRECON IN ('F','H')
					AND DFECPROCES = @x_dFecSol
				GROUP BY A.cCodUsuAna, 
						A.cCodOficin
			
		-- Agencia Pucallpa

			Select * into #tab01 from (
					SELECT	A.cCodUsuAna, 
							A.cCodOficin,
							nSalTot = SUM(nMonSalVig + nSalCreJud),
							nSalVen01_07 = SUM(nSalCreR1),
							nSalVen08_15 = SUM(nSalCreR2),
							nSalVen16_30 = SUM(nSalCreR3),
							nSalVen30_ = SUM(nSalCreR4),
							nSalVenCon = SUM(nSalCreVen),
							nSalJud = SUM(nSalCreJud),
							A.dFecProces,
							nNumCli = nNumCli
						FROM KPYHSALCARANA A
							INNER JOIN #CurCliAna B
								ON A.cCodUsuAna = B.cCodUsuAna
									AND A.cCodOficin = B.cCodOficin
						WHERE A.dFecProces = @x_dFecSol
							AND A.lEstadoSal = @x_lConRep
							and A.cCodOficin = '019'
						GROUP BY A.cCodUsuAna, A.cCodOficin, A.dFecProces, nNumCli
						--ORDER BY A.cCodOficin DESC	, A.cCodUsuAna DESC
						
						) as tmp

						/*
								Drop table #CurCliAna
								Drop table #tab01
						*/

		/*
			Select * From #tab01 A

			Select * From #tab01 A
			where A.cCodOficin = '016'

		SELECT 
			P1.cCodPerson, P1.cNomPerson,CategAseOrigen = isnull(N1.cDesClaSub,'No Registra')
			, P1.dFecRegPer, P1.dFecIngIns, P1.dFecCesIns
			,C.cCodGruPer, C.cDesCarPer
		FROM sipmpersonal P1			
			left join SIPTCLASUBNIV N1					   
				on N1.nCodPAPApr = P1.nCodPAPApr
					and N1.cCodClaSub = P1.cCodClaSub
					and N1.cCodNivel = P1.cCodNivel
					and N1.cCodSubNiv = P1.cCodSubNiv
			left join SIPTCARGOPER C
				on C.cCodGruPer = P1.cCodGruPer
		Where  P1.cCodPerson = 'NLIHON' -- 'GPENAG' 'EAGUIR' 
			-- P1.dFecRegPeR != P1.dFecIngIns

		Select * from SIPTCLASUBNIV
		Select * from SIPTCARGOPER C where lConEstado = '1' and cCodGruPer = 'AIC'
		Select cCodGruPer,* from sipmpersonal where cCodPerson = 'GPENAG' 

		*/

		-- Detalle

		Select 
				--A.cCodOficin, 
				O.cDesOficin 
				,A.cCodUsuAna				
				,P1.cNomPerson --,C.cCodGruPer
				, C.cDesCarPer	
				,CategAse = isnull(N1.cDesClaSub,'No Registra')
				,FecIngAse = left(cast(P1.dFecIngIns as date),10)
				-- ,AntigAsesor = datediff(year,P1.dFecIngIns,getdate())
				,FecCesAse = isnull(left(cast(P1.dFecCesIns as date),10),'')
				,EstLabAse = Case when P1.dFecCesIns is null then 'VIGENTE'
									else 'CESADO' END								                                                                                            
				,nSalTot = (A.nSalTot)
				,nSalVen01_07 = (A.nSalVen01_07)
				,nSalVen08_15 = (A.nSalVen08_15)
				,nSalVen16_30 = (A.nSalVen16_30)
				,nSalVen30 = (A.nSalVen30_)
				,nSalVenCon = (A.nSalVenCon)
				,nSalJud = (A.nSalJud)
				,nNumCli = (A.nNumCli)
				,FechaProceso = left(cast(A.dFecProces as date),10)				
			From #tab01 A
				inner join [GENTOficinas] O 
					on O.cCodOficin = A.cCodOficin and O.lConEstado = '1'	
				inner JOIN [sipmpersonal] P1 
					ON P1.cCodPerson = A.cCodUsuAna		
				left join SIPTCLASUBNIV N1					   
					on N1.nCodPAPApr = P1.nCodPAPApr
						and N1.cCodClaSub = P1.cCodClaSub
						and N1.cCodNivel = P1.cCodNivel
						and N1.cCodSubNiv = P1.cCodSubNiv	
				left join SIPTCARGOPER C
					on C.cCodGruPer = P1.cCodGruPer

			/*
					Drop table #tab01 
					Drop table #CurCliAna				
			*/

		-- Consolidado
		/*
			Select 
				--A.cCodOficin, 
				O.cDesOficin 
				,nSalTot = sum(A.nSalTot)
				,nSalVen01_07 = sum(A.nSalVen01_07)
				,nSalVen08_15 = sum(A.nSalVen08_15)
				,nSalVen16_30 = sum(A.nSalVen16_30)
				,nSalVen30 = sum(A.nSalVen30_)
				,nSalVenCon = sum(A.nSalVenCon)
				,nSalJud = sum(A.nSalJud)
				,nNumCli = sum(A.nNumCli)
				,A.dFecProces
				,ZON.nCodZona, ZON.cDesZona 
			From #tab01 A
				inner join [GENTOficinas] O 
					on O.cCodOficin = A.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
			-- Where ZON.nCodZona = '1'
			--Group By A.cCodOficin, O.cDesOficin, A.dFecProces,ZON.nCodZona, ZON.cDesZona 
			ORDER BY A.cCodOficin asc 
		
		*/

		/*
			Select * from [GENTOficinas] O where O.lConEstado = '1'	 and cDesOficin like '%pucallpa%'		
			Select * from [Gentofizonas] GOZ where GOZ.lEstZonOfi = '1'
			Select * from [GentZonas] ZON
		*/

		
				
