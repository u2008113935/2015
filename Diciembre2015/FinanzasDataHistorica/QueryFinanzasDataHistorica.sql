
	/*
		FINANZAS DATA HISTORICA NOVIEMBRE 2015


		Información a noviembre 2015 y diciembre 2014			
		Género					Saldo de Cartera	N° de préstamos	N° Clientes
		Mujeres			
		Hombres			
		Persona Jurídica			
		Clientes exclusivos			
		Total Cartera			
		% sobre Cartera Total	
		
		*/


DECLARE		@lnTipCambio NUMERIC(14,4)																				
	
SET @lnTipCambio	=	3.374

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
		cCodModCre = 'KPY', A.cCodTipCre, A.cCodProduc, A.cCodSubPro, A.nTasintCom		
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
		cCodProduc='13', cCodSubPro='16', A.nTasIntCom										
FROM KPRMCrePrenda A WITH(NOLOCK)
		INNER JOIN GENMCreCli B WITH(NOLOCK)
			ON A.cCodCtaKpr = B.cCodCtaCre
WHERE A.cCodEstKpr IN ('A','D','G','H','R')

SELECT * FROM #curLisSalPro

CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCtaCre_IXN  ON #curLisSalPro(cCodCtaCre)
CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCliente_IXN ON #curLisSalPro(cCodCliente)

SELECT	SaldoCapi	=	SUM(nSaldoCapi),
		CodCliente	=	COUNT(DISTINCT (cCodCliente)),
		CodCtaCre	=	COUNT(DISTINCT (cCodCtaCre))		
FROM #curLisSalPro
WHERE nSaldoCapi > 0


SELECT	CodTiPer		=	ISNULL(P.cCodSexo, 'J'),			
		Genero			=	
			CASE P.cCodSexo 
				WHEN 'M' THEN 'MUJERES'
				WHEN 'F' THEN 'HOMBRES'
				ELSE 'P JURIDICA'
			END,
		A.cCodCtaCre, A.cCodCliente, A.nSaldoCapi	
	INTO #curLisSalPro01 	
FROM #curLisSalPro	A
	LEFT JOIN CMACHYOCLI.dbo.CLIMPERNAT P				
		ON P.cCodCliente = A.CCODCLIENTE 
	LEFT JOIN CMACHYOCLI.dbo.CLIMPERJur J
		ON J.cCodCliente = A.CCODCLIENTE 
WHERE A.nSaldoCapi > 0
	-- (239,810 row(s) affected)

SELECT * FROM #curLisSalPro01

SELECT	Genero,		
		SaldoCap		=	
				CASE CodTiPer
				WHEN 'M' THEN SUM(nSaldoCapi)
				WHEN 'F' THEN SUM(nSaldoCapi)
				WHEN 'J' THEN SUM(nSaldoCapi)
			END,							
		NroPrestamos	=	
			CASE CodTiPer 
				WHEN 'M' THEN COUNT(DISTINCT (cCodCtaCre))				
				WHEN 'F' THEN COUNT(DISTINCT (cCodCtaCre))
				WHEN 'J' THEN COUNT(DISTINCT (cCodCtaCre))
			END,						
		NroClientes		=
			CASE CodTiPer
				WHEN 'M' THEN COUNT(DISTINCT (cCodCliente))
				WHEN 'F' THEN COUNT(DISTINCT (cCodCliente))
				WHEN 'J' THEN COUNT(DISTINCT (cCodCliente))
			END		
FROM #curLisSalPro01	
GROUP BY Genero,CodTiPer


/*

DROP TABLE #curLisSalPro
DROP TABLE #curLisSalPro01
DROP TABLE #codsbs

SELECT * 
FROM CMACHYOCLI.dbo.[CLIMCLIENTES] B

SELECT TOP 10 *
FROM CMACHYOCLI.dbo.CLIMPERNAT P					
			
SELECT TOP 10 *
FROM CMACHYOCLI.dbo.CLIMPERJur J

*/