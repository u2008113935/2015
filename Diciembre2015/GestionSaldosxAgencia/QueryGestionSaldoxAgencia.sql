	
DECLARE		@lnTipCambio NUMERIC(14,4),								
			@lnTotalCv NUMERIC(14,4),			@lnTotalCa NUMERIC(14,4),			
			@lnTotalCli NUMERIC(14,0),			@lnTotalCre NUMERIC(14,0),
			@lnRatioMora NUMERIC(14,0),			@lnClientes NUMERIC(14,0),
			@lnTap NUMERIC(14,0),				@lnCredProm NUMERIC(14,0)													
	
SELECT @lnTipCambio = 	nTipCamFij
FROM GENTTipCambio
WHERE LEFT(CAST(dFecTipCam AS DATE),7)  = LEFT(CAST(GETDATE() AS DATE),7)			
GROUP BY nTipCamFij 						

SELECT A.cCodCtaCre, B.cCodCliente, A.cEstCreCon, A.cCodRefina,
	   nSaldoCapi = (CASE 
						WHEN A.cEstCreCon IN ('F', 'H') THEN (A.nMonCapDes - A.nMonCapPag) * 
															CASE 
																WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																ELSE 1 
															END
						ELSE 0 
					 END),
		nSaldoVig = (CASE 
						WHEN A.cEstCreCon = 'F' AND A.cCodRefina = 'N' THEN A.nMonSalNor * 
																		CASE 
																			WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																			ELSE 1 
																			END
						ELSE 0 
					END),
		nSaldoVen = (CASE 
						WHEN A.cEstCreCon = 'F' and A.nMonSalVen > 0 THEN A.nMonSalVen * 
																		CASE 
																			WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																			ElSE 1
																		END
						ELSE 0 
					END),
		nSaldoJud = (CASE 
						WHEN A.cEstCreCon = 'H' THEN A.nMonSalVen * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
														ELSE 1
													END
						ELSE 0 
					END),
		nSaldoRef = (CASE 
						WHEN A.cEstCreCon = 'F' AND A.nMonSalNor > 0 AND A.cCodRefina = 'S' THEN A.nMonSalNor	* 
																					CASE 
																						WHEN A.cCodTipMon = '2' 
																								THEN @lnTipCambio 
																						ELSE 1
																					END
						ELSE 0 
					END),
		cCodModCre = 'KPY', A.cCodTipCre, A.cCodProduc, A.cCodSubPro, A.nTasintCom, A.cCodOficin		
	INTO #curLisSalPro 
FROM	KPYMCREconven A WITH(NOLOCK)
			INNER JOIN GENMCreCli B WITH(NOLOCK)
				ON A.cCodCtaCre = B.cCodCtaCre		
WHERE A.CESTCRECON IN ('F','H')		
UNION ALL							
SELECT cCodCtaCre = A.cCodCtaKpr, B.cCodCliente, cEstCreCon = A.cCodEstKpr, cCodRefina ='',
	   nSaldoCapi = (A.nMonSalAct * CASE 
										WHEN A.cCodTipMon = '2' THEN  @lnTipCambio 
										ELSE 1 
								  END),
	   nSaldoVig = (CASE 
						WHEN A.nDiaAtrCre <= 30 THEN A.nMonSalAct * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN  @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0
					END),
		nSaldoVen = (CASE 
						WHEN A.nDiaAtrCre > 30 THEN A.nMonSalAct * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0 
					 END),
		nSaldoJud = 0, nSaldoRef = 0, cCodModCre = 'KPR', cCodTipCre='03', 
		cCodProduc='13', cCodSubPro='16', A.nTasIntCom, A.cCodOficin										
FROM KPRMCrePrenda A WITH(NOLOCK)
		INNER JOIN GENMCreCli B WITH(NOLOCK)
			ON A.cCodCtaKpr = B.cCodCtaCre
WHERE A.cCodEstKpr IN ('A','D','G','H','R')
		
CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCtaCre_IXN  ON #curLisSalPro(cCodCtaCre)
CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCliente_IXN ON #curLisSalPro(cCodCliente)

--	SELECT * FROM #curLisSalPro

SELECT 	   
	   *,
	   Tasa		=   
			CASE cCodTipCre
				WHEN '02' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'02')) * nTasintCom
				WHEN '03' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'03')) * nTasintCom
				WHEN '04' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'04')) * nTasintCom
				WHEN '09' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'09')) * nTasintCom
				WHEN '12' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'12')) * nTasintCom
				WHEN '13' THEN (nSaldoCapi / (SELECT SUM(nSaldoCapi) 
												FROM #curLisSalPro
												WHERE nSaldoCapi > 0 AND cCodTipCre =	'13')) * nTasintCom
				END
	INTO #curLisSalProCO
