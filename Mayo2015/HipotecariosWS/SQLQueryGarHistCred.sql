--sp_helptext KPY_ConsGarLinCre_sp
/***********************************************************************************************************************************************************************************************
*	Copyright © 2012 CMAC Huancayo -. All rights reserved.                                             
*	Objetivo: Consulta las Garantias por Lineas de Credito
*	Escrito por:		Gregorio Lopez Pinto
*	Email/Movil/Phone:	2006-11-22
*  
*	Fecha creación: 2006-11-22
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		Fecha  		Responsable		Descripcion del cambio
*		2008.12.16	OPEREZ			Se agregó el valor de Ampliación.
*		2009.07.03	OPEREZ			Se adecuo a la nueva estructura de garantias.
*		2010.06.07	OPEREZ			Se esta coorgiendo el saldo de garantia de retorno.
*		2012.12.29	YGONZA			Se corrigió duplicidad de datos.
*		2012.01.11  FASTUH	        Se modifico según nueva estructura de garantias
*		2014.06.10	FASTUH			Se agrego campo de descripción de moneda.
*		2014.07.11	FASTUH			Se adecuo segun nueva estructura de ampliacion por %
*		2014.10.10	FASTUH			Se agrego que considere monto de gravamen en soles.
*		  
*	Sintaxis de ejemplo:  
		EXEC KPY_ConsGarLinCre_sp '0020080518'
***********************************************************************************************************************************************************************************************/  

CREATE PROCEDURE [dbo].[KPY_ConsGarLinCre_sp]
	@cCodLinCre CHAR(10)
AS 
BEGIN
	DECLARE @lccodmotsol CHAR (1) , @cCodMonLin CHAR(1) , @nTipCamGar DECIMAL(14,4) 
	, @nTipCamFij DECIMAL(14,3) 
	SET NOCOUNT ON

	SELECT TOP 1 @nTipCamFij = cValVarApl
	FROM ADMMVariable
	WHERE cNomVarApl = 'gntipcamfij'

	----HALLAMOS TIPO DE MONEDA DE LINEA
	SELECT @cCodMonLin = cMonedaLin  , @nTipCamGar = nTipCambio 
	FROM KPYMLinCreCli 
	WHERE cCodLinCre = @cCodLinCre 

	DECLARE @lCurGarGra TABLE (cCodCliente CHAR(12),		cCodGarCli CHAR(3),				nMonGraGar NUMERIC (14,2),
							   nMonGarOri NUMERIC(14,2),	nMonGarOriSol NUMERIC(14,2),	nMonTasGar NUMERIC(14,2),
							   nMonTasGarSol NUMERIC(14,2), nTipCamTas DECIMAL(14,4),		cTipMonGar CHAR(1))

	INSERT @lCurGarGra
	
	SELECT A.cCodCliente,A.cCodGarCli,B.nMonGraGar , B.nMonGarOri , B.nMonGarOriSol 
			, B.nMonTasGar , B.nMonTasGarSol , B.nTipCamTas, B.cCodTipMon
	FROM KPYDGarLinCre A
		INNER JOIN CMACHYOCLI..CLIMGARCLIENTE B
			ON A.CCODCLIENTE = B.CCODCLIENTE 	
			AND A.CCODGARCLI = B.CCODGARCLI 		 
	WHERE	cCodLinCre = @cCodLinCre
			AND A.cCodEstGar = 'A'

	SELECT @cCodMonLin = cMonedaLin  , @nTipCamGar = nTipCambio 
	FROM KPYMLinCreCli 
	WHERE cCodLinCre = '0020073453'--@cCodLinCre 

	SELECT @lccodmotsol = ccodmotsol 
	FROM KPYMSOLICITUD
	WHERE CCODLINCRE = '0020073453'--@cCodLinCre

	SELECT DISTINCT
		DGAR.cCodLinCre, DGAR.cCodGarCli, 			
		DGAR.cCodCliente, DGAR.cCodTipGar,
		cDesTipGar, DGAR.cCodRelCta,
		cDesRelCta, C.CNOMCLIENTE, 
		CASE WHEN @cCodMonLin = '1' THEN  E.nMonGarOriSol ELSE E.nMonGarOri END AS nMonGarOri,
		E.nMonGarOri AS nMonGarDol,
		CONVERT(DECIMAL(14,2),DGAR.nMonTasGar * CASE WHEN @cCodMonLin = '1' THEN E.nTipCamTas ELSE 1 END) AS nMonTasGar,
		DGAR.nMonTasGar AS nMonTasGarDol,
		CONVERT(DECIMAL(14,2),CASE WHEN @cCodMonLin = '1' THEN ISNULL(DGAR.nMonGraGarSol,0.00) ELSE DGAR.nMonGraGar END) AS nMonGraGar,
		'nSaldoGar' =  CASE 
							WHEN @lccodmotsol = '3' AND EXC.nMonAmpGar IS NOT NULL THEN ISNULL(EXC.nMonAmpGar,DGAR.nMonTasGar)
							ELSE dbo.KPY_RetSalDisGar_FX(DGAR.nMonTasGar,D.cCodSolCre ,DGAR.cCodCliente,DGAR.cCodGarCli)
						END  ,
		'M' As OPERACION,
		DGAR.nTipCamGar, CASE WHEN @cCodMonLin = '1' THEN  E.nMonGarOriSol ELSE E.nMonGarOri END AS nMonOrigar,
		DGAR.cCodTipMon, ccodclagar,ctipgar = GAR.ccodtipgar,GAR.ccodsubgar,
		cCodIndTotCob = 0,DGAR.nPorCobGar , ISNULL(DGAR.nPorCobLinGar ,0) AS nPorGraGar , ISNULL(M.cDesCorta,'') AS cDesMoneda
	FROM KPYDGARLINCRE DGAR 
		INNER JOIN GENDGarantia GAR
			ON DGAR.CCODTIPGAR = GAR.cCodGarant
				AND GAR.lconestado = 1
		LEFT JOIN GENTTIPRELCTA TIP
			ON DGAR.CCODRELCTA = TIP.CCODRELCTA
		INNER JOIN CMACHYOCLI.DBO.CLIMClienteS C
			ON DGAR.CCODCLIENTE = C.CCODCLIENTE
		INNER JOIN KPYMSOLICITUD D
			ON DGAR.ccodlincre = D.ccodlincre
		LEFT JOIN KPYDAMPGARCRE EXC
			ON	EXC.CCODSOLCRE = D.CCODSOLCRE
				AND EXC.CCODGARCLI = DGAR.cCodGarCli
				AND EXC.CCODGARANT = GAR.cCodGarant 
				AND EXC.CCODCLIENTE = DGAR.CCODCLIENTE
				AND EXC.CCODRELGAR = DGAR.CCODRELCTA
				AND EXC.CNOMBREPAR = 'nMonAmpGar'
				AND EXC.CCODESTEXC = 'B'
		INNER JOIN @lCurGarGra E
			ON DGAR.CCODCLIENTE = E.CCODCLIENTE 	
			AND DGAR.CCODGARCLI = E.CCODGARCLI 	
		LEFT JOIN GENTMoneda M
			ON M.cCodTipMon = E.cTipMonGar
	WHERE 
		DGAR.CCODLINCRE = '0020073453'--@cCodLinCre  
		AND DGAR.cCodEstGar = 'A'

END


