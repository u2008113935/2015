	/*
	Select * from GENTParEvaVal H (NOLOCK) --GENTParEvaVal
	Where cCodIteReg in ('e')
		 	and H.cCodTipApl = 'KPY'
			AND H.lEstEvaVal = 1

		/*
		ON B.nTipValida = H.nTipValida 
				AND B.cNombrePar = H.cParEvaVal
				AND H.cCodTipApl = 'KPY'
				AND H.lEstEvaVal = 1
		*/

	Select top 3 * 
	FROM KPYMEXCCRE A	(NOLOCK)

	Select top 10 * 
	From KPYDEXEPCRE B	(NOLOCK)
	*/

	----------------------------------------------------------------
		/*
		Select B.nTipValida , H.nTipValida , B.cNombrePar , H.cParEvaVal,
			H.* , B.*
		from GENTParEvaVal H (NOLOCK)
			INNER JOIN KPYDEXEPCRE B
				ON B.nTipValida = H.nTipValida 
				AND B.cNombrePar = H.cParEvaVal
				--AND H.cCodTipApl = 'KPY'
				--AND H.lEstEvaVal = 1
		WHERE H.cCodIteReg IN ('e','m','h')
	----------------------------------------------------------------


		select top 10 cNombrePar,* from KPYDAMPGARCRE
		select top 1 cNombrePar,* from KPYDEXEPCRE
		select top 1 cNombrePar,* from KPYDExoAmplia
		select cNombrePar,* from KPYTDESPARCRE
				select cCodIteReg from KPYTDESPARCRE
				group by cCodIteReg
		select top 10 cNombrePar,* from KPYTParAmpCre
		select top 10 cNombrePar,* from SASDParAfiSeg


		select  cCodIteReg,* from GENTParEvaVal where cDesEvaVal like '%cance%'

		select  cCodIteReg,* from KPYTDESPARCRE

		select * from KPYDSusExeCre S

		*/

	SELECT	--G.cDesEstExc
				A.cNumDocInf
				,M.cCodCliente
				,M.cNomCliente
				,cCodCtaCre = ISNULL(D.cCodCtaCre,'')
				,cDescriEst = ISNULL(cDescriEst,'')
				,cDesTipMon = ISNULL(F.cDesTipMon,'')
				,nMonCapDes = ISNULL(D.nMonCapDes,0.00)
				
				,cDesValReg = H.cDesEvaVal + ' ' + J.cOperadApl + ' ' + B.cValParam + CASE WHEN ISNULL(I.cDesEvaVal,'') = '' 
																							  THEN '' 
																							  ELSE ' de ' + ISNULL(I.cDesEvaVal,'')
																						 END
				
				,B.cValCliente
				,cJusExcCre = CONVERT(VARCHAR(250),REPLACE(ISNULL(RTRIM(LTRIM(A.cJusExcCre)),''),CHAR(10),'-'))
				,A.cCodUsuSol, B.cCodUsuApr, B.dFecAprExc
				,ISNULL(D.dFecDesCre,'')		AS	dFecDesCre
				,ISNULL(K.cDesOficin,'')		AS	cDesOficin
				,cDesTipExc = RTRIM(ISNULL(L.cDesTipExc,''))
				,cDesNorReg =  'Artículo ' + RTRIM(H.cCodArtReg) + ' - Item ' + H.cCodIteReg
				,ISNULL(O.cDesMotSol,'')		AS	cDesMotSol
				,CAST('' AS VARCHAR(50))	AS	CDESRELCTA
				,CAST('' AS CHAR(5))		AS	CCODGARANT
				,CAST('' AS VARCHAR(50))	AS	MONEDAGAR
				,CAST(0.00 AS NUMERIC(14,2))	AS	VALGAR
				,CAST(0.00 AS CHAR)	AS	NMONAMPGAR
				
				,ISNULL(M.cNroDocIde,'')		AS	cNroDocIde
				,ISNULL(M.cNroDocTri,'')		AS	cNroDocTri
				,ISNULL(Q.cDesClaCar,'')		AS	cDesClaCar
				
		--INTO #CUREXCCRE
		FROM KPYMEXCCRE A	(NOLOCK)
			INNER JOIN KPYDEXEPCRE B	(NOLOCK)
				ON A.cCodSolCre = B.cCodSolCre 
			
			left JOIN KPYMSolicitud C	(NOLOCK)
				ON A.cCodSolCre = C.cCodSolCre 
			
			INNER JOIN CMACHYOCLI..CLIMClientes M	(NOLOCK)
				ON C.cCodClient = M.cCodCliente 
			
			LEFT JOIN KPYMCRECONVEN D	(NOLOCK)
				ON C.cCodSolCre = D.cCodSolCre AND D.cEstCreCon	 <> 'X'	
							--AND	D.dFecDesCre IS NOT NULL			
			
			LEFT JOIN KPYTEstCreCon E	(NOLOCK)
				ON D.cEstCreCon = E.cEstCreCon 
			LEFT JOIN GENTMoneda F	(NOLOCK)
				ON D.cCodTipMon = F.cCodTipMon 
			INNER JOIN KPYTEstSolExc G	(NOLOCK)
				ON G.cCodEstExc = B.cEstExepCre 
			
			INNER JOIN GENTParEvaVal H 	(NOLOCK)
				ON B.nTipValida = H.nTipValida 
				--AND B.cNombrePar = H.cParEvaVal
				--AND H.cCodTipApl = 'KPY'
				--AND H.lEstEvaVal = 1
			
			LEFT JOIN GENTParEvaVal I	(NOLOCK)
				ON B.nTipValida = I.nTipValida 
				--AND B.cCamAfePar  = I.cParEvaVal
				--AND I.cCodTipApl = 'KPY'
				--AND I.lEstEvaVal = 1
			INNER JOIN GENDValidaOpe J		(NOLOCK)
				ON J.cCodTipApl = 'KPY'	
				--AND J.nTipValida = B.nTipValida 
				--AND J.nNumValida = B.nNumValida 
				--AND J.nNumDetVal = B.nNumDetVal 
			
			INNER JOIN GENTOficinas K	(NOLOCK)
				ON C.cCodOficin = K.cCodOficin 
			
			INNER JOIN GENTTipExc L	(NOLOCK)
				ON H.cCodTipExc = L.cCodTipExc
				--AND L.lEstTipExc = 1
			
			LEFT JOIN KPYDSusExeCre S	(NOLOCK)
				ON B.nNumExep = S.nNumExep
				--AND S.cCodTipSus != '0'
			INNER JOIN KPYTMotSolici O	(NOLOCK)
				ON o.cCodMotSol = C.cCodMotSol
			
			LEFT JOIN KPYTClaCarter Q
				ON Q.cCodClaCar	=	D.cCodClaCar
		WHERE --C.cCodOficin LIKE @x_cCodOficin
			--AND
			B.cEstExepCre	=	'B'	-- HABILITADO
			--AND D.dFecDesCre BETWEEN @x_dFecIniRep AND @x_dFecFinRep
			and D.dFecDesCre >= '2015-04-01'
			AND D.dFecDesCre <= '2015-06-30'		
			AND S.nNumExep IS NULL		
		--ORDER BY C.cCodOficin --, cNomCliente	

		--Select * from #CUREXCCRE


		-------------------------------------------------------------------------
			SELECT top 5 *
			FROM KPYDSusExeCre 

			SELECT top 5 *
			FROM GENTTipSusPar

			SELECT  *
			FROM GENTParEvaVal
					
					SELECT  cCodIteReg
					FROM GENTParEvaVal
					group by cCodIteReg

			SELECT top 5 *
			FROM KPYDEXEPCRE

			select * from KPYTDESPARCRE
					select cCodIteReg from KPYTDESPARCRE
					Group by cCodIteReg

			-----------------------------
			select * from KPYMEXCCRE A	(NOLOCK)
			
			select * from KPYDEXEPCRE B	(NOLOCK)

			select * from GENDValidaOpe

			select * from GENTTipExc

		
