	/*
	sp_helptext KPR_RepPreAdjMen_sp

/***********************************************************************************************************************************************************************************************
*	Sintaxis de ejemplo:  

		EXEC KPR_RepPreAdjMen_sp '002'
*
***********************************************************************************************************************************************************************************************/  

CREATE PROCEDURE [dbo].[KPR_RepPreAdjMen_sp]
@x_cCodOficin CHAR(3)
AS
BEGIN
	SELECT MAX(dFecAdjKpr) AS dFecAdj, MAX(cNroDocIde) AS cNumdocIde,
				 A.cCodCtaKpr, MAX(cNomCliente) AS cNomCliente, 
				'K10' = CASE WHEN cCodKilate = '10' THEN SUM(nPesGraNet) ELSE 0 END,
				'K12' = CASE WHEN cCodKilate = '12' THEN SUM(nPesGraNet) ELSE 0 END,
				'K14' = CASE WHEN cCodKilate = '14' THEN SUM(nPesGraNet) ELSE 0 END,
				'K16' = CASE WHEN cCodKilate = '16' THEN SUM(nPesGraNet) ELSE 0 END,
				'K18' = CASE WHEN cCodKilate = '18' THEN SUM(nPesGraNet) ELSE 0 END,
				'K21' = CASE WHEN cCodKilate = '21' THEN SUM(nPesGraNet) ELSE 0 END,
				AVG(A.nMonSalAct) AS nMonSalAct,	AVG(A.nValHisKpr) AS nMonTasKpr,
				MAX(B.cCodCliente) AS cCodCliente,	cDesTipMon,
				ccodcontra=B.cCodLinCre
		INTO #curDetAdj
		FROM KPRDCtaAdj  A (NOLOCK)
				INNER JOIN GENMCreCli B (NOLOCK)
					ON A.cCodCtaKpr = B.cCodCtaCre
						AND cCodEstKpr = 'J' 
				INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
					ON B.cCodCliente = cli.cCodCliente
				INNER JOIN KPRDAdjudiTas C (NOLOCK)
					ON A.cCodCtaKpr = C.ccodCtaKpr
				INNER JOIN KPRMCrePrenda D (NOLOCK)
					ON cCodCtaCre = D.cCodCtaKpr 
						--AND D.ccodoficin= @x_cCodOficin
				INNER JOIN GENTMONEDA M
					ON D.cCodTipMon = M.cCodTipMon
		GROUP BY cDesTipMon, A.cCodCtaKpr, cCodDetPre, cCodKilate ,B.cCodLinCre

	
	SELECT	 cItem=CONVERT(CHAR(3),ROW_NUMBER() OVER(ORDER BY ccodcontra)),
			 MAX(dFecAdj) AS dFecAdj, 
			 MAX(cNumDocIde) AS cNumDoc, 
			 cCodCtaKpr, cDesTipMon,
			 MAX(cNOmCLiente) AS cNomCli,
			 SUM(K10) AS K10, SUM(K12) AS K12,
			 SUM(K14) AS K14, SUM(K16) AS K16,
			 SUM(K18) AS K18, SUM(K21) AS K21,
			 AVG(nMonSalAct) AS nSalAct, AVG(nMonTasKPr) AS nMonTas,
			 MAX(cCodCliente) AS cCodCli,
			 ccodcontra
	FROM #curDetAdj
	GROUP BY cDesTipMon, cCodCtaKpr,ccodcontra
	ORDER BY ccodcontra
END	

	*/

	SP_HELPTEXT KPR_PreExiSinDet_sp
				
/***********************************************************************************************************************************************************************************************
*	Objetivo : Listado de Prendas Existentes
*	Sintaxis de ejemplo:  

		EXEC KPR_PreExiSinDet_sp '002'

***************************************************************************************************************************************************************************/ 
	select top 5  A.cCodCtaKpr , B.cCodCtaCre, * 
	from KPRMCrePrenda A
		INNER JOIN GENMCreCli B (NOLOCK)
				ON A.cCodCtaKpr = B.cCodCtaCre
					--AND cCodEstKpr = 'J' 
			INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
				ON B.cCodCliente = cli.cCodCliente


	select top 5 * from KPRMCrePrenda A
