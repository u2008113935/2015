	
	/*
		Agencias: Pangoa, Mazamari, Atalaya,Satipo,Pichanaki,Perene,La Merced,San Ramón
		,Oxapampa,Villa Rica,Puerto Bermúdez

		Camps de información:

		•	Nombre del cliente
		•	Teléfonos de contacto (celular o fijo)
		•	Dirección
		•	Tipo de Crédito
		•	Producto
		•	Plazo
		•	Asesor
		•	Días de atraso
		•	Mora total
		•	Monto vencido
		•	Monto Judicial
		•	Créditos vigentes y cancelados
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

	-- Select * into #tab01 from (

		Select 		
				ROW_NUMBER() 
				OVER(PARTITION BY O.cDesOficin	
						ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 						
				,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
				,CLI.cCodCliente AS 'CodigoCliente'		
				,CLIM.cNomCliente AS 'NombreCliente'
				,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
				,DireccionReferencia = DC.cDirCliRef
				,Telefono = CLIM.cNroTelPer
				,ZonaDomicilio = cNomZona
				,DIS1.cNomDistri as 'DistritoDomicilio'		 					 			
				,PRO1.cNomProvin AS 'ProvinciaDomicilio' 			
				,DEP1.cNomDepart AS 'DepartamentoDomicilio'					
				--Datos del credito			
				,CRE.cCodCtaCre AS 'CodigoCredito'				
				,STC.cDesTipCre AS 'TipoCredito'
				,STC.cDesSubTip AS 'SubTipoCredito'			 
				,STC.cDesProCre AS 'ProductoCrediticio' 			 
				,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
				,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
				,CRE.nMonCapDes as 'MontoDesembolso' 
				,TipoCambio = @nTipCambio
				,MontoDesembolsoenSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN CRE.nMonCapDes
					WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END						
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
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'
				,ISNULL(left(cast(CRE.dFecCulCre as date),10),'') as 'FechaCancelacion'			
				--,CRE.cEstCreCon
				--,EC.cDescriEst AS 'EstadoCredito'	
				,DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')				
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
			
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre										

			WHERE CRE.cEstCreCon in ('F','H','G')					
				and CRE.cCodOficin in ('052','071','057','010','014','070','004','075','015'
					,'069','031','063')		
				and left(cast(CRE.dFecDesCre as date),10) >= '2012-01-01' 
					
				
		--	) as tmp

		/*

			Select * from GENTOficinas where cDesOficin like '%Puerto%'

				Agencias: Pangoa, Mazamari, Atalaya,Satipo,Pichanaki,Perene,La Merced,San Ramón
				,Oxapampa,Villa Rica,Puerto Bermúdez
		*/