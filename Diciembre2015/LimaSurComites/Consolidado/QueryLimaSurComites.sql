	
		/*
				Revisando los campos que si están son el código de analista, la agencia, 
				el saldo capital, saldo vigente, saldo vencido, saldo judicial, 
				numero de re prestamos, número de clientes, tipo de créditos, nivel del asesor, 
				monto desembolsado, monto capital pagado, tipo de cómite. 
				
		*/

		SET LANGUAGE spanish;
			--Tipo cambio a junio 2015
		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		
		SET @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam AS DATE),10) =	'2015-10-31'	
			)

		SELECT		
					CRE.cCodUsuAna AS 'CodAsesor'
					,SP.cNomPerson AS 'NombreAsesor'
					,N.cDesClaSub	
					,UltimoCargo = 	CA.cDesCarPer 						
					,CodComite		 =	S.cCodComite
					,DescripComite	 =	ISNULL(TC.cDescriTip,'NO REGISTRA')

					,Oficina = O.cDesOficin										
					,Zona = ZON.cDesZona			
				
					--,Anio= year(CRE.DFECDESCRE)
					,Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
					,CLI.cCodCliente AS 'CodigoCliente'					
					--Datos del credito		 								
					,CRE.cCodCtaCre AS 'CodigoCredito'				
					--,CRE.cCodTipCre
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					--,CRE.cCodProduc 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					--,CRE.cCodSubPro 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
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
					,TEM				= CRE.nTasintCom	
					,TEA	  			= (POWER((CRE.nTasintCom/100 + 1 ), 12)-1) * 100	
					,DiasdeMora			= CRE.nDiaAtrCre 										
					,CuotasAprobadas	= CRE.nNumCuoApr
					,FechaDesembolso	=	left(cast(CRE.dFecDesCre as date),10)	
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
					,SaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
											* CASE WHEN CRE.cCodTipMon = '2'
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)
					,SaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
											AND CRE.cCodRefina = 'S'
										THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)										
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END													
					,MontoCapitalPagado		=	CRE.nMonCapPag		
					,MontoInteresAprobado	=	CRE.nMonIntPro 
					,MontoInteresAlaFecha	=	CRE.nMonIntFec 
					,MontoInteresPagado		=	CRE.nMonIntPag				
					,MontoGastoAprobado		=	CRE.nMonGasPro		
					,MontoGastosPagados		=	CRE.nMonGasPag		
					,MontoMoraProgramada	=	CRE.nMonMorPro		
					,MontoMoraPagada		=	CRE.nMonMorPag																										 									

				INTO #curLisComiteLimaSur

			FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre				
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
													
					INNER JOIN SIPTCARGOPER CA
						ON CA.cCodGruPer = SP.cCodGruPer 
				
					INNER JOIN [SIPDIncAsiPon] P 
						ON P.cCodPerson = SP.cCodPerson	AND P.cCodPeriodo = '2015/09'
							AND P.cCodSituac = 'A'								
			
					INNER join [SIPTClaSubNiv] N
						ON	N.cCodNivel = P.cCodNivel AND N.cCodSubNiv = P.cCodSubNiv 
							AND N.cCodClaSub = P.cCodClaSub AND N.lConEstado = 1 
							AND N.nCodPAPApr	=	8				
					
					INNER JOIN KPYMSolicitud	S
						ON S.cCodSolCre		=	CRE.cCodSolCre 				
					LEFT JOIN KPYTComite	TC
						ON TC.cCodComite	=	S.cCodComite	AND TC.lConEstado = 1

		WHERE CRE.cEstCreCon in ('F','H')								
			AND O.lConEstado = '1'	AND	 ZON.nCodZona = '1'
		ORDER BY CRE.cCodUsuAna --, ZON.nCodZona, CRE.cCodOficin

	/*
		SELECT * FROM #curLisComiteLimaSur
		-- 44,363
	*/

	SELECT  Zona, Oficina, CodComite, DescripComite, CodAsesor, NombreAsesor, cDesClaSub, UltimoCargo,
			SaldoCapital			=	SUM(SaldoCapital),
			SaldoVencidoJudicial	=	SUM(SaldoVencido) + SUM(SaldoJud),
			NumeroCliente			=	COUNT(DISTINCT (CodigoCliente)),
			NumeroDesembolsos		=	COUNT(DISTINCT (CodigoCredito)),
			RatioMora				=	(SUM(SaldoVencido) + SUM(SaldoJud)) / SUM(SaldoCapital)		
	FROM #curLisComiteLimaSur
	WHERE SaldoCapital > 0
	GROUP BY Zona, Oficina, CodComite, DescripComite, CodAsesor, NombreAsesor, cDesClaSub, UltimoCargo
	ORDER BY CodAsesor

	
		/*

			DROP TABLE #curLisComiteLimaSur

			SELECT  cCodComite ,*
			FROM KPYMSolicitud 
			WHERE dFecSolCre >= '2015.12.20'
      
 
			SELECT *
			FROM KPYTComite 
			WHERE lConEstado = 1
				  AND cCodComite = 'HCA'

		*/

		