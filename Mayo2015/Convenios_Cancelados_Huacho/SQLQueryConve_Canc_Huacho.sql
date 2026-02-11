	SELECT 
			CLIM.cCodSbs AS 'COD_SBS1'
			,CLIM.cNroDocIde as 'NroDocumento1'

			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	
			,C.cDirCliente AS 'Direccion_Cliente' 
			,isnull(C.cDirCliRef,'') as 'Direccion_Referencia_Cliente'
			,DEP.cNomDepart AS 'Departamento_Cliente'
			,pro.cNomProvin AS 'Provincia_Cliente'
			,dis.cNomDistri AS 'Distrito_Cliente'
			,isnull(CLIM.cNroTelPer,'') AS 'Nro_Telefono_Personal'

			--DATOS DEL CREDITO
			,A.cCodCtaCre AS 'CODIGO_CREDITO'
			,A.nMonCapDes as 'MONTO_DESEMBOLSADO' 			
			,CASE A.cCodTipMon
			 WHEN '1' THEN 'SOLES' 
			 WHEN '2' THEN 'DOLARES'
			 ELSE '0' 
			 END AS 'MONEDA'
			,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'	
			,A.dFecDesCre as 'Fecha_Desembolso_Credito'
			,A.dFecCulCre as 'Fecha_Culminacion_Credito'				
			,B.cDesConven AS cDesConven
			,O.cDesOficin AS cDesOficin
			,A.cCodConven
		INTO #tmpCon  -- DROP TABLE #tmpCon				
	FROM [KPYMCreConven] A 
		INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre
		INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN KPYTEstCreCon EC 
		    	ON EC.cEstCreCon = A.cEstCreCon
		
		--UBIGEO DEL CLIENTE
		LEFT JOIN CMACHYOCLI.DBO.[CLIMDirecc] C
				ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
		INNER JOIN [GenTDepartame] dep
				ON DEP.cCodDepart = C.cCodDepart
		INNER JOIN [GentProvincia] pro
				ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
		INNER JOIN [GentDistrito] dis
				ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
				and dis.cCodDepart = C.cCodDepart

		INNER JOIN KPYMConvenios B 
				ON A.cCodConven = B.cCodConven 
		INNER JOIN GENTOficinas O
				ON SUBSTRING(A.cCodCtaCre,4,3) = O.cCodOficin
	WHERE A.cEstCreCon = 'G'--IN ('F','H') 
			AND A.cCodConven <> 'XXXXXX'
			and O.cCodOficin = '041'			
	ORDER BY CLI.cCodCliente 

	--(5880 row(s) affected)

	select * from #tmpCon

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpCon_COD_CLIENTE_IXN ON #tmpCon(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #tmpCon_COD_SBS1_IXN ON #tmpCon(COD_SBS1)
CREATE NONCLUSTERED INDEX #tmpCon_CODIGO_CREDITO_IXN ON #tmpCon(CODIGO_CREDITO)
--------------------****************************************************************************

SELECT * FROM #tmpCon (NOLOCK) 	
	--DROP TABLE #tmpCon
	
	ALTER TABLE #tmpCon
	ADD PromDiaAtr int 

	SELECT * into #tmpCon01 FROM  ( SELECT TOP 1 * FROM #tmpCon) AS Tmp98
	DELETE FROM #tmpCon01
	--DROP TABLE #tmpCon01
	
	SELECT * FROM #tmpCon01 (NOLOCK) --

--***************************cursor promedio dias de atraso-----------
		Declare @ccodcred varchar(18), @diaatr int		
			Declare cDiaAtraso CURSOR FOR	
			SELECT CODIGO_CREDITO FROM #tmpCon (NOLOCK) 	

			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @diaatr =  (SELECT round(avg(cast(nDiaVenCuo as float)),0)
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
								WHERE PLA.cCodCtaCre = @ccodcred )																																													

				INSERT INTO #tmpCon01
					SELECT * FROM #tmpCon (NOLOCK) 
					WHERE CODIGO_CREDITO = @ccodcred

				UPDATE #tmpCon01
				SET PromDiaAtr = @diaatr
				WHERE CODIGO_CREDITO = @ccodcred		
				
				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso

----------------VERIFICANDO---------------------------
			
			SELECT * FROM #tmpCon01 (NOLOCK)--DATA FILTRADA
			--(5880 row(s) affected)
