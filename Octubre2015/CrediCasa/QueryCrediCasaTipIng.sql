
		/*
			
			Solicitar data de la cartera de créditos con los siguientes datos: 
				* código de cliente * agencia * asesor * tipo de crédito * subproducto: credicasa habitacional 
				* monto * plazo * tem * días atraso * zona * dirección de domicilio * provincia * distrito 
				* departamento. * actividad (empresariales) y tipo de ingreso (para consumo)

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

	Select * into #tab01 from (

			Select 		
					ROW_NUMBER() 
					OVER(PARTITION BY CLI.cCodCliente
							ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 					
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
					--,DireccionReferencia = isnull(DC.cDirCliRef,'')
					,ZonaDomi = Z.cNomZona
					,DIS1.cNomDistri as 'DistritoDomi'		 					 			
					,PRO1.cNomProvin AS 'ProvinciaDomi' 			
					,DEP1.cNomDepart AS 'DepartamentoDomi'	
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
					,NumeroCuotas = CRE.nNumCuoApr
					,DiasAtraso = CRE.nDiaAtrCre
					--,CodPlazo = CRE.cCodPlazo
					,Plazo = TP.cDesPlazo
					,TEM = CRE.nTasintCom	
					,TipoTasa = CRE.cTipTasCom									
					,DetalleTipoTasa =
						Case CRE.cTipTasCom
						When 'TM' THEN 'ESPECIAL MAYOR'
						When 'TT' THEN 'DE TABLA'
						When 'TM' THEN 'DE ADMINISTRAC'
						When 'TJ' THEN 'DE JEFATURA'
						When 'TG' THEN 'DE GERENCIA'
						When 'ES' THEN 'GER OPE/FINAN'
						ELSE CRE.cTipTasCom END	 					
					,PlazoInicial = CRE.nNumDiaApr
					,CuotasAprobadas = CRE.nNumCuoApr
					,DiasGracia = CRE.nNumDiaGra
					,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
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
					,CIUU = isnull(CLIM.cCodCiiu,'9999')
					,DescActividad = isnull(CI.cdesactivi,'OTRAS ACTIVIDADES NO ESPECIFICADAS')		
					,CodTipoIngreso = DE.nCodDetCon 
					,TipoIngreso = DE.cNomDetCon
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
					inner join [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.GENTTipPlazo TP
						on TP.cCodPlazo = CRE.cCodPlazo and TP.lConEstado = '1'	
					inner join GENTCodCiiu CI
						on CI.cCodCiiu = CLIM.cCodCiiu		
					inner join KpyMSolicitud SO
						ON SO.cCodLinCre = CLI.cCodLinCre
					inner join KpyDEvaSolici E
						ON E.cCodSolCre = SO.cCodSolCre
					inner join KpyDIngDeuInt I
						on I.nNumEvaMes = E.nNumEvaMes
					inner join KPYDDocEvaCon DE
						on DE.nCodDetCon = I.nCodDetCon 		 								

				WHERE CRE.cEstCreCon in ('F','H')					
					and STC.cDesSubCre like '%credi%casa%habitacional%'

				) as tmp


			Select * into #tab02 from (select top 1 * from #tab01) as tmp
			Delete from #tab02


			--02
	------------------------CURSOR 1ER CREDITO-----------------------------------
				Declare @cc1 char(12)
					Declare cC CURSOR FOR	
						
						Select distinct CodigoCliente from #tab01 (nolock)

					OPEN cC
						FETCH cC into @cc1
						WHILE (@@FETCH_STATUS=0)
						BEGIN	
				
						  Insert Into #tab02
						  Select top 1 * 										
							from #tab01
							where CodigoCliente = @cc1									
					
						FETCH cC INTO @cc1
						END
						CLOSE cC
						DEALLOCATE cC
		-----------------------------------------------------------------------------

			Select * from #tab02 

        /*
			drop table #tab02
			drop table #tab01
		*/

		/*
				Select * from [KPYTSUBTIPCRE] STC
				where STC.lEstado = '1' 
						and STC.cDesSubCre like '%credi%casa%habitacional%'

		*/