-- DROP TABLE CALISBSV02
Select * from CALISBSV02
Where CCODSBS = '0141780506'

	
-- Drop table ClienV01
select * from ClienV01

	SELECT * into resul from (
		select A.*  --B.*
			,case when CaliAbr15 = '0' then 'Normal' end as 'CaliAbr15' 
			,case when CaliMar15 = '0' then 'Normal' end as 'CaliMar15' 
			,case when CaliFeb15 = '0' then 'Normal' end as 'CaliFeb15'
			,case when CaliEne15 = '0' then 'Normal' end as 'CaliEne15' 
			,case when CaliDic14 = '0' then 'Normal' end as 'CaliDic14'
			,case when CaliNov14 = '0' then 'Normal' end as 'CaliNov14' 
			,case when CaliOct14 = '0' then 'Normal' end as 'CaliOct14'
			,case when CaliSep14 = '0' then 'Normal' end as 'CaliSep14' 
			,case when CaliAgo14 = '0' then 'Normal' end as 'CaliAgo14'
			,case when CaliJul14 = '0' then 'Normal' end as 'CaliJul14' 
			,case when CaliJun14= '0' then 'Normal' end as 'CaliJun14'
			,case when CaliMay14= '0' then 'Normal' end as 'CaliMay14' 
		from [ClienV01] A
			inner JOIN  [CALISBSV02] B
				ON A.cCodSbs = B.CCODSBS
		Where B.CaliAbr15 ='0' and B.CaliMar15 = '0' AND  B.CaliFeb15 = '0' 
			AND B.CaliEne15 = '0' AND B.CaliDic14 = '0' AND B.CaliNov14 = '0' 
			AND  B.CaliOct14 = '0' AND B.CaliSep14 = '0' AND B.CaliAgo14 = '0' 
			AND B.CaliJul14 = '0' AND B.CaliJun14 = '0' and CaliMay14 = '0'
			--order by dFecReg , NroDocumento
			) as tmp

			
			select * from resul
			WHERE cCodCtaCre = '107010101003827797'
					AND cCodCliente = '107010631185'

			select cCodCtaCre, COUNT(cCodCtaCre)
			from resul
			GROUP BY cCodCtaCre
			HAVING COUNT(cCodCtaCre) > 1

			select cCodCliente, COUNT(cCodCliente)
			from resul
			GROUP BY cCodCliente
			HAVING COUNT(cCodCliente) > 1

			select count(distinct cCodCliente) from resul

	--AGREGANDO AGENCIAS AL REPORTE
	-- Drop table resulV01	
	Select * into resulV01 from (
			Select 
				A.dFecReg, A.cNomCliente, A.cCodSbs, A.cCodCliente, A.NroDocumento, A.cCodCtaCre
				,A.TasaInteres, A.TasaCostoEfectivoAnual				
				, A.cCodTipCre, A.TipoCredito
				,A.SubTipoCredito, A.cCodProduc, A.ProductoCrediticio, A.cCodSubPro
				,A.SubProductoCrediticio, A.EstadoCredito, A.Antig, A.PromDiaAtr
				,O.cCodOficin, O.cDesOficin, ZON.nCodZona, ZON.cDesZona
				,A.CaliAbr15, A.CaliMar15, A.CaliFeb15, A.CaliEne15, A.CaliDic14, A.CaliNov14
				,A.CaliOct14, A.CaliSep14, A.CaliAgo14, A.CaliJul14, A.CaliJun14, A.CaliMay14
			from [resul] A
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[KPYMCRECONVEN] B (NOLOCK)		
					ON B.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS = A.cCodCtaCre
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[GENTOficinas] O 
					ON O.cCodOficin = B.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona
			) as tmp

		SELECT * FROM resulV01

	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX resulV01_cCodCliente_IXN ON resulV01(cCodCliente)	
	--------------------****************************************************************************	
	-- Drop table resulV01
	-- Drop table resulV02
	SELECT * into resulV02 from (
	Select 
		--A.dFecReg,
		A.cNomCliente, A.cCodSbs, A.cCodCliente, A.NroDocumento--, A.cCodCtaCre
		,B.cCodCtaCre ,B.dFecDesCre		
		,case B.cCodTipMon
		 when '1' then B.nMonCapDes
		 when '2' then B.nMonCapDes * 3.15
		 end AS 'MontoDesembSoles' 
		--, A.TasaInteres, A.TasaCostoEfectivoAnual
		,B.nTasIntCom as 'TasaInteres'--, B.nCosEfeAct as 'TasaCostoEfectivoAnual'
		, A.cCodTipCre, A.TipoCredito
		,A.SubTipoCredito, A.cCodProduc, A.ProductoCrediticio, A.cCodSubPro	,A.SubProductoCrediticio
		--, A.EstadoCredito
		,D.cDescriEst 
		--,A.Antig	
		, A.PromDiaAtr, A.cCodOficin, A.cDesOficin, A.nCodZona, A.cDesZona
		, A.CaliAbr15
		,A.CaliMar15, A.CaliFeb15, A.CaliEne15, A.CaliDic14, A.CaliNov14, A.CaliOct14
		,A.CaliSep14, A.CaliAgo14, A.CaliJul14, A.CaliJun14, A.CaliMay14
	From resulV01 A (NOLOCK)
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[GENMCRECLI] C (NOLOCK)
				ON C.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS  = A.cCodCliente
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[KPYMCRECONVEN] B (NOLOCK)		
				ON B.cCodCtaCre = C.cCodCtaCre
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.DBO.[KPYTEstCreCon] D
				ON D.cEstCreCon = B.cEstCreCon		
	WHERE B.cEstCreCon IN ('F','G')
			AND A.cCodTipCre != '04'
			AND A.cCodTipCre != '03'
	--Order by A.cCodCliente
	) as tmp		  	  
		   
	select * from resulV02
	WHERE cCodCliente = '107010000761'
	--where TasaInteres is null
	order by cCodCliente
		
		--validando
			select cCodCtaCre, COUNT(cCodCtaCre)
			from resulV02
			GROUP BY cCodCtaCre
			HAVING COUNT(cCodCtaCre) > 1

			select count(distinct cCodCliente) from resulV02			
			
		-- select cCodTipCre from resulV02 group by cCodTipCre

			/* -- VALIDANDO ANIOS DE ANTIGUEDAD
			Select 
				B.dFecIniSisF , B.dFecIniCmac  
				,A.* 
			From resulV02 A 
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] B
					ON B.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS  = A.cCodCliente	
			WHERE A.cCodCliente	= '107011425730'

			select * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] 
			WHERE cCodCliente	= '107011425730'

			Select dFecDesCre,cEstCreCon,* 
			from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] 
			Where cCodCtaCre = '107062101000101819' -- '107006101001842070'
			*/
			
			select *
			from [resulV02] A
			where cCodCliente = '107010000761'
			order by dFecDesCre
				and dFecDesCre in (select min(dFecDesCre) from [resulV02] 
									where cCodCliente = '107010000761')

			-- dFecDesCre : 2000-04-27 00:00:00.000

  select * into resulV03 from (
	select 
	cNomCliente,cCodSbs,cCodCliente,NroDocumento,count(cCodCtaCre) as 'CantCreditos'
	,min(dFecDesCre) as 'FecDesem'
	,avg(MontoDesembSoles) as 'PromedioMontoDesem'
	,avg(TasaInteres) as 'TasaInteres',cCodTipCre,TipoCredito,SubTipoCredito,cCodProduc
	,ProductoCrediticio,cCodSubPro,SubProductoCrediticio,PromDiaAtr
	,cCodOficin, cDesOficin, nCodZona, cDesZona
	,CaliAbr15
	,CaliMar15,CaliFeb15,CaliEne15,CaliDic14,CaliNov14,CaliOct14,CaliSep14,CaliAgo14,CaliJul14
	,CaliJun14,CaliMay14 
	from resulV02
	group by 
	cNomCliente,cCodSbs,cCodCliente,NroDocumento
	,cCodTipCre,TipoCredito,SubTipoCredito,cCodProduc
	,ProductoCrediticio,cCodSubPro,SubProductoCrediticio,PromDiaAtr
	,cCodOficin, cDesOficin, nCodZona, cDesZona
	,CaliAbr15
	,CaliMar15,CaliFeb15,CaliEne15,CaliDic14,CaliNov14,CaliOct14,CaliSep14,CaliAgo14,CaliJul14
	,CaliJun14,CaliMay14		
	--order by cCodCliente
	) as tmp
	
	Select  
		A.cNomCliente, A.cCodSbs, A.cCodCliente, A.NroDocumento, A.CantCreditos, A.FecDesem
		--,year(getdate()), year(A.FecDesem)
		,(year(getdate()) - year(A.FecDesem)) AS 'AntigAnios'
		,A.PromedioMontoDesem, A.TasaInteres, A.cCodTipCre, A.TipoCredito, A.SubTipoCredito
		,A.cCodProduc, A.ProductoCrediticio, A.cCodSubPro, A.SubProductoCrediticio, A.PromDiaAtr
		,A.cCodOficin, A.cDesOficin, A.nCodZona, A.cDesZona, A.CaliAbr15, A.CaliMar15, A.CaliFeb15
		,A.CaliEne15, A.CaliDic14, A.CaliNov14, A.CaliOct14, A.CaliSep14, A.CaliAgo14, A.CaliJul14
		,A.CaliJun14, A.CaliMay14
	From [resulV03] A
	Order By A.cNomCliente


			