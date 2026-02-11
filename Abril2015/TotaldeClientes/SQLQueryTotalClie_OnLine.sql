--EN LINEA
--USE SOFCMACHYO_DIARIO_MANIANA
--USE SOFCMACHYO_DIARIO_MEDIODIA
--USE SOFCMACHYO_DIARIO_TARDE
--drop table #newcli
select * into #newcli FROM  (
--DECLARE @cantclic as int, @cantclip as int
--set @cantclic = (
--select * into #tmp_01 FROM  (
select 	--count(DISTINCT CLI.cCodCliente) as CLICOD
		DISTINCT CLI.cCodCliente 
from [GENMCRECLI] CLI (NOLOCK)			
	INNER JOIN 	[KPYMCRECONVEN] CRE 	
			ON CLI.cCodCtaCre = CRE.cCodCtaCre		
WHERE CRE.cEstCreCon IN ('F','H')--ESTADO DEL CREDITO ES VIGENTE F	y JUDICIAL H					
		and (CRE.nMonCapDes - CRE.nMonCapPag) > 0
		--(186574 row(s) affected)
	--) as tmp01
--select * from #tmp_01
 --) --(186385 row(s) affected)
--/*
--set @cantclip = (
UNION
--select * into #tmp_02 FROM  (
SELECT ---count(DISTINCT CLI1.cCodCliente)
		DISTINCT CLI1.cCodCliente
FROM [KPRMCREPRENDA] PREN (NOLOCK)		
		INNER JOIN 	[GENMCRECLI] CLI1 
			ON CLI1.cCodCtaCre = PREN.cCodCtaKpr
WHERE PREN.cCodEstKpr in ('D','A','R','G','H')		
		and PREN.nMonSalAct > 0	
			--(941 row(s) affected)
 --) as tmp02
 ) as tmp03
 --- UNION (187145 row(s) affected)
 --UNION ALL --(187327 row(s) affected)

 --select * from #tmp_02 --(942 row(s) affected)

 --select B.cCodCliente from #tmp_02 B
 --WHERE B.cCodCliente IN (select A.cCodCliente from #tmp_01 A)
 --760
	--	)--(942 row(s) affected)
--*/
--select @cantclic --+ @cantclip 
	--	as clientes

--select * from GENTGruSangui

--(187327 row(s) affected)
select cCodCliente from #newcli 
select count(cCodCliente) from #newcli 
--187145
--187327
--187515

--(187333 row(s) affected)

