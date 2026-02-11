Use SGN

--CREACION TABLA MAESTRA DESERTORES
--Drop table MDESERV01
SELECT * into MDESERV01 FROM (Select TOP 1 * from AGVESV02) as tmp
select * from MDESERV01
--delete from MDESERV01

--insertando 
--ZONA LIMA NORTE
/*
	--AGVESV02	
		INSERT INTO MDESERV01
		select * from AGVESV02
	--AGSMPV02	
		INSERT INTO MDESERV01
		select * from AGSMPV02
	--AGSJMV02
	INSERT INTO MDESERV01
	select * from AGSJMV02
	--AGMIRAFLORESV02
	INSERT INTO MDESERV01
	select * from AGMIRAFLORESV02
	--AGLOSOLIVOSV02
	INSERT INTO MDESERV01
	select * from AGLOSOLIVOSV02
	--AGHUARALV02
	INSERT INTO MDESERV01
	select * from AGHUARALV02
	--AGHUACHOV02
	INSERT INTO MDESERV01
	select * from AGHUACHOV02
	--AGCARABAYLLOV02
	INSERT INTO MDESERV01
	select * from AGCARABAYLLOV02
	--AGBARRANCAV02
	INSERT INTO MDESERV01
	select * from AGBARRANCAV02
	--AGCOMASV02
	INSERT INTO MDESERV01
	select * from AGCOMAS03
---Zona Centro
	--Ag Real
		INSERT INTO MDESERV01
		Select * from AGREALV02
	--Ag REALHUANUCO	
		INSERT INTO MDESERV01
		Select * from AGREALHUANUCOV02
	--Ag AGREALCAJAMARCA
		INSERT INTO MDESERV01
		SELECT * FROM AGREALCAJAMARCAV02
	--Ag AGMERCADOV02	
		INSERT INTO MDESERV01
		select * from AGMERCADOV02
	--AGHUANCAS02	
		INSERT INTO MDESERV01
		select * from AGHUANCAS02
---Zona LIMA SUR
	--AGABANCAYLIMAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGABANCAYLIMAV02
	--AGCANTOGRANDEV02
		INSERT INTO MDESERV01
		select * from AGCANTOGRANDEV02
	--AGCANETEV02
		INSERT INTO MDESERV01
		select * from AGCANETEV02
	--AGCHINCHAV02
		INSERT INTO MDESERV01
		select * from AGCHINCHAV02
	--AGCHOSICAV02
		INSERT INTO MDESERV01
		select * from AGCHOSICAV02
	--AGHUACHIPAV02
		INSERT INTO MDESERV01
		select * from AGHUACHIPAV02
	--AGHUAYCANV02
		INSERT INTO MDESERV01
		select * from AGHUAYCANV02
	--AGICAV02
		INSERT INTO MDESERV01
		select *  from AGICAV02
	--AGATEV02
		INSERT INTO MDESERV01
		select * from AGATEV02
	--AGSJLV02
		INSERT INTO MDESERV01
		select * from AGSJLV02
	--AGSANSEBASTIANV02
		INSERT INTO MDESERV01
		select * from AGSANSEBASTIANV02
	--AGSANTAANITAV02
		INSERT INTO MDESERV01
		select * from AGSANTAANITAV02
	--AGWANCHAQV02
		INSERT INTO MDESERV01
		select * from AGWANCHAQV02

--zona CENTRO ORIENTE	
	--AGHUANUCOV02
		INSERT INTO MDESERV01
		SELECT * FROM AGHUANUCOV02
	--AGCARHUAMAYOV02
		INSERT INTO MDESERV01
		SELECT * FROM AGCARHUAMAYOV02
	--AGAGUAYTIAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGAGUAYTIAV02
	--AGHUANUCOIIV02
		INSERT INTO MDESERV01
		SELECT * FROM AGHUANUCOIIV02
	--AGJUNINV02
		INSERT INTO MDESERV01
		SELECT * FROM AGJUNINV02
	--AGLAOROYAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGLAOROYAV02
	--AGPASCOV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPASCOV02
	--AGPUCALLPAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPUCALLPAV02
	--AGPUERTOBERMUDEZV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPUERTOBERMUDEZV02
	--AGSANJUANPASCOV02
		INSERT INTO MDESERV01
		SELECT * FROM AGSANJUANPASCOV02
	--AGTINGOMARIAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGTINGOMARIAV02
	--AGTOCACHEV02
		INSERT INTO MDESERV01
		SELECT * FROM AGTOCACHEV02

--zona selva central
	--AGTARMAV02
		INSERT INTO MDESERV01
		select * from AGTARMAV02
	--AGATALAYAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGATALAYAV02
	--AGLAMERCEDV02
		INSERT INTO MDESERV01
		SELECT * FROM AGLAMERCEDV02
	--AGMAZAMARIV02
		INSERT INTO MDESERV01
		SELECT * FROM AGMAZAMARIV02
	--AGOXAPAMPAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGOXAPAMPAV02
	--AGPANGOAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPANGOAV02
	--AGPERENEV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPERENEV02
	--AGPICHANAKIV02
		INSERT INTO MDESERV01
		SELECT * FROM AGPICHANAKIV02
	--AGSANRAMONV02
		INSERT INTO MDESERV01
		SELECT * FROM AGSANRAMONV02
	--AGSATIPOV02
		INSERT INTO MDESERV01
		SELECT * FROM AGSATIPOV02
	--AGVILLARICAV02
		INSERT INTO MDESERV01
		SELECT * FROM AGVILLARICAV02
*/
		
