/***********************************************************************************************************************************************************************************************
*	Objetivo : Reporte de prendas adjudicadas
*	Sistema / Modulo:	VITALIS / CREDITOS
*	Modificaciones:    
*		Fecha  		Responsable		Descripcion del cambio
*	2007-11-12		GLOPEZ			Consulta con la tabla CLIMCLIENTES
	2013-06-21		EMEZAP			SE MODIFICO SP Y SE AGREGO CAMPO cCodLinCre
*	Sintaxis de ejemplo:  
		EXEC KPR_RepPreAdjMen_sp '002'
			 KPR_RepPreAdjMen_sp
*
***********************************************************************************************************************************************************************************************/  
  SET LANGUAGE spanish;
  Select * into #adj from(
  
	SELECT 
				/*
				ROW_NUMBER() 
				OVER(PARTITION BY Anio=DATENAME(year, left(cast(A.dFecAdjKpr as date),10))
				ORDER BY Anio=DATENAME(year, left(cast(A.dFecAdjKpr as date),10)) ) as 'Anio'
				*/
				Anio=DATENAME(year, left(cast(A.dFecAdjKpr as date),10))
				,Mes =DATENAME(month, left(cast(A.dFecAdjKpr as date),10))
				,FecchaAdj = left(cast(A.dFecAdjKpr as date),10)
				,B.cCodCliente 
				, cli.cNroDocIde, cNomCliente = cli.cNomCliente 
				, A.cCodCtaKpr, B.cCodLinCre 				
				, C.nCanPieKpr, C.cDetPreKpr, C.nPesGraBru, C.nPesGraNet --, A.nMonSalAct
				, A.nValHisKpr, cDesTipMon, O.cDesOficin, cDesEstKpr						
		--INTO #curDetAdj
		FROM KPRDCtaAdj  A (NOLOCK)
			INNER JOIN GENMCreCli B (NOLOCK)
				ON A.cCodCtaKpr = B.cCodCtaCre
					--AND cCodEstKpr = 'J' 
			INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
				ON B.cCodCliente = cli.cCodCliente
			INNER JOIN KPRDAdjudiTas C (NOLOCK)
				ON A.cCodCtaKpr = C.ccodCtaKpr
			INNER JOIN KPRMCrePrenda D (NOLOCK)
				ON cCodCtaCre = D.cCodCtaKpr 
					--AND D.ccodoficin= '002' --@x_cCodOficin
			INNER JOIN GENTMONEDA M
				ON D.cCodTipMon = M.cCodTipMon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = D.ccodoficin
			INNER JOIN KPRTESTCREDITO ES
				ON ES.cCodEstKpr = A.cCodEstKpr
		Where A.cCodEstKpr = 'J' --J	ADJUDICADO  				
		--Order by B.cCodCliente
		--GROUP BY cDesTipMon, A.cCodCtaKpr, cCodDetPre, cCodKilate ,B.cCodLinCre
	) as tmp ;

	select 
			ROW_NUMBER() 
			OVER(PARTITION BY Anio
			ORDER BY FecchaAdj) as 'Nro'
			,* 
	from #adj
	where FecchaAdj >= '2014-01-01' 
		and FecchaAdj <= '2015-05-31'
	
	

		-- DROP tABLE #adj
	
	--Estado de adjudicadas como en estado de diferidas.
	SELECT * FROM KPRTESTCREDITO WHERE  -- cCodEstKpr IN ('J','')
				 cCodEstKpr IN ('P','D','R','A','H','G','C')

	
	SP_HELPTEXT KPR_PreExiSinDet_sp
				
