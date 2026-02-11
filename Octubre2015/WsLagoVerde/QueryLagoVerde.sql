
	/*
		SOLICITO UN REPORTE DE CRÉDITOS HIPOTECARIOS VIGENTES CUYO DATOS DE GARANTÍAS 
		CONTEMPLEN EL SIGUIENTE DATO: 
			URB. LAGO VERDE / URBANIZACIÓN LAGO VERDE. 
			ZONA CENTRO FECHAS DE DESEMBOLSO 01.01.2010.

	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)

		-- Drop table #tab01
	Select * into #tab01 from (
			Select 		
					ROW_NUMBER() 
					OVER(PARTITION BY year(CRE.DFECDESCRE)
							ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)
					--,CRE.cCodTipCre
					 ,STC.cDesTipCre AS 'TipoCredito'
					 ,STC.cDesSubTip AS 'SubTipoCredito'
					 --,CRE.cCodProduc
					 ,STC.cDesProCre AS 'ProductoCrediticio' 
					 --,CRE.cCodSubPro	
					 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 							
					--Datos del credito			
					,CRE.nMonCapDes as 'MontoDesembolso' 
					,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,SaldoCapitalenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
						END					
					,FechaAprobacion=left(cast(S.dFecAprCre as date),10)	
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,TEM=CRE.nTasintCom	
					,NumeroCuotas=CRE.nNumCuoApr										 

					--,CRE.cEstCreCon
					--,EC.cDescriEst AS 'EstadoCredito'
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					--,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'') 
					--,B.cCodGarCli
					--,O.cCodOficin
					,Oficina = O.cDesOficin							
					--,ZON.nCodZona
					,Zona = ZON.cDesZona			
					--Datos del Cliente			
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre
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
					 inner join KPYMSolicitud S
						ON S.cCodSolCre = CRE.cCodSolCre			
										
				WHERE CRE.cEstCreCon in ('F','H','G')					
					and (CRE.cCodTipCre = '04' and STC.lEstado = '1')			
		) as tmp
 			
		--
		/*
				Select * from #tab01 
				Order By Anio,Mes
		*/

		 /*
		 Select CodigoCredito, count(CodigoCredito)
		 from #tab01
		 group by CodigoCredito
		 having count(CodigoCredito) > 1 


		 Select CodigoCliente, count(CodigoCliente)
		 from #tab01
		 group by CodigoCliente
		 having count(CodigoCliente) > 1 

		 select *
		 from #tab01
		 where CodigoCliente = '107012133207' --'107010025685'

			Select top 10 * from CMACHYOCLI_MANIANA..CLIDDirGarant D
			Select top 5 * from [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.GENTTipVia
			Select top 5 * from [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.GENTViaAcc

		 */
		
	
			Select A.*
				,B.cCodTipGar, B.cCodGarCli
				,FechaConstitGarantRRPP = left(cast(C.dFecConsGar as date),10) 
				,TitularGarantia = C1.cNomCliente
				,Direccion = D.cDirCliente	
				,Referencia = D.cDirCliRef
				,NombreZona = Z.cNomZona
				,NombreVia = V.cNomViaAcc
				--,D.cCodZona
				--,ZO.cNomZona
				--,D.cCodDepart
				,DE.cNomDepart
				--,D.cCodProvin
				,PR.cNomProvin
				--,D.cCodDistri
				,DI.cNomDistri				

			From #tab01 A
				inner join KPYDGarLinCre B	
					on A.cCodLinCre = B.cCodLinCre			
				inner join CMACHYOCLI_MANIANA.DBO.CliMGarFisHipCli C
					on C.cCodCliente = B.cCodCliente
						and C.cCodGarCli = B.cCodGarCli 
					and C.dFecConsGar is not NULL
				
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C1 
					ON C1.cCodCliente = B.cCodCliente
				
				left join CMACHYOCLI_MANIANA..CLIMGarCliente G
					on G.cCodCliente = B.cCodCliente 
						and G.cCodTipGar = B.cCodTipGar
						and G.cCodGarCli = B.cCodGarCli
				left join CMACHYOCLI_MANIANA..CLIDDirGarant D
					on D.cCodCliente = B.cCodCliente and D.cCodGarCli = B.cCodGarCli 

				inner join GENTDepartame DE
					on DE.cCodDepart = D.cCodDepart
				inner join GENTProvincia PR
					on PR.cCodProvin = D.cCodProvin and PR.cCodDepart = D.cCodDepart
				inner join GENTDistrito DI 
					on DI.cCodDistri = D.cCodDistri and DI.cCodDepart = D.cCodDepart
						and DI.cCodProvin = D.cCodProvin
				inner join [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.GENTViaAcc V
					on V.cCodViaAcc = D.cCodViaAcc 
						and V.cCodTipVia = D.cCodTipVia
						AND V.cCodDepart = D.cCodDepart
						and V.cCodProvin = D.cCodProvin
				INNER JOIN GENTZona Z
						ON Z.cCodZona = D.cCodZona 
							and Z.cCodDepart = D.cCodDepart
							and Z.cCodProvin = D.cCodProvin
							and Z.cCodDistri = D.cCodDistri

			WHERE -- B.cCodTipGar != 'PEFIS' AND 				
					B.cCodEstGar = 'A'	
					and (D.cDirCliente like '%lago%ve%' or D.cDirCliRef like '%lago%ve%'
							or V.cNomViaAcc like '%lago%ve%' or Z.cNomZona like '%lago%ve%'  )
			Order By A.Anio,A.Mes

			-- (2,764 row(s) affected)
	


