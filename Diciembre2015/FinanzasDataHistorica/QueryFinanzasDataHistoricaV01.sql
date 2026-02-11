
SELECT *
FROM DATACREDITOS

CREATE NONCLUSTERED INDEX DATACREDITOS_cCodCliente_IXN ON DATACREDITOS(cCodCliente)
CREATE NONCLUSTERED INDEX DATACREDITOS_cCodCtaCre_IXN ON DATACREDITOS(cCodCtaCre)

SELECT	CodTipPer		=	ISNULL(P.cCodSexo, 'J'),			
		Genero			=	
			CASE P.cCodSexo 
				WHEN 'M' THEN 'MUJERES'
				WHEN 'F' THEN 'HOMBRES'
				ELSE 'P JURIDICA'
			END,
		A.cCodCtaCre, A.cCodCliente, A.nSaldoCapi	
	INTO curLisSalPro01 	
FROM DATACREDITOS	A
	LEFT JOIN HYO00402.CMACHYOCLI_MANIANA.dbo.CLIMPERNAT P				
		ON P.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS		=	A.CCODCLIENTE 
	LEFT JOIN HYO00402.CMACHYOCLI_MANIANA.dbo.CLIMPERJur J
		ON J.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS		=	A.CCODCLIENTE 
WHERE A.nSaldoCapi > 0
	-- (239,810 row(s) affected)

SELECT * FROM curLisSalPro01

SELECT	Genero,		
		SaldoCap		=	
				CASE CodTipPer
				WHEN 'M' THEN SUM(nSaldoCapi)
				WHEN 'F' THEN SUM(nSaldoCapi)
				WHEN 'J' THEN SUM(nSaldoCapi)
			END,							
		NroPrestamos	=	
			CASE CodTipPer 
				WHEN 'M' THEN COUNT(DISTINCT (cCodCtaCre))				
				WHEN 'F' THEN COUNT(DISTINCT (cCodCtaCre))
				WHEN 'J' THEN COUNT(DISTINCT (cCodCtaCre))
			END,						
		NroClientes		=
			CASE CodTipPer
				WHEN 'M' THEN COUNT(DISTINCT (cCodCliente))
				WHEN 'F' THEN COUNT(DISTINCT (cCodCliente))
				WHEN 'J' THEN COUNT(DISTINCT (cCodCliente))
			END		
FROM curLisSalPro01	
GROUP BY Genero,CodTipPer

SELECT * FROM CLIEXC

/*
SELECT cCodCliente, COUNT (cCodCliente)
FROM CLIEXC
GROUP BY cCodCliente
HAVING COUNT (cCodCliente) > 1
*/
--	110,470 row(s) affected)
--	110,470

SELECT * FROM CLIEXC	--110467

SELECT * FROM curLisSalPro01

SELECT  
		SaldoCap		=	SUM(A.nSaldoCapi),				
		NroPrestamos	=	COUNT(DISTINCT (A.cCodCtaCre)),								
		NroClientes		=   COUNT(DISTINCT (A.cCodCliente))
	--INTO curCliExc02
FROM curLisSalPro01 A
	INNER JOIN CLIEXC B
		ON A.cCodCliente	=	B.cCodCliente
WHERE	A.cCodCliente	IN (SELECT cCodCliente FROM CLIEXC)		
--	(110,467 row(s) affected)

-- DROP TABLE curCliExc02
SELECT * FROM curCliExc02