FROM #curLisSalPro
WHERE nSaldoCapi > 0		
		
--	SELECT * FROM #curLisSalProCO
/*
	DROP TABLE #curLisSalProCO01
	DROP TABLE #curLisSalProCO02
*/

SELECT cCodOficin		=	ISNULL(cCodOficin,'CO'),
	   cCodTipCre		=	ISNULL(cCodTipCre,'CO'),	
	   nSaldoCv			=	SUM(nSaldoCapi),
	   nSaldoCa			=	SUM(nSaldoVen)	+	SUM(nSaldoJud),								  							
	   cCodCliente		=	COUNT (DISTINCT (cCodCliente)),							  
	   cCodCtaCre		=	COUNT (DISTINCT (cCodCtaCre)),
	   lcTip			=	'CR',		      	   
	   TAPP				=   SUM(Tasa)	   
	INTO #curLisSalProCO01
FROM #curLisSalProCO
WHERE nSaldoCapi > 0
GROUP BY GROUPING SETS((cCodOficin,cCodTipCre),())				

-- SELECT * FROM #curLisSalProCO01

SELECT	cCodOficin,cCodTipCre,	nSaldoCv,	nSaldoCa,	cCodCliente,	cCodCtaCre,	lcTip,	TAPP,	
		CreditoPromedio		=	nSaldoCv / 	cCodCliente,
		TAPP02				=	(POWER((1 + TAPP/100),12) - 1 ), 
		RatioMora			=	nSaldoCa / nSaldoCv
	INTO #curLisSalProCO02
FROM #curLisSalProCO01
--WHERE cCodTipCre NOT IN ('CO')



SELECT cCodOficin,cCodTipCre, nSaldoCv, nSaldoCa,cCodCliente,cCodCtaCre, CreditoPromedio,
	   TAPP02, RatioMora	
	INTO #curLisSalProCOLE01
FROM #curLisSalProCO02


SELECT 
		TAP		=	 (nSaldoCapi/ (SELECT SUM(nSaldoCapi) 
								  FROM #curLisSalPro
								  WHERE nSaldoCapi > 0 )) * nTasintCom
	INTO #curTap01
FROM #curLisSalPro
WHERE nSaldoCapi > 0