select * from MDESERV01 where cCodOficin = '057'
select cCodOficin from MDESERV01 GROUP BY cCodOficin 

		--- cambios el 31 de julio 2015
		select * from MDESERV01 ORDER BY CODIGO_CLIENTE

		Select * from MDESERV02

		
		select * --A.*, B.* 
		from MDESERV01 A
			inner join MDESERV02 B
				on RTRIM(A.NroDocumento1) = RTRIM(B.NroDocumento1)
		




--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX MDESERV01_CODIGO_CLIENTE_IXN ON MDESERV01(CODIGO_CLIENTE)
--------------------****************************************************************************

	--SELECT * FROM #TMP
	-- Drop table #TmpSGN01

	SET LANGUAGE spanish;

	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')	


	SELECT * into #TmpSGN01 FROM  (
	
			SELECT 
				Anio=DATENAME(year, left(cast(CRE.dFecDesCre as date),10))
				,Mes =DATENAME(month, left(cast(CRE.dFecDesCre as date),10))
				--Datos del Cliente	
				,isnull(CLIM.cNroDocIde,CLIM.cNroDocTri) as 'NroDocumento'
				,CLI.cCodCliente AS 'CodigoCliente'
				,CLIM.cNomCliente AS 'NombreCliente'
				--DATOS DEL CREDITO
				,CRE.cCodCtaCre AS 'CodigoCredito'
				,CRE.nMonCapDes as 'MontoDesembolso' 
				,CRE.nTasIntCom as 'TasaInteres'						
				,CRE.nCosEfeAct as 'TasaCostoEfectivoAnual'
				,case CRE.cCodTipMon 
				 When '1' then 'SOLES'
				 WHEN '2' THEN 'DOLARES'
				 END as 'MONEDA'
				,CRE.nMonintPro as 'MontoInteresAprobado'
				,CRE.nMonintFec as 'MontoInteresAlaFecha'
				,CRE.nMonintPag as 'MontoInteresPagado'
				,EC.cDescriEst AS 'EstadoCredito'
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
				,left(cast(CRE.dFecCulCre as date),10) as 'FechaCulminacionCredito'
				,CRE.nNumCuoApr as 'NroCuotasAprobadas'
				
				,MontoDesembEnSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN CRE.nMonCapDes
					WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END										
				,SaldoCapEnSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
					WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
					END						
					
				,case CRE.cCodPlazo				
				 when '1' then 'CORTO PLAZO'
				 when '2' then 'LARGO PLAZO'
				 END as 'Plazo'
				 ,CRE.cCodTipCre
				 ,STC.cDesTipCre AS 'TipoCredito'
				 ,STC.cDesSubTip AS 'SubTipoCredito'
				 ,CRE.cCodProduc
				 ,STC.cDesProCre AS 'ProductoCrediticio' 
				 ,CRE.cCodSubPro	
				 ,STC.cDesSubcRE AS 'SubProductoCrediticio'		
	 			 ,CRE.cCodOficin, O.cDesOficin AS 'NombreAgencia' , ZON.cDesZona
				 ,CRE.cCodUsuAna AS 'CodigoAnalista'--COD ANALISTA
				 ,SP.cNomPerson AS 'NombreAnalista'--NOMBRE ANALISTA  
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
						ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
						ON EC.cEstCreCon = CRE.cEstCreCon
				inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
						ON SP.cCodPerson = CRE.cCodUsuAna
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
						ON O.cCodOficin = CRE.cCodOficin
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
						ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
						AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'		
		
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[Gentofizonas] GOZ
						ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZonas] ZON
						ON ZON.nCodZona = GOZ.nCodZona			
			WHERE CLI.cCodCliente  COLLATE SQL_Latin1_General_CP1_CI_AS	
					in ( Select CODIGO_CLIENTE from MDESERV01 )
							--where Zona = 'ZONA LIMA SUR' )					
						--AND CRE.cEstCreCon = 'F'
					AND left(cast(CRE.dFecDesCre as date),10) >= '2015-04-01'
			--ORDER BY CLI.cCodCliente

	) as tmp


		Select * from #TmpSGN01 
		order by FechaDesembolsoCredito
			-- (1,614 row(s) affected) EL 30-06-2015
			-- (1,963 row(s) affected) EL 31-07-2015
		
		Select 
			ROW_NUMBER() 
			OVER(PARTITION BY Anio
			ORDER BY FechaDesembolsoCredito) as 'Nro'
			,* 
		from #TmpSGN01

--------------SOLO LIMA SUR-------------------------
		select * from MDESERV01 where Zona = 'ZONA LIMA SUR' 
		ORDER BY CODIGO_CLIENTE

--------------SOLO CENTRO-------------------------
		select * from MDESERV01 where Zona = 'ZONA CENTRO' 
		ORDER BY CODIGO_CLIENTE

--------------SOLO CENTRO ORIENTE-------------------------
		select * from MDESERV01 where Zona = 'ZONA CENTRO ORIENTE' 
		ORDER BY CODIGO_CLIENTE

--------------SOLO SELVA CENTRAL-------------------------
		select * from MDESERV01 where Zona = 'ZONA SELVA CENTRAL' 
		ORDER BY CODIGO_CLIENTE

--------------SOLO LIMA NORTE-------------------------
		select * from MDESERV01 where Zona = 'ZONA LIMA NORTE' 
		ORDER BY CODIGO_CLIENTE