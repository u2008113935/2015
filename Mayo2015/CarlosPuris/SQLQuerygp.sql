Select * from gp
Select cNomCliente from gp

SELECT * into #cligar FROM (
Select cCodCliente,cNomCliente, isnull(cNroDocIde,cNroDocTri) as 'NroDocIdent'
From [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
Where cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS in (Select cNomCliente from gp)
) as tmp99

--drop table #cligar
SELECT * into #cligar FROM 
(Select CODGR,LEFT(CODGR,12) AS CODCLIENTE, RIGHT(CODGR,3) AS CODGARAN,cNomCliente,nMonSalCre
 ,TGR,CGR,COBGR,FCONS,POL,FVEPOL,MONGR,VCONS,FUVAL,REPEV,VCOM,VREA,CC,VBC,VANX,IGRC,RGPRF
 from gp) as tmp99

--SELECT LEN(CODGR) FROM GP

select top 1 *
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)

SELECT TOP 1  *
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDAMPGARCRE] G

select TOP 1 *
from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDGARLINCRE] L

select *
from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDGARLINCRE] L
WHERE L.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS 
		IN (select CODCLIENTE from #cligar)

select * from #cligar

--SELECT * into #cli FROM (
Select  A.*,
	CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA
	,O.cDesOficin AS 'NOMBRE_AGENCIA'
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
	,CLI.cCodCliente, CRE.cCodCtaCre
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
	INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN #cligar A
			ON A.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS  = CLI.cCodCliente
WHERE CRE.cEstCreCon = 'F'
	  and CLI.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS  
			IN (select cCodCliente from #cligar)
ORDER BY CLI.cCodCliente ASC
--) as tmp98

select CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA		
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
	, CRE.cCodCtaCre
FROM [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
where CRE.cCodCtaCre = '107007101005580995'