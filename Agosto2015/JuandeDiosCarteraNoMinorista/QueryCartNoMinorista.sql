
		/*
		CARTERA DE CRÉDITO NO MINORISTAS (Incluye Cartas Fianza)
		FechaInicio : (Juio-2010) Fecha Fin: 06/08/2015	
		Mediana Empresa, Grande Empresa, IFI's				

		Nombre y apellidos del cliente
		Nro. de Cuenta de Crédito
		Moneda
		Monto de Desembolso
		Plazo del Crédito (Dias)
		Numero de cuotas del crédito
		TEA o TEM
		Saldo de Capital
		Saldo de capital convertido en moneda Nacional
		Actividad Económica o CIIU
		Giro del Negocio
		Tipo de Crédito
		Sub Producto de Crédito
			Modalidad de Crédito
			Calificación Crediticia
		Saldo Vencido
		Saldo Vencido convertido en moneda nacional
		Tipo de Persona (Natural o Jurídica)
		Fecha de Registro de la solicitud del crédito
		Fecha de Desembolso del crédito
		Agencia
		Zona
		Asesor de Negocios Actual
		Estado (cancelado o vigente)
		Dias de mora: promedio
		Dias de mora: maximo de retraso
			Historial de Créditos
			Ingreso del evaluación empresarial

		*/

	/*
	
	Drop table #tab01


	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')	
	
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
					,TipoPersona = 
						Case when CLIM.cNroDocTri is not null AND CLIM.cNroDocIde IS NULL
							 then 'PERSONA JURIDICA'
						else 'PERSONA NATURAL' END                         
					--,SectorEconomico = isnull(SE.cDesSecEco,'No Registra')
					
					,CodigoCIIUSolicitante = S.cCodCIIUSol, CI1.ccodciiu 					
					,ActividadEconomica =  CI1.cdesactivi
					,CI2.ccodciudet ,GiroNegocio = ISNULL(CI2.cdesactivi,'SIN REGISTRO')
					--Evaluacion
					,UtilidadOperativa = EE.nUtilidOpe 
					,ResUnidadEconomicaFamiliar = EE.nResultUef
					,CapacidadPago = EE.nCapacPago

					,C.cDirCliente AS 'Direccion_Cliente' 
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
							-- and CI1.ccodcatego in ('0','I')
					left join GENDCodCiiu CI2
						on CI2.ccodciiu = CI1.ccodciiu	
							and CI2.ccodciudet = CLIM.ccodciudet	
					
					inner join KpyDEvaSolici ES
						on ES.cCodSolCre = S.cCodSolCre
					inner join KpydEpgEvaSol1 EE
						on EE.nNumEvaMes = ES.nNumEvaMes

					Where CRE.cEstCreCon in ('F','G')
						and (CRE.cCodTipCre in ('09','11','12') and STC.lEstado = '1')			
			) as tmp

		----------------------------
		
		-- 02
		/*
		
		Select * from #tab01
		Select * from [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMCLIENTES]

		*/
		Alter table #tab01
		Add PromedioDiasAtraso numeric(10,5), MaximoDiasAtraso numeric(10,5)


		-----------CURSOR PROMEDIO DE DIAS DE ATRASO--------------------------
			Declare @codcred varchar(18), @promdiaatr NUMERIC (10, 5), @maxdiaatr NUMERIC (10, 2)
			
			Declare cPromDiaAtr CURSOR FOR	
			SELECT CodigoCredito FROM #tab01 (NOLOCK) 

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


					set @maxdiaatr =  	
					(
					Select 
						max ( Case when NDIAVENCUO < 0 then 0.00 else cast (NDIAVENCUO as numeric (10,5)) end ) 					
					from [KPYDPLANPAGCRE] 
					where cCodCtaCre = @codcred
						and cCodPlaPag =  
							(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
								where cCodCtaCre = @codcred)
						and dFecPagCuo is not null 	
					)

				
				UPDATE #tab01
				SET PromedioDiasAtraso = @promdiaatr
				WHERE CodigoCredito = @codcred	
				
				UPDATE #tab01
				SET MaximoDiasAtraso = @maxdiaatr
				WHERE CodigoCredito = @codcred	

				FETCH cPromDiaAtr INTO @codcred
				END
				CLOSE cPromDiaAtr
				DEALLOCATE cPromDiaAtr
			-----------------------------------------------------------
		
				/*
				Select * from #tab01

				Select * from #tab01
				Where PromedioDiasAtraso is null and MaximoDiasAtraso is NULL
				*/

				Update #tab01
				Set PromedioDiasAtraso = 0.00 ,MaximoDiasAtraso = 0.00
				Where PromedioDiasAtraso is null and MaximoDiasAtraso is NULL

		/*

		Select * from #tab01

		select * from KpyDEvaSolici

		select * from 
					KpydEpgEvaSol1					
					KpyDEvaSolici					
					KpyMEvaClient
					KpyMEvaSolCre					
		
		Select * from KpydEpgEvaSol1		

		Select *  from GENTCodCiiu 
			where ccodciiu = '0111'

		select * from GENDCodCiiu
			where ccodciiu = '0111'
		
		Select ccodciudet
		from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		group by ccodciudet 

		Select top 11 cCodCIIUSol,* from KPYMSolicitud
		where cCodCIIUSol = 'CCCC'


		Select COUNT (cCodCIIUSol) from KPYMSolicitud
		where cCodCIIUSol = 'CCCC'
		*/