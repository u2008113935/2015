
	/*
	SELECT 
			cCodCliente,	cNomCliente
		INTO #Tab01
	FROM CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] 
	WHERE cNomCliente IN 
		(
			'CAMARENA TUEROS, TERESA ROSARIO',
			'FERNANDEZ GALVEZ, JOSE LUIS',
			'MARAVI ALEJO, MARIBEL BERTHA',
			'PORRAS HUAMAN, YULISA KATY',
			'PORTOCARRERO VARGAS, CESAR AUGUSTO',
			'PORTOCARRERO VARGAS, WALTER ULISES',
			'QUINTANILLA GALARZA, CARLOS FEDERICO',
			'ROBLES LINARES, FRANCO DANILO',
			'SALVADOR JARA, MISAEL CESAR',
			'TELLO CARHUANCA, DANIEL',
			'TORRES PALOMARES, RIGOBERTO SENA',
			'VALENZUELA SOTO, ANGEL LUIS',
			'VERA ROMAN, CARMEN',
			'VILCAPOMA CORDOVA, MARLENE DORA',
			'VILLAVICENCIO DE VEGA, GUADALUPE BERTA',
			'ALIAGA CERRON, JESUS INOCENTE',
			'HIDALGO OSPINA, MARIA DEL PILAR',
			'MALQUI ALDERETE, JACKELYNE EDITH'
		)

		*/

		/*
		
			Cliente, Cuenta,	Cod. Cliente,	Cod. Expediente,	Atraso,	Fec. Desemb,
			Monto Desembolsado (en su Moneda),	Saldo Capital (Convertido),
			Saldo Vencido (Convertido),	Tip Crédito,	Producto,	Sub Producto,
			Analista Origen,	Analista,	Oficina,	
			Estado	Domicilio, Provincia Domicilio, Distrito Domicilio, Zona Domicilio
			Fuente Ing Provincia, Fuente Ing Distrito, Fuente Ing Zona,
			Analista Destino
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
				
		SELECT 					
				Cliente					=	CLIM.cNomCliente 												
				,Cuenta					=	CRE.cCodCtaCre
				,CodCliente				=	CLI.cCodCliente 										
				,CodExpediente			=	E.cCodExpCli			
				,Atraso					=	CRE.nDiaAtrCre 														 
				,FechaDesemb			=	LEFT(CAST(CRE.dFecDesCre AS DATE),10)
				,MontoDesembolsoSoles = 
					CASE cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END		
				,SaldoCapi = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
									THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
										* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				/*
				,nSaldoVig = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
									THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				*/
				,nSaldoVen = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
									THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END)
				/*
				,nSaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
										* CASE WHEN CRE.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
										AND CRE.cCodRefina = 'S'
									THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)						
				*/
				,TipoCredito			=	STC.cDesTipCre
				--,SubTipoCredito			=	STC.cDesSubTip			 
				,Producto				=	STC.cDesProCre 			 
				,SubProducto			=	STC.cDesSubcRE 										
				/*
				,CASE cre.cCodTipMon
					WHEN '1' THEN 'SOLES'
					WHEN '2' THEN 'DOLARES'
					END AS 'Moneda'
				*/				
				--,TipoCambio				=	@nTipCambio																											
				,AnalistaOrigen				=	S.cCodUsuIng
				--,NombreAsesorOrigen		=	SP2.cNomPerson			
				,Analista					=	CRE.cCodUsuAna
				--,NombreAsesorActual			=	SP.cNomPerson
				,Oficina					=	O.cDesOficin										
				,EstadoCredito =
					 CASE CRE.cEstCreCon
						WHEN 'G' THEN 'CANCELADO' 
						ELSE D.cDesConCre
					 END																				
				--,ZonaAgencia			=	ZON.cDesZona								
				,ProvinciaDomicilio		=	PRO1.cNomProvin  			
				,DistritoDomicilio		=	DIS1.cNomDistri		 					 			
				--,DepartamentoDomicilio	=	DEP1.cNomDepart 											
				,ZonaDomicilio			=	Z.cNomZona				
				
				,ProvinciaFuenteIng		=	ISNULL(PROV1.cNomProvin,'')  			
				,DistritoFuenteIng		=	ISNULL(DIST1.cNomDistri,'')		 					 			
				--,DepartamentoFuenteIng	=	ISNULL(DEPA1.cNomDepart,'') 											
				,ZonaFuenteIng			=	ISNULL(Z1.cNomZona,'')
				/*
				,S.cCodUsuAna
				,NombreAsesorAnalista	=	SP1.cNomPerson
				*/		
			--INTO #Temp01
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
				LEFT JOIN KPYTEstCreCon EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				INNER JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna	
				--condicion credito 
				LEFT JOIN [KPYTConCredit] D
					ON D.cCondicCon = CLI.cCondicCon			 

				LEFT join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
					on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'
			
				INNER JOIN [GenTDepartame] DEP1
					ON DEP1.cCodDepart = DC.cCodDepart
				INNER JOIN [GentProvincia] PRO1
					ON PRO1.cCodProvin = DC.cCodProvin and PRO1.cCodDepart = DC.cCodDepart
				INNER JOIN [GentDistrito] DIS1
					ON DIS1.cCodDistri = DC.cCodDistri	 and DIS1.cCodProvin = DC.cCodProvin 
						and dis1.cCodDepart = DC.cCodDepart					
			
				INNER JOIN GENTZona Z
					ON Z.cCodZona = DC.cCodZona 
						and Z.cCodDepart = DC.cCodDepart
						and Z.cCodProvin = DC.cCodProvin
						and Z.cCodDistri = DC.cCodDistri	
				
				LEFT JOIN CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					ON E.cCodClient		 =	CLI.cCodCliente
				
				LEFT JOIN CMACHYOCLI_MANIANA.dbo.CLIDFUEINGRESO F
					ON F.cCodCliente	 =	CLI.cCodCliente	 
				
				LEFT JOIN [GenTDepartame] DEPA1
					ON DEPA1.cCodDepart = F.cCodDepart
				LEFT JOIN [GentProvincia] PROV1
					ON PROV1.cCodProvin = F.cCodProvin and PROV1.cCodDepart = F.cCodDepart
				LEFT JOIN [GentDistrito] DIST1
					ON DIST1.cCodDistri = F.cCodDistri	 and DIST1.cCodProvin = F.cCodProvin 
						and DIST1.cCodDepart = F.cCodDepart					
			
				LEFT JOIN GENTZona Z1
					ON Z1.cCodZona = F.cCodZona 
						and Z1.cCodDepart = F.cCodDepart
						and Z1.cCodProvin = F.cCodProvin
						and Z1.cCodDistri = F.cCodDistri	
				
				INNER JOIN KPYMSOLICITUD S
					ON S.cCodSolCre =	CRE.cCodSolCre
				/*
				INNER JOIN sipmpersonal SP1 
					ON SP1.cCodPerson = S.cCodUsuAna
				*/
				INNER JOIN sipmpersonal SP2 
					ON SP2.cCodPerson = S.cCodUsuIng
			WHERE CRE.cEstCreCon IN ('F','H')									
				AND CLI.cCodCliente IN -- ('107012504683')
								(SELECT cCodCliente FROM #Tab01)
				AND E.CTIPEXPCLI='K' AND E.lconEstado = 1 	
			ORDER BY CLI.cCodCliente

			-- (29 row(s) affected)

		/*
			SELECT *
			FROM CMACHYOCLI_MANIANA.dbo.CLIDFUEINGRESO F
			WHERE cCodCliente = '107012504683'
			
			SELECT cCodSolCre,*
			FROM KPYMSOLICITUD
			
			SELECT cCodSolCre,*
			FROM KPYMCRECONVEN

			SELECT *		
			FROM CMACHYOCLI_MANIANA.dbo.CLIDFUEINGRESO 
			WHERE cCodCliente IN (SELECT cCodCliente FROM #Tab01)
			ORDER BY cCodCliente


			SELECT  
				cCodCliente, cCodFueIng, cCodTipFIn					
				,TipoFuenteIngreso = 
					Case cCodTipFIn
					when 'D' then 'DEPENDIENTE'
					when 'I' then 'INDEPENDIENTE'
					else 'NO REGISTRA' 
					END					
				,NombreFuenteIngreso = cNomEmp
				,cCodDepart,	cCodProvin,	cCodDistri,	cCodZona
			FROM CMACHYOCLI_MANIANA.dbo.CLIDFUEINGRESO 
			WHERE cCodCliente IN (SELECT cCodCliente FROM #Tab01)
			ORDER BY cCodCliente

		*/