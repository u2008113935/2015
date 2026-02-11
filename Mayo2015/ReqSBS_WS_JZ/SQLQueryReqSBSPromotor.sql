-- DROP TABLE #tmpv01
SELECT * into #tmpv01 FROM  (
Select 
	ROW_NUMBER() 
	OVER(PARTITION BY STC.cDesTipCre 
			ORDER BY CRE.dFecDesCre) AS Secuencia
	 ,CRE.cCodTipCre
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
	 --,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	 --,CRE.cCodProduc
	 --,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
	 ,CRE.cCodSubPro	
	 ,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'	  
	--Datos del Cliente	
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'	
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'	
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case cre.cCodTipMon
	when '1' then 'SOLES'--(CRE.nMonCapDes - CRE.nMonCapPag)
	when '2' then 'DOLARES'--(CRE.nMonCapDes - CRE.nMonCapPag) * 3.34
	end AS 'MONEDA'
	,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SALDO'		
	--,CRE.cCodDesCre
	--,B.cCodDesCre
	--,C.cCodTipDes, C.cDesTipDes
	,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,A.cCodSolCre
	--,C.cCodTipDes
	,C.nMonTipDes
	,D.cCodTipDes
	,D.cDesTipDes		
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
	INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon	
	INNER JOIN kpymsolicitud A
			ON A.cCodSolCre =  CRE.cCodSolCre
	INNER JOIN KPYDDesCreCon B
			ON B.cCodSolCre =  A.cCodSolCre AND B.cCodDesCre = CRE.cCodDesCre 
	INNER JOIN KPYDTipDesCre C
			ON C.cCodSolCre =  A.cCodSolCre
	INNER JOIN KPYTTipDesCre D
			ON D.cCodDesCre = CRE.cCodDesCre AND C.cCodTipDes = D.cCodTipDes
WHERE CRE.cEstCreCon = 'F'		
   AND (cDesSubCre	like '%PROMOTOR%INMOBI%' and lEstado = 1)	 
	 ) as tmp99
--ORDER BY CRE.cCodTipCre ASC
--(23,698 row(s) affected)
--/*
--cCodSolCre
select * from #tmpv01 where CODIGO_CLIENTE = '107011332265'
select * from #tmpv01 where CODIGO_CREDITO ='107016101002838384'
--select * from #tmpv01 order by Secuencia asc

select TOP 1 * from #tmpv01 
where cCodSolCre='0160036695' 
	and nMonTipDes = (select max(nMonTipDes) from #tmpv01 where cCodSolCre='0160036695' )

SELECT * into #tmpv02 FROM  ( select top 1 * from #tmpv01) as tmp98
delete from #tmpv02
select * from #tmpv02


--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpv01_cCodSolCre_IXN ON #tmpv01(cCodSolCre)
CREATE NONCLUSTERED INDEX #tmpv02_cCodSolCre_IXN ON #tmpv02(cCodSolCre)
--------------------****************************************************************************

--CURSOR #TMP_CREMICRO
Declare @cCodSolCre varchar(10)
Declare cCursor1 CURSOR FOR
	select cCodSolCre from #tmpv01
OPEN cCursor1
FETCH cCursor1 into @cCodSolCre
WHILE (@@FETCH_STATUS=0)
BEGIN
		INSERT INTO #tmpv02 			 										
		select TOP 1 * from #tmpv01 
		where cCodSolCre=@cCodSolCre 
			and nMonTipDes = (select max(nMonTipDes) from #tmpv01 
								where cCodSolCre=@cCodSolCre )			

FETCH cCursor1 INTO @cCodSolCre
END
CLOSE cCursor1
DEALLOCATE cCursor1
-------------------------------------------------------
select * from #tmpv02 where CODIGO_CLIENTE ='107011332265'
select distinct * from #tmpv02 where CODIGO_CLIENTE ='107011332265'
-------------------------------------------------------
--delete from #tmpv02
SELECT * into #tmpv03 FROM  ( select distinct * from #tmpv02) as tmp97
--drop table #tmpv03

select * from #tmpv03 where CODIGO_CLIENTE ='107011332265'

select * from #tmpv03 
--where CODIGO_CREDITO='107016101002838384'--'107011101005093480'
order by TIPO_DE_CREDITO,Secuencia

select CODIGO_CREDITO, count(CODIGO_CREDITO)
from #tmpv03 
group by CODIGO_CREDITO 
having count(CODIGO_CREDITO)>1


drop table #tmpv01
drop table #tmpv02
drop table #tmpv03

/*
SELECT TOP 1 * FROM kpymsolicitud
--CRE.cCodDesCre AS 'DESTINO' 
SELECT * FROM [KPYMCRECONVEN] WHERE cCodSolCre='0070040839'
SELECT * FROM kpymsolicitud WHERE cCodSolCre = '0070040839'

SELECT *
FROM KPYDDesCreCon
WHERE cCodSolCre = '0070040839'
 
SELECT * FROM KPYTDesCreCon WHERE cCodDesCre = 6 --cCodDesCre
 
SELECT *
FROM KPYDTipDesCre
WHERE cCodSolCre = '0070040839' --cCodTipDes
--cCodSolCre
--0070040839
 
SELECT *
FROM KPYTTipDesCre 
WHERE cCodDesCre = 7 --cCodTipDes, cCodDesCre
*/
