--KPY_ValRegSolCre_sp
sp_helptext Kpy_ValRepCre_sp  
/***********************************************************************************************
*	Copyright  2012 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo : Validacion de Registro de Solicitud de Crédito
*  
*	Escrito por: 			PEREZ PEREZ, JOSE JESUS
*	Email/Movil/Phone:		operez@cmachuancayo.com.pe
*  
*	Fecha creacion: 2010-02-09 
*	Sistema / Modulo:	VITALIS / CREDITOS
*	Modificaciones:    
*		Fecha  		Responsable		Descripcion del cambio
*		2008.10.09	OPEREZ			Se quito la validacion de mora y gastos pagados.
*		2008.11.03	OPEREZ			Se Evito las validaciones para Pre pagos de Hipotecarios.
*		2008.11.11	OPEREZ			Se modifico los criterios para créditos de Libre Amortización.
*		2009.01.13	OPEREZ			Se considero tipo de reprogramacion especial para 
*									creditos de libre amortizacion
*		2009.07.01	AROBLE			Se valida para que la libre amortizacion solo se realiza por esta modalidad de reprogramacion	
*		2009.10.27	OPEREZ			Se esta obviando la validacion de la N° de reprogramaciones para un grupo de creditos
*									luego del proceso de reprogramacion se quitara el conjunto de creditos de la validacion.	
*		2010.02.24	OPEREZ			Se esta actualizando segun lo solicitado en el MEMORANDUM 01041		
*		2010.07.06	OPEREZ			Se esta alineando a la aestructura de validaciones.
*		2012.08.20	CMUCHA			Se está agregando la columna nRepCuoBal(reprogramaciones cuota balon)
*		2012.10.26	YGONZA			Se esta incluyendo la validación de Saldo de interes a la fecha.
*		2012.11.05  CMUCHA			Se agregó validación para leasing
*		2013.10.04	CMUCHA			Se incluye la validación de modalidad opción de compra leasing

*	Sintaxis de ejemplo:

	DECLARE @x_cResVal VARCHAR(300)

	EXEC Kpy_ValRepCre_sp	
				@x_cCodCtaCre = '107038102000468542',
				@x_cCodTipRep = '1',
				@x_cResVal = @x_cResVal OUTPUT 
	SELECT @x_cResVal
*
************************************************************************************************/

CREATE PROCEDURE [dbo].[Kpy_ValRepCre_sp]
	@x_cCodCtaCre CHAR(18),
	@x_cCodTipRep CHAR(1),
	@x_cResVal VARCHAR(300) OUTPUT
