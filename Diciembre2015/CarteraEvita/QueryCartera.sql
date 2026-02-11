	
	/*
		Buenas Tardes, se me ha encargado revisión de cartera del asesor IOSPIN 
		por lo que requiero el listado de créditos desembolsados cuando estuvo en la Agencia Real Cajamarca 
		y si fuera posible desembolsados por la auxiliar LCHUMB
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

		Select 										
				Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
				,CLI.cCodCliente AS 'CodigoCliente'		
				,CLIM.cNomCliente AS 'NombreCliente'						
				--Datos del credito			
				,CRE.cCodCtaCre AS 'CodigoCredito'	
				,CodExpediente	=	E.cCodExpCli			
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
				,SaldoCapital = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
									THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
										* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,SaldoVigente = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
									THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,SaldoVencido = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
									THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END)
				,SaldoJudicial = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
										* CASE WHEN CRE.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
										AND CRE.cCodRefina = 'S'
									THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)						
				,TEM = CRE.nTasintCom					
				,PlazoCuotaEnDias = CRE.nNumDiaApr
				,CuotasAprobadas = CRE.nNumCuoApr
				,DiasGracia = CRE.nNumDiaGra
				,PlazoTotalEnDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
				,EstadoCredito =
				 CASE CRE.cEstCreCon
					 WHEN 'G' THEN 'CANCELADO' 
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
				,CodAnalistaOrigen				=	S.cCodUsuIng
				,NombreAsesorOrigen				=	SP2.cNomPerson							

				,B.cCodUsuOpe
				,NombreOperacionesDesembolso	=	SP3.cNomPerson	
										
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
					ON DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'		
							
				LEFT join KPYTDesCreCon D2
					ON D2.cCodDesCre = CRE.cCodDesCre	
				
				INNER JOIN KPYMSOLICITUD S
					ON S.cCodSolCre =	CRE.cCodSolCre
				INNER JOIN sipmpersonal SP2 
					ON SP2.cCodPerson = S.cCodUsuIng
				
				LEFT JOIN CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					ON E.cCodClient		 =	CLI.cCodCliente						
		           
				INNER JOIN GENMKardex B
                    ON CRE.CCODCTACRE = B.CCODCUENTA              						
				INNER JOIN sipmpersonal SP3
					ON SP3.cCodPerson = B.cCodUsuOpe

			WHERE CRE.cEstCreCon in ('F','H','G')					
						AND S.cCodUsuIng	=	'IOSPIN'
						AND O.cCodOficin	=	'035'
						AND E.CTIPEXPCLI='K' AND E.lconEstado = 1 	

						AND B.CCODTIPOPE	= '1001'
						AND B.CCODTIPKAR	= 'KPY'
						AND CCODESTTRX		= 'N'
						--AND B.cCodUsuOpe	= 'LCHUMB'
			ORDER BY year(CRE.DFECDESCRE), MONTH (CRE.DFECDESCRE)

			-- (386 row(s) affected)

		/*

			SELECT S.cCodUsuSol, S.cCodUsuAna, S.cCodUsuIng,S.* 
			FROM KPYMSOLICITUD S
			WHERE S.cCodUsuIng	=	'IOSPIN'

			Select * from GENTOficinas where cDesOficin like '%Puerto%'

				Agencias: Pangoa, Mazamari, Atalaya,Satipo,Pichanaki,Perene,La Merced,San Ramón
				,Oxapampa,Villa Rica,Puerto Bermúdez
		*/