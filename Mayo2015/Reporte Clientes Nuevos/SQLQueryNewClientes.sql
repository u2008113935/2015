USE SOFCMACHYO_201503

Select top 5 *
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente

select top 2 * from [KPYMCRECONVEN] CRE (NOLOCK)		
select top 2 * from [GENMCRECLI] CLI 
select top 2 * from CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
--dFecIniSisF	dFecIniCmac
select count(*) from CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
where dFecIniSisF != dFecIniCmac

select count(*) from CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
where dFecReg = dFecIniCmac

----01 CLIENTES NUEVOS 

SELECT * into #TMP_MICRO FROM  (
Select  count(distinct CLIM.cCodCliente)--CLIM.cCodCliente)
	/*
	CLIM.dFecReg, CLIM.cCodCliente, CLIM.cCodOficina, CLIM.cNomCliente--, CLIM.cNomCorCli
	--,CLIM.dFecIniSisF, CLIM.dFecIniCmac
	,isnull(CLIM.cNroDocIde, CLIM.cNroDocTri) as 'NroDocumento'--, CLIM.cUsuMod, CLIM.dFecMod
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
	,CRE.cCodTipCre
	,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
	,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	,CRE.cCodProduc
	,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
	,CRE.cCodSubPro	
	,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
	,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
	*/
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
where CLIM.dFecReg >= '2015-01-01'
		and CLIM.dFecReg <= '2015-02-28'--'2015-03-31'
		--and CRE.cCodTipCre = '02'	
		and CRE.cEstCreCon = 'F'
		AND CRE.dFecDesCre >= '2015-01-01'
	    AND CRE.dFecDesCre <= '2015-02-28'	 
--ORDER BY CLIM.dFecReg
) as tmp
--6120 , 6182
--(3853 row(s) affected)

Select count(distinct cCodCliente) from #TMP_MICRO 
--3836

-----------------------------------------------------------------------
SELECT * into #TMP_CLI FROM  (
SELECT --COUNT(DISTINCT CLI.cCodCliente)
	---/*
	CLIM.dFecReg, CLIM.cCodCliente, CLIM.cNomCliente	
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'	
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
	,CRE.dFecCulCre as 'Fecha_Culminacion_Credito'
	,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,DATEDIFF (day, max( CRE.dFecCulCre) ,MAX(CRE.dFecDesCre)) AS 'DIAS'
	--*/
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon
group by CRE.cEstCreCon, CRE.dFecDesCre, CRE.dFecCulCre, CLIM.cNomCliente	
,CLIM.dFecReg,CLIM.cCodCliente, CRE.cCodCtaCre, EC.cDescriEst
having CRE.cEstCreCon = 'G'--'F'
      --CRE.dFecCulCre < '2014-01-01' 
	  --AND CRE.dFecDesCre >= '2015-01-01'
	  --AND CRE.dFecDesCre <= '2015-02-28'
	  and DATEDIFF (day, max( CRE.dFecCulCre) , CRE.dFecDesCre)  < 365
ORDER BY CRE.dFecCulCre
) AS tmp

--31,506 CLIENTES
--(31,968 row(s) affected) CREDITOS

select * from #TMP_CLI

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #TMP_CLI_cCodCliente_IXN ON #TMP_CLI(cCodCliente)
--**********************************************************************************************

SELECT * into #TMP_CLI01 FROM  (select top 1 * from #TMP_CLI) as tmp99
select * from #TMP_CLI01
delete from #TMP_CLI01

		declare @fecha date
		set @fecha =
		(select max(CRE.dFecCulCre) FROM [KPYMCRECONVEN] CRE (NOLOCK)		
							INNER JOIN [GENMCRECLI] CLI 
									ON CLI.cCodCtaCre = CRE.cCodCtaCre
							INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
									ON CLIM.cCodCliente = CLI.cCodCliente
		where CLIM.cCodCliente = '107010412115'	) 
		--select @fecha
		if @fecha <= '2014-01-01' 
		begin 
		print @fecha
		end
		--else
		--begin
		--print 'no ingresa'
		--end



	-----------OBTENIENDO EL ULTIMO CREDITO CANCELADO-----------
--CURSOR #TMP_CREMICRO
Declare @codcli varchar(16), @codcred varchar(18)
Declare cCremicro CURSOR FOR
	SELECT distinct cCodCliente FROM #TMP_CLI (NOLOCK)
OPEN cCremicro
FETCH cCremicro into @codcli
WHILE (@@FETCH_STATUS=0)
BEGIN
		declare @fecha date
		set @fecha =
		(select max(CRE.dFecCulCre) FROM [KPYMCRECONVEN] CRE (NOLOCK)		
							INNER JOIN [GENMCRECLI] CLI 
									ON CLI.cCodCtaCre = CRE.cCodCtaCre
							INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
									ON CLIM.cCodCliente = CLI.cCodCliente
		where CLIM.cCodCliente = @codcli ) 

		if @fecha <= '2014-01-01' 
		begin 
				INSERT INTO #TMP_CLI01 
				select * from #TMP_CLI where cCodCliente = @codcli
		end 		
FETCH cCremicro INTO @codcli
END
CLOSE cCremicro
DEALLOCATE cCremicro
------------------------------------------------------------------
select * from #TMP_CLI01 --(2137 row(s) affected)

select count(distinct cCodCliente) from #TMP_CLI01 --2123

 