AS
SET NOCOUNT ON
	DECLARE @IDOC INT,					@lnTipValida INT = 1, 
			@lXMLCur XML,				@lcCodCliente CHAR(12),	
			@lnNumCreVig INT,			@lcCodMotSol CHAR(1) = '4', -- REPROGRAMACION	
			@lcResult VARCHAR (8000),	@lXMLCurExc XML,				
			@lcCodCtaCre CHAR(18),		@lnNumRepCre INT,
			@lnAtrCuo INT,				@lnAtrPro NUMERIC(14,4),
			@lnCapPag NUMERIC(14,4),	@lSaldoInt	NUMERIC(14,4),
			@lSaldoMor 	NUMERIC(14,4),	@lSalGasRep NUMERIC(14,4),
			@lcCodTipCre CHAR(2),		@lcCodModCre CHAR(2),
			@lcEstCreCon CHAR(1),		@lnNumCuoApr INT,
			@lcCodSubPro CHAR(2),		@lcCodMonSol CHAR(1),
			@lcCodProduc CHAR(2),		@lcCodTotPro CHAR(6),
			@lnPorCuoIni NUMERIC(10,4), -- Porcentaje cuota inicial leasing
			@lnPorOpcCom NUMERIC(10,4), -- Porcentaje opción de compra leasing
			@lcModOpcCom CHAR(1),		-- Modalidad de opción de compra
			@lnNumCuoSol INT,			-- Número cuotas solicitud				
			@lnRepCuoBal INT,
			@lnSalIntFec NUMERIC(14,4)		
		
	SELECT	@lcCodCliente = cCodCliente ,
			@lcCodMonSol = cCodTipMon ,
			@lcCodTipCre = cCodTipCre,			
			@lcCodProduc = cCodProduc,  
			@lcCodSubPro = cCodSubPro , 
			@lcCodModCre = cCodModCre, 
			@lcEstCreCon = cEstCreCon,
			@lnNumCuoApr = nNumCuoApr,			
			@lcCodTotPro = cCodTipCre + cCodProduc + cCodSubPro 
	FROM KPYMCRECONVEN A
		INNER JOIN GENMCreCli B
			ON A.cCodCtaCre = B.cCodCtaCre  
	WHERE A.cCodCtaCre  = @x_cCodCtaCre
																
	--- Número de créditos vigentes para Refinanciar, ampliar o reprogramar																

	SELECT @lnNumCreVig = COUNT(*)
	FROM kpymcreconven A 
	INNER JOIN GENMCreCli B
		ON A.ccodctacre = B.ccodctacre
	WHERE B.cCodCliente = @lcCodCliente
		AND cEstCreCon LIKE '[F]'
	
	SELECT @lnNumRepCre = COUNT(*) 
	FROM KPYDCREREFINA
	WHERE	cmotcampla = '2'
			AND cCtaCreRef	= @x_cCodCtaCre
			AND CCODESTREF	= 'R'
			AND CINDPREPAG != 'S'
			
	SELECT @lnRepCuoBal = COUNT(*) 
	FROM KPYDCREREFINA
	WHERE	cmotcampla = '2'
			AND cCtaCreRef	= @x_cCodCtaCre
			AND CCODESTREF	= 'R'
			AND CINDPREPAG != 'S'	
			AND cCodTipRep = '3'

	SELECT	@lnAtrCuo = MAX(ndiavencuo),
			@lnAtrPro = SUM(CASE 
								WHEN ndiavencuo < 0 THEN 0.00 
								ELSE ndiavencuo 
							END)/COUNT (a.ccodctacre) 
	FROM KPYMCreConven A
		INNER JOIN genmcrecli B
			ON a.ccodctacre = b.ccodctacre
		INNER JOIN kpydplanpagcre C
			ON a.ccodctacre = c.ccodctacre
				AND b.ccodultpla = c.ccodplapag
	WHERE	cEstCreCon = 'F' 
			AND a.ccodctacre = @x_cCodCtaCre
	GROUP BY a.ccodctacre	


	SELECT	@lnCapPag = SUM(c.nMonCapPag ),
			@lSaldoInt = SUM(CASE 
								WHEN C.nMonIntFec - c.nMonIntPag < 0 THEN  C.nMonIntPro - c.nMonIntPag
								ELSE C.nMonIntFec - c.nMonIntPag
							  END ),		
			@lSaldoMor = SUM( c.nMonMorpro-c.nMonMorPag),
			@lSalGasRep = SUM( c.nMonGasPro-c.nMonGasPag)
	FROM kpymcreconven AS a 
		INNER JOIN genmcrecli AS b
			ON a.ccodctacre = b.ccodctacre
		INNER JOIN kpydplanpagcre AS c
			ON a.cCodCtaCre = c.cCodCtaCre
				AND b.ccodultpla = c.ccodplapag
	WHERE	cEstCreCon = 'F' 	
			AND cCodEstCuo ='E' 
			AND a.ccodctacre = @x_cCodCtaCre
	GROUP BY a.ccodctacre

	---------
	SELECT	@lnSalIntFec = (a.nMonIntFec - a.nMonIntPag)
	FROM kpymcreconven AS a 
		INNER JOIN genmcrecli AS b
			ON a.ccodctacre = b.ccodctacre
	WHERE cEstCreCon = 'F' 	
		AND a.ccodctacre = @x_cCodCtaCre
	---------

	-- PARA LEASING --
	IF EXISTS ( SELECT A.cCodCtaCre
				FROM KPYMCRECONVEN A WITH(NOLOCK)
					INNER JOIN KPYTTipCreLsg B
						ON A.cCodTipCre = B.cCodTipCre
						AND A.cCodProduc = B.cCodProduc
						AND A.cCodSubPro = B.cCodSubPro
						AND B.lConEstado = 1
				WHERE A.cCodCtaCre = @x_cCodCtaCre )
	BEGIN
		-- Porcentajes
		SELECT @lnPorCuoIni = nPorCuoIni,
			   @lnPorOpcCom = nPorOpcCom,
			   @lcModOpcCom = cModOpcCom
		FROM KPYMCotizacion A
			INNER JOIN KPYMCRECONVEN B
				ON A.cCodSolCre = B.cCodSolCre			
		WHERE B.cCodCtaCre = @x_cCodCtaCre		

		-- Número de cuotas
		SET @lnNumCuoSol = @lnNumCuoApr
	END	


	CREATE TABLE #CUROPE  (		cCodMotSol char(1),			nNumCreVig INT,				nCreCmacHyo INT,			nNumEntFinEnd INT ,			
								nNumMaxCreVig INT,			nPlaDiaCre INT,				cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			
								nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	
								cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		
								nNumRepCre  INT ,			nAtrCuoCre NUMERIC(14,4) ,	nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	
								nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	nSalMorCuo  NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	
								cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , nMonEndFin   NUMERIC(14,4),	cCodTipCreVal CHAR (2),		
								cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	
								nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	nNumCreVen INT,				cCalCreCli CHAR(1),			
								cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			cOpiEndCli CHAR(2),			cCodTipDes CHAR(2),
								cCodTotPro CHAR(6),			nPorCuoIni NUMERIC(10,4),   nPorOpcCom NUMERIC(10,4),	nNumCuoSol SMALLINT,
								nRepCuoBal INT,				nSalIntFec NUMERIC(14,4),	cModOpcCom CHAR(1)
							)							

	CREATE TABLE #CURTMP  (		cCodMotSol char(1),			nNumCreVig INT,				nCreCmacHyo INT,			nNumEntFinEnd INT ,			
								nNumMaxCreVig INT,			nPlaDiaCre INT,				cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			
								nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	
								cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		
								nNumRepCre  INT ,			nAtrCuoCre NUMERIC(14,4) ,	nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	
								nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	nSalMorCuo  NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	
								cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , nMonEndFin   NUMERIC(14,4),	cCodTipCreVal CHAR (2),		
								cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	
								nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	nNumCreVen INT,				cCalCreCli CHAR(1),			
								cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			cOpiEndCli CHAR(2),			cCodTipDes CHAR(2)  ,
								cCodTotPro CHAR(6),			nPorCuoIni NUMERIC(10,4),   nPorOpcCom NUMERIC(10,4),	nNumCuoSol SMALLINT,
								nRepCuoBal INT,				nSalIntFec NUMERIC(14,4),	cModOpcCom CHAR(1)
							)				
															

	INSERT #CUROPE	
	SELECT	cCodMotSol =	@lcCodMotSol, 
			nNumCreVig =	@lnNumCreVig,		
			nCreCmacHyo =	0,
			nNumEntFinEnd =	0,
			nNumMaxCreVig = 0,
			nPlaDiaCre  =	0,
			cCodDocIde	=	'',
			cCodMonSol =	@lcCodMonSol,
			nMonRefCre =	0.00,	     			
			cOpiRefCre =	'' ,         
			nCreBloRef = 	'',
			nSalGasCre =	0.00,
			cCodTipCre = ISNULL(@lcCodTipCre,''), 
			cCodModCre = ISNULL(@lcCodModCre,''), 
			cEstCreCon = ISNULL(@lcEstCreCon,''),
			cCodTipRep = ISNULL(@x_cCodTipRep,''),
			nNumRepCre = ISNULL(@lnNumRepCre,0),
			nAtrCuoCre = ISNULL(@lnAtrCuo,0),	
			nMorProCre = ISNULL(@lnAtrPro,0.00),
			nNumCuoApr = ISNULL(@lnNumCuoApr,0), 
			nPagCapCuo = ISNULL(@lnCapPag,0.00),
			nSalIntCuo = ISNULL(@lSaldoInt,0.00), 
			nSalMorCuo = ISNULL(@lSaldoMor,0.00),
			nSalGasCuo = ISNULL(@lSalGasRep,0.00),			
			cCalCliCar = '',
			nMonAmpSol = 0.00,          
			nMonEndFin = 0.00,         
			cCodTipCreVal = ISNULL(@lcCodTipCre,''),			
			cCodProduc = ISNULL(@lcCodProduc,''),	
			cCodSubPro = ISNULL(@lcCodSubPro,'') ,	
			nNumAmpCre = 0,
			nPorPagCuo = 0.00, 
			nProAtrCuoPag = 0.00,
			nAtrCuoPag = 0.00,
			nNumCreVen = 0,
			cCalCreCli ='' ,
			cCalRieCli ='' ,
			cOpiTipCre = '',   
			cOpiEndCli = '',
			cCodTipDes = '',
			cCodTotPro = ISNULL(@lcCodTotPro,''),
			nPorCuoIni = ISNULL(@lnPorCuoIni,0.0000),
			nPorOpcCom = ISNULL(@lnPorOpcCom,0.0000),
			nNumCuoSol = ISNULL(@lnNumCuoSol,0),	
			nRepCuoBal = ISNULL(@lnRepCuoBal,0),
			nSalIntFec = ISNULL(@lnSalIntFec,0),
			cModOpcCom = ISNULL(@lcModOpcCom,'') 

	-- VALIDACION DE PARAMETROS

	EXECUTE GEN_ValGenPar_SP 
			@x_cCodTipApl	= 'KPY',
			@x_nTipValida	= @lnTipValida, 
			@x_cResVal		= @x_cResVal OUTPUT	,
			@x_XMLCur		= @lXMLCur OUTPUT			

	
	DROP TABLE #CUROPE
	DROP TABLE #CURTMP