--------------------------------------------------------------------------------------------------
		CREATE PROCEDURE [dbo].[KPR_PreExiSinDet_sp]
		@x_cCodOficin CHAR(3)
		AS
		
		SELECT	BB.cCodCliente ,cli.cNroDocIde, cli.cNomCliente, BB.cCodLinCre
				,A.cCodCtaKpr, cCodLote = '          ', cDesTipMon,
				AVG(nMonsalAct) AS nMonsalAct, 
				SUM(nPesGraNet) AS nPesGraNet,
				SUM(nCanPieKpr) AS nCanPieKpr,
				'XX' = CASE WHEN MAX(cCodEstKpr) = 'C' THEN '2' ELSE '1' END
				,O.cCodOficin, O.cDesOficin
			INTO #curPreExi
			FROM KPRMCrePrenda A
				INNER JOIN kprddetprenda B
					ON A.cCodCtaKpr = B.cCodCtaKpr
						AND A.cCodEstKpr IN ('P','D','R','A','H','G','C')
						AND A.cFlgCtto = '0'
						--AND A.ccodoficin= @x_cCodOficin
				INNER JOIN GENTMONEDA C
					ON A.cCodTipMon = C.cCodTipMon
				INNER JOIN GENMCreCli BB (NOLOCK)
					ON A.cCodCtaKpr = BB.cCodCtaCre					
				INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
					ON BB.cCodCliente = cli.cCodCliente
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = A.cCodOficin
			GROUP BY cDesTipMon, A.cCodCtaKpr, BB.cCodCliente, cli.cNroDocIde,
					 cli.cNomCliente,  BB.cCodLinCre, O.cCodOficin, O.cDesOficin

			-- SELECT * FROM #curPreExi

		INSERT INTO #curPreExi
		SELECT	B.cCodCliente ,cli.cNroDocIde, cli.cNomCliente, B.cCodLinCre
				,A.cCodCtaKpr, C.cCodLinCre AS cCodLote, cDesTipMon,
				AVG(nMonsalAct) AS nMonsalAct, 
				SUM(nPesGraNet) AS nPesGraNet,
				SUM(nCanPieKpr) AS nCanPieKpr,
				'XX' = CASE WHEN MAX(cCodEstKpr) = 'C' THEN '2' ELSE '1' END
				,O.cCodOficin, O.cDesOficin
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

				INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
					ON B.cCodCliente = cli.cCodCliente
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = A.cCodOficin
			GROUP BY C.cCodLinCre, cDesTipMon, A.cCodCtaKpr, B.cCodCliente ,cli.cNroDocIde
					,cli.cNomCliente, B.cCodLinCre, O.cCodOficin, O.cDesOficin


		SELECT *
			FROM #curPreExi
			ORDER BY cDesTipMon, cCodLote, cCodCtaKpr

			
			-- Drop table #curPreExi

--***********************************************************************************************************************************************************************************************/ 		
			
		SP_HELPTEXT KPR_PreExiConDet_sp

/***********************************************************************************************************************************************************************************************
*	Objetivo : detalle de prendas en existencia
*	Sintaxis de ejemplo:  

		EXEC KPR_PreExiConDet_sp '002'

***********************************************************************************************************************************************************************************************/  

		CREATE PROCEDURE [dbo].[KPR_PreExiConDet_sp]
		@x_cCodOficin CHAR(3)		
		AS

		SET NOCOUNT ON

		SELECT	BB.cCodCliente ,cli.cNroDocIde, cli.cNomCliente, BB.cCodLinCre,
				A.cCodCtaKpr, '          ' AS cCodLote,
				cDesTipMon, nMonsalAct, nPesGraNet, npesgrabru,
				cDetPreKpr, cCodDetPre, nCanPieKpr, ccodkilate
				,O.cCodOficin, O.cDesOficin
			INTO #curPreExiDet
			FROM KPRMCrePrenda A
				INNER JOIN KPRDDetPrenda B
					ON A.cCodCtaKpr = B.cCodCtaKpr
						AND cCodEstKpr IN ('D','A','R','G','H','P','C')
						AND A.cFlgCtto = '0'
						--AND A.ccodoficin = @x_cCodOficin
				INNER JOIN GENTMoneda C
					ON A.cCodTipMon = C.cCodTipMon

				INNER JOIN GENMCreCli BB (NOLOCK)
					ON A.cCodCtaKpr = BB.cCodCtaCre					
				INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
					ON BB.cCodCliente = cli.cCodCliente
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = A.cCodOficin                                                                                                              

		INSERT INTO #curPreExiDet
		SELECT	B.cCodCliente ,cli.cNroDocIde, cli.cNomCliente, B.cCodLinCre,
				A.cCodCtaKpr, B.cCodLinCre AS cCodLote,
				cDesTipMon, nMonsalAct, nPesGraNet, npesgrabru,
				cDetPreKpr, cCodDetPre, nCanPieKpr, ccodkilate
				,O.cCodOficin, O.cDesOficin
			FROM KPRMCrePrenda A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre	
						AND A.cCodEstKpr IN ('D','A','R','G','H','P','C')
						AND A.cFlgCtto = '1'
						--AND A.ccodoficin = @x_cCodOficin
				INNER JOIN KPRDDetPrenda C
					ON B.cCodLinCre = C.cCodLinCre
				INNER JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon

				INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMClientes cli (NOLOCK)
					ON B.cCodCliente = cli.cCodCliente
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = A.cCodOficin

					

		SELECT * FROM #curPreExiDet
		ORDER BY cDesTipMon, cCodLote, cCodCtaKpr, cCodDetPre