-------------------------------------------------------------
		  SELECT * FROM #tmpCon01 where NroDocumento1 IS NULL

		  	  ------------CURSOR COMPLETANDO nro doc null-----------
				Declare @ccodcli01 varchar(12)
				Declare cNrodoc CURSOR FOR							
					 SELECT CODIGO_CLIENTE FROM #tmpCon01 (NOLOCK)  
					 where NroDocumento1 IS NULL					
				OPEN cNrodoc
				FETCH cNrodoc into @ccodcli01
				WHILE (@@FETCH_STATUS=0)
				BEGIN										
					UPDATE #tmpCon01
					SET NroDocumento1 = (SELECT cNroDocTri 
										 FROM  CMACHYOCLI.dbo.[CLIMCLIENTES]
										 WHERE cCodCliente = @ccodcli01)
					WHERE CODIGO_CLIENTE = @ccodcli01
				FETCH cNrodoc INTO @ccodcli01
				END
				CLOSE cNrodoc
				DEALLOCATE cNrodoc
		------------------------VERIFICANDO----------------
		  --SELECT * FROM #CREMICROCANC where CODIGO_CLIENTE = '107012075756'
		  SELECT * FROM #tmpCon01 where NroDocumento1 IS NULL --0

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpCon01_COD_CLIENTE_IXN ON #tmpCon01 (CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #tmpCon01_COD_SBS1_IXN ON #tmpCon01 (COD_SBS1)
CREATE NONCLUSTERED INDEX #tmpCon01_CODIGO_CREDITO_IXN ON #tmpCon01 (CODIGO_CREDITO)
--------------------****************************************************************************

	ALTER TABLE #tmpCon01
	ADD RCC_MAR2015 VARCHAR(12)

	--ALTER TABLE #tmpCon01
	--DROP COLUMN RCC_MAR2014

	SELECT * FROM #tmpCon01

	---------------*******CURSOR CLASIFICACION RCC****************----------------------------------
				Declare @ccodcliente varchar(12), @mar2015 char(12) 
				Declare cClienteRCC CURSOR FOR					
					SELECT CODIGO_CLIENTE
					FROM  #tmpCon01 (NOLOCK) 							
				OPEN cClienteRCC
				FETCH cClienteRCC into @ccodcliente
				WHILE (@@FETCH_STATUS=0)
				BEGIN		
					--SET @ccodcliente = '107010613779'--'107010614033'

					set @mar2015 = 
					(SELECT Z.CDESQUECARF 
					FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 										
					WHERE CCODFECMES = '201503' AND CCODCLIENTE = @ccodcliente ) 					
					
					IF @mar2015 <> ''
					BEGIN		
								Update #tmpCon01
								Set RCC_MAR2015 = @mar2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	
					ELSE IF @mar2015 IS NULL
					BEGIN
								Update #tmpCon01
								Set RCC_MAR2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
																			
				
				FETCH cClienteRCC INTO @ccodcliente
				END
				CLOSE cClienteRCC
				DEALLOCATE cClienteRCC									
			
            -------------------------VALIDANDO----------------------
			
			SELECT * from #tmpCon01 (NOLOCK)
-------------------------------------------------------------
		SELECT	cEstCreCon ,
				 SUM(nNroCredS) AS nNroCredS,
				 SUM(nNroCredD)AS nNroCredD,
				 SUM(nMonSol)AS nMonSol,
				 SUM(nMonDol)AS nMonDol,
				 SUM(nMonDolC)AS nMonDolC,
				 cCodOficin,
				 MAX(cDesConven)AS cDesConven,
				 MAX(cDesOficin)AS cDesOficin, 
				cCodConven
		INTO 	#tmpConvenios 
		FROM #tmpCon
		GROUP BY cCodOficin, cCodConven, cEstCreCon
		ORDER BY cCodOficin, cEstCreCon, cDesConven

		SELECT TMP.*,
			   cTituloRep= SPACE(100),
			   lEsConven = CONVERT(CHAR(1),
			   XXX.lEsConvenio), 
			   lDctoPlan = CONVERT(CHAR(1),
			   XXX.lDctoPlanilla)
		FROM #tmpConvenios TMP 
				INNER JOIN (SELECT lEsConvenio, lDctoPlanilla, cCodConven  
								FROM KPYMCONVENIOS)  AS XXX
					ON(TMP.CCODCONVEN = XXX.CCODCONVEN)