SET		@lnTap		=	(SELECT SUM(TAP) FROM #curTap01)

SELECT @lnTotalCv	=	SUM(nSaldoCapi),
	   @lnTotalCa	=	SUM(nSaldoVen) + SUM(nSaldoJud),
	   @lnTotalCli	=	COUNT(DISTINCT (cCodCliente)),
	   @lnTotalCre	=	COUNT(DISTINCT (cCodCtaCre)),
	   @lnCredProm   =   SUM(nSaldoCapi) / COUNT(DISTINCT (cCodCliente)),
	   @lnRatioMora	=	(SUM(nSaldoVen) + SUM(nSaldoJud)) / SUM(nSaldoCapi)	   
FROM #curLisSalPro
WHERE nSaldoCapi > 0

SELECT @lnClientes	=	SUM(cCodCliente)
FROM #curLisSalProCOLE01

SELECT  cCodOficin,
		cCodTipCre,		
		Producto	=	CASE 
							WHEN cCodTipCre =  '02' THEN 'MICROEMPRESAS'
							WHEN cCodTipCre =  '03' THEN 'CONSUMO'
							WHEN cCodTipCre =  '04' THEN 'HIPOTECARIOS'
							WHEN cCodTipCre =  '09' THEN 'EMP SIST FINAN'						
							WHEN cCodTipCre =  '12' THEN 'MEDIANAS EMPRESAS'						
							WHEN cCodTipCre =  '13' THEN 'PEQUENIA EMPRESAS'										
						END,						
		SaldoCv		= nSaldoCv,	
		PorcSalCv	= CASE	
						WHEN cCodTipCre =  '02' THEN (nSaldoCv / @lnTotalCv) 															  
						WHEN cCodTipCre =  '03' THEN (nSaldoCv / @lnTotalCv) 
						WHEN cCodTipCre =  '04' THEN (nSaldoCv / @lnTotalCv) 
						WHEN cCodTipCre =  '09' THEN (nSaldoCv / @lnTotalCv) 
						WHEN cCodTipCre =  '12' THEN (nSaldoCv / @lnTotalCv) 
						WHEN cCodTipCre =  '13' THEN (nSaldoCv / @lnTotalCv) 						
					  END,
		SaldoCa		= nSaldoCa,	
		PorcSalCa	= CASE	
						WHEN cCodTipCre =  '02' THEN (nSaldoCa / @lnTotalCa) 															  
						WHEN cCodTipCre =  '03' THEN (nSaldoCa / @lnTotalCa) 
						WHEN cCodTipCre =  '04' THEN (nSaldoCa / @lnTotalCa) 
						WHEN cCodTipCre =  '09' THEN (nSaldoCa / @lnTotalCa) 
						WHEN cCodTipCre =  '12' THEN (nSaldoCa / @lnTotalCa) 
						WHEN cCodTipCre =  '13' THEN (nSaldoCa / @lnTotalCa) 					
					  END,
		NumCli	    = cCodCliente,	
		PorcNumCli	= CASE	
						WHEN cCodTipCre =  '02' THEN (cCodCliente / @lnClientes) 
						WHEN cCodTipCre =  '03' THEN (cCodCliente / @lnClientes) 
						WHEN cCodTipCre =  '04' THEN (cCodCliente / @lnClientes) 
						WHEN cCodTipCre =  '09' THEN (cCodCliente / @lnClientes) 
						WHEN cCodTipCre =  '12' THEN (cCodCliente / @lnClientes) 
						WHEN cCodTipCre =  '13' THEN (cCodCliente / @lnClientes) 						
					  END,
		Creditos	= cCodCtaCre,
		PorcCred	= CASE	
						WHEN cCodTipCre =  '02' THEN (cCodCtaCre / @lnTotalCre) 
						WHEN cCodTipCre =  '03' THEN (cCodCtaCre / @lnTotalCre) 
						WHEN cCodTipCre =  '04' THEN (cCodCtaCre / @lnTotalCre) 
						WHEN cCodTipCre =  '09' THEN (cCodCtaCre / @lnTotalCre) 
						WHEN cCodTipCre =  '12' THEN (cCodCtaCre / @lnTotalCre) 
						WHEN cCodTipCre =  '13' THEN (cCodCtaCre / @lnTotalCre) 												
					  END,
		CreditoPromedio,
		TAPP02,
		RatioMora	= CASE	
						WHEN cCodTipCre =  '02' THEN RatioMora
						WHEN cCodTipCre =  '03' THEN RatioMora 
						WHEN cCodTipCre =  '04' THEN RatioMora
						WHEN cCodTipCre =  '09' THEN RatioMora
						WHEN cCodTipCre =  '12' THEN RatioMora
						WHEN cCodTipCre =  '13' THEN RatioMora
						WHEN cCodTipCre =  'LE' THEN RatioMora						
					  END		
	INTO #curLisSalProCOLE02
FROM #curLisSalProCOLE01
	
-- SELECT * FROM #curLisSalProCOLE02

SELECT A.cCodOficin, B.cDesOficin,
	   A.cCodTipCre, Producto,	
	   A.SaldoCv,			A.PorcSalCv,		
	   A.SaldoCa,			A.PorcSalCa,		
	   A.NumCli,			A.PorcNumCli,		
	   A.Creditos,			A.PorcCred,			A.TAPP02,		RatioMora,
	   CreditoPromedio,
	   SaldoCvT				=	@lnTotalCv,		
	   SaldoCaT				=	@lnTotalCa,		
	   NumCliT				=	@lnTotalCli,	
	   CreditosT			=	@lnTotalCre,
	   CredPromT			=	@lnCredProm,
	   TAPPT				=	(POWER((1 + @lnTap/100),12) - 1 ),
	   RatioMoraT			=	@lnTotalCa / @lnTotalCv,
	   TipoCambio			=	@lnTipCambio	   		   
FROM #curLisSalProCOLE02 A	
	INNER JOIN [GENTOficinas] B
		ON B.cCodOficin = A.cCodOficin and B.lConEstado = '1'				
ORDER BY A.cCodOficin

/*
	DROP TABLE #curLisSalPro	
	DROP TABLE #curLisSalProCO
	DROP TABLE #curLisSalProCO01	
	DROP TABLE #curLisSalProCO02	  
	DROP TABLE #curLisSalProCOLE01
	DROP TABLE #curLisSalProCOLE02	 
	DROP TABLE #curTap01
*/
