
		/*
			Se solicita poder remitir de la Base de Créditos no minoristas la cantidad de clientes dsitrubuidos 
			por zonas, sectores economicos, sectores economicos por zona, por tipo de Persona,	
			
		*/


		-- 1ro obtener creditos no minoristas

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
						OVER(PARTITION BY CRE.cCodUsuAna
								ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
						,CRE.cCodUsuAna AS 'CodAsesorActual'
						,SP.cNomPerson AS 'NombreAsesorActual'	
						,CLI.cCodCliente AS 'CodigoCliente'		
						,CLIM.cNomCliente AS 'NombreCliente'
						,CLIM.cCodClaPer												
						,TipoPersona = T.CdesCorta	
						,CodSecEcomomico = isnull(CLIM.cCodSecEco,'O')											
						,DescSecEcomomico = isnull(SE.cDesSecEco,'OTRAS ACTIVIDADES DE SERVICIOS COMUNITARIOS,SOCIALES Y PERSONALES')													
						,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
						,DireccionReferencia = DC.cDirCliRef
						,ZonaDireccion = Z.cNomZona
						,DIS1.cNomDistri as 'Distrito'		 					 			
						,PRO1.cNomProvin AS 'Provincia' 			
						,DEP1.cNomDepart AS 'Departamento'	
						--Datos del credito			
						,CRE.cCodCtaCre AS 'CodigoCredito'
						,CLI.cCodLinCre			
						,STC.cDesTipCre AS 'TipoCredito'
						,STC.cDesSubTip AS 'SubTipoCredito'			 
						,STC.cDesProCre AS 'ProductoCrediticio' 			 
						,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
						,CRE.nMonCapDes as 'MontoDesembolso' 
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
						,TEM=CRE.nTasintCom	
						,NumeroCuotas=CRE.nNumCuoApr
						,EstadoCredito =
						 Case CRE.cEstCreCon
						 when 'G' then 'CANCELADO' 
						 ELSE D.cDesConCre
						 END														 
						,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
						,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
						,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
						--,CRE.cEstCreCon
						--,EC.cDescriEst AS 'EstadoCredito'			
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

						left join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
							on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'
			
						INNER JOIN [GenTDepartame] DEP1
							ON DEP1.cCodDepart = DC.cCodDepart
						INNER JOIN [GentProvincia] PRO1
							ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
						INNER JOIN [GentDistrito] DIS1
							ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
								and dis1.cCodDepart = DC.cCodDepart					
			
						INNER JOIN GENTZona Z
							ON Z.cCodZona = DC.cCodZona 
								and Z.cCodDepart = DC.cCodDepart
								and Z.cCodProvin = DC.cCodProvin
								and Z.cCodDistri = DC.cCodDistri	
						inner join GENTClaPersona T
							on T.cCodClaPer = CLIM.cCodClaPer
						left join GENTSecEcon SE
							on SE.cCodSecEco = CLIM.cCodSecEco						 														
							
					WHERE CRE.cEstCreCon in ('F','H')					
						-- and CRE.cCodOficin = '058'	
						and CRE.cCodTipCre in ('05','06','07','08','09','10','11','12') 
					) as tmp


	/*
		Select * from #tab01
			-- (326 row(s) affected)
	*/

	Select CodigoCliente, count(CodigoCliente)
	From #tab01
	Group By CodigoCliente
	Having count(CodigoCliente) > 1
	Order BY count(CodigoCliente) desc

	Select * From #tab01
	Where CodigoCliente = '107018964878'

	
	-------------------------------------------------------------------------
	Select * into #tab02 from ( Select top 1 * from #tab01 ) as tmp
		-- Drop table #DEvaSolici
		-- Select * from #DEvaSolici
		Delete from #tab02

		
		----------------------------CURSOR EVALUACION-----------------------
			Declare @codclie char(12) 				
				Declare cNm CURSOR FOR
					
				Select distinct CodigoCliente from #tab01 (NOLOCK)									

				OPEN cNm
				FETCH cNm into @codclie
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #tab02 					
					Select top 1
						*
					FROM #tab01
					where CodigoCliente = @codclie
			
				FETCH cNm INTO @codclie
				END
				CLOSE cNm
				DEALLOCATE cNm
		-------------------------------------------------------------------
	
		

		/*
				Select * from #tab02

				Select CodigoCliente, count(CodigoCliente)
				From #tab02
				Group By CodigoCliente
				Having count(CodigoCliente) > 1
				Order BY count(CodigoCliente) desc


				Select
					CodigoCliente,cCodClaPer,TipoPersona,CodSecEcomomico,DescSecEcomomico
					,Oficina,Zona
				From #tab02


				drop table #tab01
				drop table #tab02

		*/