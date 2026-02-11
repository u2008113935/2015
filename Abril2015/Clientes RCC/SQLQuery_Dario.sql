--RCC
SELECT TOP 10 * 
FROM URIESGOS.dbo.[URIRCCMAE808] A
       INNER JOIN URIESGOS.dbo.[URIRCCSAL808] B
             ON A.CCODSBS = B.CCODSBS
WHERE B.CCODEMP = '00107'
 
 
SELECT DISTINCT B.cCodCliente
INTO #TMPCLI
FROM KPYMCRECONVEN A
       INNER JOIN GENMCreCli B
             ON A.cCodCtaCre = B.cCodCtaCre
       WHERE cEstCreCon IN ('F','H')
 
 
CREATE NONCLUSTERED INDEX #TMPCLI_cCodcliente_IXN ON #TMPCLI(cCodCliente)
 
SELECT A.cCodCliente, A.cCodSbs, A.cCodTipDocId, C.cDirCliente,
             cCodDepart, cCodProvin, cCodDistri, cCodZona, cCodTipVia
FROM CMACHYOCLI.DBO.CLIMClientes A (NOLOCK)
       INNER JOIN #TMPCLI B
             ON A.cCodCliente = B.cCodCliente
       LEFT JOIN CMACHYOCLI.DBO.CLIMDirecc C
             ON A.cCodCliente = C.cCodCliente
             AND C.bDirPredet = 1
 
 
 
 
--SELECT top 10 *
--FROM CMACHYOCLI.DBO.CLIMPerNat
 
SELECT top 10 *
FROM [HYO00409\HISTORICO].CMACHYOCLI.DBO.[CLIMDirecc] C
WHERE bDirPredet = 1
