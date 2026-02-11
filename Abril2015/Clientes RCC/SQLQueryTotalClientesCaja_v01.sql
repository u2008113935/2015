--FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYMCRECONVEN] CRE (NOLOCK)

/*
select CRE.nDiaAtrCre,*
from  [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
where CRE.cCodCtaCre = '107014101002831894'
*/

--select  CRE.nDiaAtrCre,*
--from  [HYO00402].SOFCMACHYO_AYER.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
--where CRE.cCodCtaCre = '107014101002831894'

--/*
DECLARE @cantclic as int, @cantclip as int
set @cantclic = (
select --top 200
		--/*
		count(DISTINCT CLI.cCodCliente) as CLICOD
		--,COUNT(CLI.cCodCtaCre) AS CLICRE
		--,count (CRE.cCodCtaCre) as crecre
		--*/
		/*
		CRE.cCodCtaCre
		,CLI.cCodCliente 
	    ,CASE CRE.cEstCreCon
		  WHEN 'F' THEN 'VIGENTE'
		  WHEN 'H' THEN 'JUDICIAL'
		  --WHEN 'I' THEN 'CASTIGADO'
		  --WHEN 'G' THEN 'CANCELADO'
		  --WHEN 'E' THEN 'PENDIENTE'
		  ELSE ''
		  END AS 'ESTADO_DEL_CREDITO'
		,(CRE.nMonCapDes - CRE.nMonCapPag) as 'SaldoCapital'
	    ,CRE.nSalCapDia, CRE.nSalCapAnt
		  */		  
from --[KPYMCRECONVEN] CRE (NOLOCK)		
	[HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN 	[HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI 
	--INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
WHERE CRE.cEstCreCon IN ('F','H')--ESTADO DEL CREDITO ES VIGENTE F
		--and CRE.nMonCapDes > 0
		and (CRE.nMonCapDes - CRE.nMonCapPag) > 0
--Group by CLI.cCodCliente
 )
		--212717
		--and 
		--CRE.nSalCapAnt > 0.00
--*/
set @cantclip = (
SELECT count(DISTINCT CLI1.cCodCliente)
	--PREN.nMonCreKpr as 'MontodelCredito'
	--,PREN.nMonPagKpr as 'MontoPagado'
	--,PREN.nMonSalAct as 'SaldoActual'
FROM [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPRMCREPRENDA] PREN (NOLOCK)
		--INNER JOIN [GENMCRECLI] CLI1 
		INNER JOIN 	[HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI1 
			ON CLI1.cCodCtaCre = PREN.cCodCtaKpr
WHERE PREN.cCodEstKpr in ('D','A','R','G','H')
		AND (PREN.nMonCreKpr - PREN.nMonPagKpr) > 0
		)

select @cantclic + @cantclip as clientes

/*
SELECT  CRE.cCodCtaCre
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
WHERE CRE.cCodCtaCre IN -- = '107001411000000101'
		(SELECT PREN.cCodCtaKpr
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPRMCREPRENDA] PREN)

SELECT  TOP 2 *
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI (NOLOCK)
*/

/*
select top 2 * 
from  [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI (NOLOCK)	
*/

/*
select  *
from [HYO00402].SOFCMACHYO_DIARIO_TARDE.dbo.[KPYTESTCRECON] ECRE (NOLOCK)
*/