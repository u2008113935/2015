-- DROP TABLE #tmpv01
SELECT * into #tmpv01 FROM  (
Select 
	ROW_NUMBER() 
	OVER(PARTITION BY STC.cDesTipCre 
			ORDER BY CRE.dFecDesCre) AS Secuencia
	 ,CRE.cCodTipCre
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
	 ,CRE.cCodSubPro	
	 ,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'	  
	--Datos del Cliente	
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'	
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	--Datos del credito
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'	
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case cre.cCodTipMon
	when '1' then 'SOLES'
	when '2' then 'DOLARES'
	end AS 'MONEDA'
	,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SALDO'
    ,CRE.nTasintCom
	,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 
	,O.cDesOficin
	,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'			
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
	INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon
	INNER JOIN [GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN [GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [GentZonas] zon
		ON goz.nCodZona = zon.nCodZona
	inner JOIN [sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna	
	--INNER JOIN [KPYDPLANPAGCRE] A
	--		ON A.cCodCtaCre = CRE.cCodCtaCre	
WHERE CRE.cEstCreCon = 'F'		
	AND cre.cCodTipMon = '2'
	 and ((CRE.cCodTipCre = '04' and STC.lEstado = 1))
	 --AND A.cCodEstCuo = 'P'
	 --and CRE.cCodCtaCre = '107001102013016016'
	 ) as tmp99
--ORDER BY CRE.cCodTipCre ASC
--(75 row(s) affected)
--/*
--cCodSolCre
select len(CODIGO_CREDITO) from #tmpv01
select * from #tmpv01
--select * from #tmpv01 order by Secuencia asc

select max(cNumCuoPla)--*--count(cNumCuoPla) as 'CuotaPagadas'
from [KPYDPLANPAGCRE] 
where cCodCtaCre = '107001102013016016'  and cCodEstPla ='E'  and cCodEstCuo = 'P' --and dFecPagCuo is not null
--144
107001102014261627
107001102014273151

select max(cNumCuoPla)--*--count(cNumCuoPla)
from [KPYDPLANPAGCRE] 
where cCodCtaCre = '107001102013016016'  and cCodEstPla ='E' 
	
--and dFecPagCuo is null
--and dFecPagCuo is not null and cCodEstCuo = 'P'
--136
drop table #tmpv01

alter table #tmpv01
add CuotaPagadas int

alter table #tmpv01
add CuotaProgramadas int

alter table #tmpv01
add DiasAtraso int

select * from #tmpv01

SELECT * into #tmpv02 FROM  ( select * from #tmpv01) as tmp98
delete from #tmpv02
drop table #tmpv02
select * from #tmpv02


--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpv01_cCodSolCre_IXN ON #tmpv01(cCodSolCre)
CREATE NONCLUSTERED INDEX #tmpv02_cCodSolCre_IXN ON #tmpv02(cCodSolCre)
--------------------****************************************************************************

--CURSOR #TMP_CREMICRO
Declare @cCodCtaCre varchar(18), @cuotasprog int, @cuotaspag int, @diasatraso int
Declare cCursor11 CURSOR FOR
	select CODIGO_CREDITO from #tmpv01
OPEN cCursor11
FETCH cCursor11 into @cCodCtaCre
WHILE (@@FETCH_STATUS=0)
BEGIN
	set @cuotaspag = (select max(cNumCuoPla) from [KPYDPLANPAGCRE] 
						where cCodCtaCre = @cCodCtaCre  and cCodEstPla ='E'  
						and cCodEstCuo = 'P')

	set @cuotasprog = (select max(cNumCuoPla) from [KPYDPLANPAGCRE] 
						where cCodCtaCre = @cCodCtaCre  and cCodEstPla ='E' )

	set @diasatraso = (SELECT nDiaVenCuo FROM [KPYDPLANPAGCRE] 
						where cCodCtaCre=@cCodCtaCre and cCodEstPla ='E' 
							and cCodEstCuo ='P' 
							and cNumCuoPla = (select max(cNumCuoPla) 
												FROM [KPYDPLANPAGCRE] 
												where cCodCtaCre=@cCodCtaCre
												and cCodEstPla ='E' and cCodEstCuo ='P'))
		Update #tmpv02 			 										
		Set CuotaPagadas = @cuotaspag 
		where CODIGO_CREDITO = @cCodCtaCre
		
		Update #tmpv02 			 										
		Set CuotaProgramadas = @cuotasprog
		where CODIGO_CREDITO = @cCodCtaCre	

		Update #tmpv02 			 										
		Set DiasAtraso = @diasatraso
		where CODIGO_CREDITO = @cCodCtaCre	

FETCH cCursor11 INTO @cCodCtaCre
END
CLOSE cCursor11
DEALLOCATE cCursor11
-------------------------------------------------------
select * from #tmpv02 


DROP TABLE #tmpv01
DROP TABLE #tmpv02
-------------------------------------------------------
--delete from #tmpv02