/***********************************************************************************************************************************************************************************************
*	Objetivo : Listado de Prendas Existentes
*	Sintaxis de ejemplo:  

		EXEC KPR_PreExiSinDet_sp '002'

***********************************************************************************************************************************************************************************************/ 

		SELECT	A.cCodCtaKpr, cCodLote = '          ', cDesTipMon,
				AVG(nMonsalAct) AS nMonsalAct, 
				SUM(nPesGraNet) AS nPesGraNet,
				SUM(nCanPieKpr) AS nCanPieKpr,
				'XX' = CASE WHEN MAX(cCodEstKpr) = 'C' THEN '2' ELSE '1' END
			INTO #curPreExi
			FROM KPRMCrePrenda A
				INNER JOIN kprddetprenda B
					ON A.cCodCtaKpr = B.cCodCtaKpr
						AND A.cCodEstKpr IN ('P','D','R','A','H','G','C')
						AND A.cFlgCtto = '0'
						--AND A.ccodoficin= @x_cCodOficin
				INNER JOIN GENTMONEDA C
					ON A.cCodTipMon = C.cCodTipMon 
			GROUP BY cDesTipMon, A.cCodCtaKpr

			--SELECT * FROM #curPreExi

		INSERT INTO #curPreExi
		SELECT	A.cCodCtaKpr, C.cCodLinCre AS cCodLote, cDesTipMon,
				AVG(nMonsalAct) AS nMonsalAct, 
				SUM(nPesGraNet) AS nPesGraNet,
				SUM(nCanPieKpr) AS nCanPieKpr,
				'XX' = CASE WHEN MAX(cCodEstKpr) = 'C' THEN '2' ELSE '1' END
			FROM KPRMCrePrenda A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre	
						AND A.cCodEstKpr in ('P','D','R','A','H','G','C')											
						AND A.cFlgCtto = '1'
						--AND A.ccodoficin = @x_cCodOficin
				INNER JOIN kprddetprenda C
					ON B.cCodLinCre = C.cCodLinCre
				INNER JOIN GENTMONEDA D
					ON A.cCodTipMon = D.cCodTipMon 
			GROUP BY C.cCodLinCre, cDesTipMon, A.cCodCtaKpr


		SELECT *
			FROM #curPreExi
			ORDER BY cDesTipMon, cCodLote, cCodCtaKpr

--***********************************************************************************************************************************************************************************************/ 		
			
		SP_HELPTEXT KPR_PreExiConDet_sp

/***********************************************************************************************************************************************************************************************
*	Objetivo : detalle de prendas en existencia
*	Sintaxis de ejemplo:  

		EXEC KPR_PreExiConDet_sp '002'

***********************************************************************************************************************************************************************************************/  

		SELECT	A.cCodCtaKpr, '          ' AS cCodLote,	cDesTipMon
				, nMonsalAct, nPesGraNet, npesgrabru,
				cDetPreKpr, cCodDetPre, nCanPieKpr, ccodkilate
			INTO #curPreExiDet
			FROM KPRMCrePrenda A
				INNER JOIN KPRDDetPrenda B
					ON A.cCodCtaKpr = B.cCodCtaKpr
						AND cCodEstKpr IN ('D','A','R','G','H','P','C')
						AND A.cFlgCtto = '0'
						--AND A.ccodoficin = @x_cCodOficin
				INNER JOIN GENTMoneda C
					ON A.cCodTipMon = C.cCodTipMon


		INSERT INTO #curPreExiDet
		SELECT	A.cCodCtaKpr, B.cCodLinCre AS cCodLote,
				cDesTipMon, nMonsalAct, nPesGraNet, npesgrabru,
				cDetPreKpr, cCodDetPre, nCanPieKpr, ccodkilate
			FROM KPRMCrePrenda A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre	
						AND A.cCodEstKpr IN ('D','A','R','G','H','P','C')
						AND A.cFlgCtto = '1'
						AND A.ccodoficin = @x_cCodOficin
				INNER JOIN KPRDDetPrenda C
					ON B.cCodLinCre = C.cCodLinCre
				INNER JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon

		SELECT * FROM #curPreExiDet
		ORDER BY cDesTipMon, cCodLote, cCodCtaKpr, cCodDetPre
---------------------------------------------------------------------------------