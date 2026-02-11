Use SOFCMACHYO_201503

Select STC.cCodTipCre, STC.cDesTipCre , STC.cDesSubTip			,STC.cCodProduc, STC.cDesProCre , STC.cCodSubPro,  STC.cDesSubCre, STC.lEstado
From [KPYTSUBTIPCRE] STC
Where STC.lEstado = '1' and cCodTipCre in ('02','03','04','10','11','12','13')
order by cCodTipCre,cCodProduc, cCodSubPro


Select STC.cCodTipCre, STC.cDesTipCre , STC.cDesSubTip ,STC.cCodProduc, STC.cDesProCre , STC.cCodSubPro,  
		STC.cDesSubCre, STC.lEstado
From [KPYTSUBTIPCRE] STC
Where STC.lEstado = '1' 
		and (	(cCodTipCre = '03' and cCodProduc in ('03','13') and cCodSubPro in ('07','08','09','13','16'))
				or (cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro = '06' )  )
order by cCodTipCre,cCodProduc, cCodSubPro

		/*
		Empresarial (Cartas fianza) 
		Consumo (plazos fijos, adelantos de sueldo)
		*/

		---SOLUCION----------
		--01
SELECT * into #tmp_pruebas FROM  (

Select top 100000 
		 CRE.cCodCtaCre, CRE.cCodTipCre ,STC.cDesTipCre, CRE.cCodProduc,  STC.cDesProCre , CRE.cCodSubPro, 
		 STC.cDesSubCre
From [KPYMCRECONVEN] CRE (NOLOCK)
	inner join [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
Where  CRE.cEstCreCon = 'G' 		

) as tmp01

-- Drop Table #tmp_pruebas
		
		--02
SELECT * into #tmp_sacar FROM  ( 
			Select * from #tmp_pruebas (NOLOCK)
			Where  (	(cCodTipCre = '03' and cCodProduc in ('03','13') and cCodSubPro in ('07','08','09','13','16'))
				or (cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro = '06' )  )
) as tmp02
		
		--03
SELECT * into #tmp_pruebas01 FROM  (
		select * 
		from #tmp_pruebas
		where cCodCtaCre not in (Select cCodCtaCre from #tmp_sacar)
) as tmp02

--------------------VERIFICANDO----------------------
		--04	
SELECT * into #tmp_pruebas01 FROM  ( select top 1 * from #tmp_pruebas (NOLOCK) ) as tmp02
SELECT * from #tmp_pruebas01
delete from #tmp_pruebas01
drop table #tmp_pruebas01

select * from #tmp_pruebas01
Where  (	(cCodTipCre = '03' and cCodProduc in ('03','13') and cCodSubPro in ('07','08','09','13','16'))
				or (cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro = '06' )  )
------------------------------------------------------------------------------------------------
--(99597 row(s) affected) 
--(403 row(s) affected) sacar


--------------CONYUGUE-----------------
--No se incluyen si su conyugue tiene créditos. 
		--01
SELECT * into #tmp_V01 FROM (
		SELECT top 1000
			CLIM.cNroDocIde as 'NroDocumento1'
			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
		FROM [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
		Where  CRE.cEstCreCon = 'G' 
	
	) AS tmp99

	select * from #tmp_V01

	--obteniendo data de conyugues
	--02
	SELECT * into #tmp_V02 FROM (
		SELECT 
			CPN.cCodConyug, CPN.cCodCliente,CPN.cApePat,CPN.cApeMat,CPN.cNombre
		FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMPERNAT] CPN (NOLOCK)
		where CPN.cCodConyug in (select CODIGO_CLIENTE from #tmp_V01 (NOLOCK) )
		
	) as tmp98

	select * from #tmp_V02
	
	--conyugues con credito vigentes
	--03
	SELECT * into #tmp_V03 FROM (	
	Select 
			CLIM.cNroDocIde as 'NroDocumento1'
			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
	from [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
	where CLI.cCodCliente in (select cCodCliente from #tmp_V02)
		and CRE.cEstCreCon = 'F' 
	
	) as tmp99
	
	--sacando a clientes con conyugues con credito vigentes
	--04
	select * from #tmp_V02 --(668 row(s) affected) 
	select * from #tmp_V03 --(74 row(s) affected) --esta considerando q un conyugue puede tener varios creditos.
		
	SELECT * into #tmp_V04 FROM (	
	select * from #tmp_V02 X
	where X.cCodCliente in (select Y.CODIGO_CLIENTE from #tmp_V03 Y)
	) as tmp97
	--(55 row(s) affected) --sale menos xq se esta cosiderando el codigo de cliente

	--filtrando de la lista de creditos
	--05
	select * from #tmp_V01
	select * from #tmp_V04
	
	select * from #tmp_V01 X
	where X.CODIGO_CLIENTE not in (select Y.cCodConyug from #tmp_V04 Y)
