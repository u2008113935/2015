USE SOFCMACHYO
GO
IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_InsExpMiBaño_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_InsExpMiBaño_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Inserta un Expediente de Crédito MI BAÑO 
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-07
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		DECLARE @nNroExpCre INT = 1
		EXEC KPY_InsExpMiBaño_SP
				@x_cCodOpcion	= 'N',
				@x_nNroExpCre	= 250,
				@x_cNomCliente	= 'YENCIO',
				@x_cApePatCli	= 'DEL RIO',
				@x_cApeMatCli	= 'CHEJADE',
				@x_cNroDocIde	= '44894675',
				@x_nEstCivil	= '1',
				@x_cNroTelCli	= '975159696'
				@x_nCodDistri	= 12,
				@x_cDirCliente	= 'Jr. tarata 123',
				@x_nIdSolucion	= 1,
				@x_nPrecTotal	= 1500.00,
				@x_cOrigReg		= 'C',
				@x_cObsReg		= 'Registro Interno'
				@x_nRetExpCre	= @nNroExpCre OUTPUT
		SELECT @nNroExpCre
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_InsExpMiBaño_SP]
	@x_cCodOpcion		CHAR(1),
	@x_nExpMiBañoId		INT,
	@x_nNroExpCre		INT,
	@x_cNomCliente		VARCHAR(150),
	@x_cApePatCli		VARCHAR(150),
	@x_cApeMatCli		VARCHAR(150),
	@x_cNroDocIde		VARCHAR(12),
	@x_nEstCivil		INT,
	@x_cNroTelCli		VARCHAR(13),
	@x_cCodDistri		CHAR(6),
	@x_cDirCliente		VARCHAR(150),
	@x_nIdSolucion		INT,
	@x_cOrigReg			CHAR(1),
	@x_cObsReg			VARCHAR(250),
	@x_nRetExpCre		INT	= 0	OUTPUT
AS
SET NOCOUNT ON
SET XACT_ABORT ON
SET @x_nRetExpCre = @x_nNroExpCre
IF @x_nNroExpCre = 0
	AND @x_cOrigReg = 'C'
BEGIN 
	DECLARE @cRutWsHatSol	VARCHAR(150)
	SELECT @cRutWsHatSol = cValVarApl
	FROM ADMMVariable
	WHERE cNomVarApl = 'gcRutWsHatSol'
	AND cCodOficin = '001'
	SELECT @x_nNroExpCre = dbo.[KPY_RegSolCliHS_FX] (@cRutWsHatSol, @x_cNomCliente, @x_cApePatCli, @x_cApeMatCli, 
									@x_cNroDocIde, @x_nEstCivil, @x_cNroTelCli, @x_nIdSolucion, 7)
	SET @x_nRetExpCre = @x_nNroExpCre
	IF @x_nRetExpCre = 1
	BEGIN
		RETURN
	END
END
BEGIN TRANSACTION
	IF @x_cCodOpcion = 'N'
	BEGIN
		DECLARE @nExpMBId INT
		INSERT INTO KPYMREGEXPMIBAÑO	
					(	nNroExpCre,		cNroDocIde,		cNomCliente, 
						cApePatCli,		cApeMatCli,		cNroTelCli, 
						dFecRegExp,		nEstCivil,		nSolucionId,	
						cCodEstExp,		cDistriCli,		cDirecCli,		
						cOrigReg,		lEstRegistro)
			VALUES	(	@x_nNroExpCre,	@x_cNroDocIde,	@x_cNomCliente,
						@x_cApePatCli,	@x_cApeMatCli,	@x_cNroTelCli, 
						GETDATE(),		@x_nEstCivil,	@x_nIdSolucion,	
						'P',			@x_cCodDistri,	@x_cDirCliente,	
						@x_cOrigReg,	1)
		SET @nExpMBId = @@IDENTITY 
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

		INSERT INTO KPYDREGEXPMIBAÑO	
					(	nExpMiBañoId,
						cCodEstExp,
						cObsReg,
						nSolucionId,
						lEstRegistro)
			VALUES	(	@nExpMBId,	
						'P',	
						@x_cObsReg,
						@x_nIdSolucion,	
						1)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
	END
	ELSE
	BEGIN
		UPDATE KPYMREGEXPMIBAÑO
		SET cNroDocIde = @x_cNroDocIde,		
			cNomCliente = @x_cNomCliente, 
			cApePatCli = @x_cApePatCli,		
			cApeMatCli = @x_cApeMatCli,		
			cNroTelCli = @x_cNroTelCli, 
			nEstCivil = @x_nEstCivil,		
			nSolucionId = @x_nIdSolucion,	
			cDistriCli = @x_cCodDistri,		
			cDirecCli = @x_cDirCliente
		WHERE nExpMiBañoId = @x_nExpMiBañoId
			AND lEstRegistro = 1
			AND cCodEstExp = 'P'
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
	END
COMMIT TRANSACTION
GO
	GRANT EXEC ON [dbo].[KPY_InsExpMiBaño_SP] TO ADM_ADM_rl	
GO
	GRANT EXEC ON [dbo].[KPY_InsExpMiBaño_SP] TO WCF_WCF_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_UpdEstExpMB_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_UpdEstExpMB_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Actualiza el estado de una solicitud mi Baño
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-07
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		
		EXEC KPY_UpdEstExpMB_SP
				@x_nNroExpCre	= 1
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_UpdEstExpMB_SP]
	@x_nExpMiBañoId	INT,
	@x_cCodEstExp	CHAR(1),
	@x_cObsReg		VARCHAR(250),
	@x_nIdSolucion	INT,
	@x_cNumOperac	VARCHAR(20),
	@x_cCodSolCre	CHAR(10),
	@x_nMonSol		DECIMAL(14,2),
	@x_cResValid	VARCHAR(250) OUTPUT
AS
SET NOCOUNT ON
SET @x_cResValid = 'OK'

--===================================
--VALIDACIÓN DE SOLICITUD DE CRÉDITO
--===================================
IF @x_cCodEstExp = 'A' 
	AND NOT EXISTS (
					SELECT CCODSOLCRE 
					FROM KPYMSolicitud
					WHERE cCodSolCre = @x_cCodSolCre
				)
	BEGIN 
		SET @x_cResValid = 'Solicitud de Crédito no Existe. Por favor Verifique.'
		RETURN
	END

--========================================================
--VALIDACIÓN DE NÚMERO DE OPERACIÓN DE DESEMBOLSO (KARDEX)
--========================================================
IF @x_cCodEstExp = 'D' 
	AND NOT EXISTS (
					SELECT cCodKardex
					FROM GENMKardex
					WHERE cCodTipKar = 'KPY'
					AND cCodKardex = @x_cNumOperac
				)
	BEGIN 
		SET @x_cResValid = 'Número de Operación no Existe en el Kardex. Por favor Verifique.'
		RETURN
	END

--================================================
--Actualización del Registro del expediente MiBaño
--================================================
DECLARE @cResSerWebMB VARCHAR(255),
		@nNroExpCre INT,
		@cRutWsHatSol	VARCHAR(150),
		@cDistriCli	CHAR(6),
		@cDirecCli	VARCHAR(250)

SELECT	@nNroExpCre = nNroExpCre,
		@cDistriCli = cDistriCli,
		@cDirecCli	= cDirecCli
FROM KPYMREGEXPMIBAÑO
WHERE nExpMiBañoId = @x_nExpMiBañoId

SELECT @cRutWsHatSol = cValVarApl
FROM ADMMVariable
WHERE cNomVarApl = 'gcRutWsHatSol'
AND cCodOficin = '001'

BEGIN TRANSACTION
	--ENVIAR INFORMACIÓN DE LA APROBACIÓN DE LA SOLICITUD 
	IF @x_cCodEstExp = 'A'
	BEGIN
		SELECT @cResSerWebMB = DBO.[KPY_AprobarCred_FX] (@cRutWsHatSol, @nNroExpCre, @x_nIdSolucion, @x_nMonSol, @cDistriCli, @cDirecCli)
		IF @@ERROR <> 0 
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
		IF LTRIM(RTRIM(@cResSerWebMB)) <> 'OK'
		BEGIN
			SET @x_cResValid = @cResSerWebMB
			ROLLBACK TRANSACTION
			RETURN
		END
	END

	--ENVIAR INFORMACIÓN DEL RECHAZO DE LA SOLICITUD 
	IF @x_cCodEstExp = 'R'
	BEGIN
		SELECT @cResSerWebMB = DBO.[KPY_RechazarCred_FX] (@cRutWsHatSol, @nNroExpCre, @x_cObsReg)
		IF @@ERROR <> 0 
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
		IF LTRIM(RTRIM(@cResSerWebMB)) <> 'OK'
		BEGIN
			SET @x_cResValid = @cResSerWebMB
			ROLLBACK TRANSACTION
			RETURN
		END
	END

	--ENVIAR INFORMACIÓN DEL DESEMBOLSO DE LA SOLICITUD 
	IF @x_cCodEstExp = 'D'
	BEGIN
		SELECT @cResSerWebMB = DBO.[KPY_DesembolsarCred_FX] (@cRutWsHatSol, @nNroExpCre, @x_cNumOperac)
		IF @@ERROR <> 0 
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
		IF LTRIM(RTRIM(@cResSerWebMB)) <> 'OK'
		BEGIN
			SET @x_cResValid = @cResSerWebMB
			ROLLBACK TRANSACTION
			RETURN
		END
	END

	UPDATE KPYMREGEXPMIBAÑO
	SET cCodEstExp = @x_cCodEstExp,
		cCodSolCre = CASE	WHEN @x_cCodEstExp = 'A' THEN @x_cCodSolCre
							ELSE cCodSolCre END,
		nSolucionId = CASE	WHEN @x_cCodEstExp IN ('A','D') THEN @x_nIdSolucion
							ELSE nSolucionId END,
		cNumOpe = CASE	WHEN @x_cCodEstExp IN ('D') THEN @x_cNumOperac
							ELSE cNumOpe END,
		nPrecTot = CASE	WHEN @x_cCodEstExp IN ('A') THEN @x_nMonSol
							ELSE nPrecTot END
	WHERE nExpMiBañoId = @x_nExpMiBañoId
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

	UPDATE KPYDREGEXPMIBAÑO
	SET lEstRegistro = 0
	WHERE nExpMiBañoId = @x_nExpMiBañoId
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
	
	INSERT INTO KPYDREGEXPMIBAÑO
			(nExpMiBañoId,	cCodEstExp,
			cObsReg,		nSolucionId,
			lEstRegistro)
	VALUES (@x_nExpMiBañoId,@x_cCodEstExp,
			@x_cObsReg,		@x_nIdSolucion,
			1)
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
COMMIT TRANSACTION

GO
	GRANT EXEC ON [dbo].[KPY_UpdEstExpMB_SP] TO ADM_ADM_rl	
GO
	GRANT EXEC ON [dbo].[KPY_UpdEstExpMB_SP] TO WCF_WCF_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_ValNroExpMiBaño_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_ValNroExpMiBaño_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Valida existencia de un Expediente de Crédito MI BAÑO
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-07
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		
		EXEC KPY_ValNroExpMiBaño_SP
				@x_nNroExpCre	= 1
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_ValNroExpMiBaño_SP]
	@x_nNroExpCre	INT,
	@x_cNroDocide	CHAR(8)
AS
SET NOCOUNT ON
SELECT nNroExpCre
FROM KPYMREGEXPMIBAÑO	
WHERE nNroExpCre = @x_nNroExpCre
AND cNroDocIde = @x_cNroDocide
AND lEstRegistro = 1
GO
	GRANT EXEC ON [dbo].[KPY_ValNroExpMiBaño_SP] TO ADM_ADM_rl	
GO
	GRANT EXEC ON [dbo].[KPY_ValNroExpMiBaño_SP] TO WCF_WCF_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisCreMiBaño_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisCreMiBaño_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Lista los Expedientes de Crédito MI BAÑO por Estado
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-07
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		
		EXEC KPY_LisCreMiBaño_SP
				@x_cCodEstExp	= 'P'
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_LisCreMiBaño_SP]
	@x_cCodEstExp	CHAR(1),
	@x_dFecIni		DATETIME,
	@x_dFecFin		DATETIME
AS
SET NOCOUNT ON
SET @x_dFecFin = DATEADD(HOUR, 23.9,@x_dFecFin)
SELECT 	A.nExpMiBañoId,
		A.nNroExpCre,
		A.cNroDocIde,
		cNomComp = A.cApePatCli + '/' + A.cApeMatCli + ' ' + A.cNomCliente,
		A.cNomCliente,
		A.cApePatCli,
		A.cApeMatCli,
		A.cNroTelCli,
		A.dFecRegExp,
		A.nEstCivil,
		nSolucionId = CAST (A.nSolucionId AS VARCHAR(2)),
		A.cCodSolCre,
		A.cCodEstExp,
		A.cDistriCli,
		B.cNomDistri,
		A.cDirecCli,
		A.nPrecTot,
		A.cOrigReg,
		C.cObsReg
FROM KPYMREGEXPMIBAÑO A
	INNER JOIN GENTDISTRITO B
		ON SUBSTRING(A.cDistriCli,1,2) = B.cCodDepart
		AND SUBSTRING(A.cDistriCli,3,2) = B.cCodProvin
		AND SUBSTRING(A.cDistriCli,5,2) = B.cCodDistri
		AND A.dFecRegExp BETWEEN @x_dFecIni AND @x_dFecFin
	INNER JOIN KPYDREGEXPMIBAÑO C
		ON A.nExpMiBañoId = C.nExpMiBañoId
		AND C.lEstRegistro = 1
		AND A.cCodEstExp = C.cCodEstExp
WHERE A.cCodEstExp = @x_cCodEstExp
AND A.lEstRegistro = 1
GO
	GRANT EXEC ON [dbo].[KPY_LisCreMiBaño_SP] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisEstCreMB_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisEstCreMB_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Lista los Estados de los Expedientes de Crédito MI BAÑO.
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-07
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		
		EXEC KPY_LisEstCreMB_SP
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_LisEstCreMB_SP]
AS
SET NOCOUNT ON
SELECT cCodEstExp, cDetEstExp
FROM KPYTESTEXPMB	
WHERE lEstRegistro = 1
UNION 
SELECT cCodEstExp = 'S', cDetEstExp = '..SELECCIONE..'
GO
	GRANT EXEC ON [dbo].[KPY_LisEstCreMB_SP] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisTipSolucMB_SP]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisTipSolucMB_SP]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo:				Listar Tipos de Soluciones MI BAÑO 
*  
*	Escrito por: 			HERBERT VARGAS
*	Email/Movil/Phone:		hvargas@cajahuancayo.com.pe
*  
*	Fecha creación: 2015-10-13
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		USUARIO			FECHA			DETALLE
*
*	Sintaxis de ejemplo:  
*		
		EXEC KPY_LisTipSolucMB_SP
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_LisTipSolucMB_SP]
AS
SET NOCOUNT ON
SELECT	nSolucionId = CAST (nSolucionId AS VARCHAR(3)), 
		cDesCorta
FROM KPYTTIPSOLUCMB
WHERE lEstRegistro = 1

GO
	GRANT EXEC ON [dbo].[KPY_LisTipSolucMB_SP] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_ModDesCre_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_ModDesCre_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2014 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo: Actualiza datos de destino y tipo de destino de credito
*  
*	Escrito por: 			GLOPEZ
*	Email/Movil/Phone:		GLOPEZ@CMAC-HUANCAYO.COM.PE
*  
*	Fecha creación: 2003-06-01
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:
*		Fecha   		Creador   	Motivo
*		2006-08-07		GLOPEZ		Se añade datos para guardar el tipo de destino de credito 
*		2007-01-13		GLOPEZ		Cambios para almacenar monto en tipo de destinos
*		2010.05.20		OPEREZ		Se esta controlando el valor nulo del XML	
*		2010.06.27		OPEREZ		Se agregó la longitud del campo "ccoddescre"
*		2014.09.10		YGONZA		Se está agregando productos de linea crediecologica. 
		2015.10.14		HVARGA		Se agrega parámetro @x_xcurSubDesCre para sub Destinos de Créditp (Ej: MiBaño y WaterCredit)

*	Sintaxis de ejemplo:  
*		EXEC KPY_ModDesCre_sp
*
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_ModDesCre_sp]
	@x_DesCre TEXT,
	@x_TipDes TEXT,
	@x_cCodSolCre CHAR(10),
	@x_cCodCtaCre CHAR(18),
	@x_cCodUsu CHAR(6),
	@x_dFecSis DATETIME,
	@x_xcurProEco TEXT,
	@x_xcurSubDesCre TEXT
AS
SET NOCOUNT ON
DECLARE @IDOC INT
DECLARE @x_cEstcreCon CHAR(1)

SELECT @x_cEstcreCon = cEstCreCon 
	FROM kpymcreconven WHERE cCodSolCre = @x_cCodSolCre

SET @x_cEstcreCon = ISNULL(@x_cEstcreCon,'B')

IF @x_DesCre IS NOT NULL 
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_DesCre
	    
	SELECT cdescrides, nmonporafe, ccoddescre
		INTO #curDesCre
		FROM OPENXML (@IDOC, '/VFPData/curdescrecon',1)    
		WITH (cdescrides varchar(50), nmonporafe numeric(14,2), ccoddescre char(2))    
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
	-- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    
END	

IF @x_TipDes IS NOT NULL
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_TipDes
	SELECT ccodtipdes, nmontipdes
		INTO #curTipDes
		FROM OPENXML (@IDOC, '/VFPData/curdetdetact',1)    
		WITH (ccodtipdes char(2), nmontipdes numeric(14,2))
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
	-- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    
END

---------------------------------------------------------   
IF @x_xcurProEco IS NOT NULL
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_xcurProEco
	SELECT cCodSolCre,cCodDesCre,cCodTipDes,cCodTipEco,cDesDesEco,lIndMar,nMonProEco
		INTO #curproeco
		FROM OPENXML (@IDOC, '/VFPData/curproeco',1)    
		WITH (ccodsolcre CHAR(10),ccoddescre CHAR(2),ccodtipdes CHAR(2),ccodtipeco CHAR(2),cdesdeseco VARCHAR(150),lindmar BIT,nmonproeco NUMERIC(14,2))
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
	-- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    
END
---------------------------------------------------------

--============== SUB DESTINOS DE CRÉDITOS (EJ. MIBAÑO Y WATERCREDIT)===============--
IF @x_xcurSubDesCre IS NOT NULL
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_xcurSubDesCre
	SELECT cCodSolCre,cCodSubTipDes,cCodDesCre,cCodTipDes,cCodSolSubTipCre,cDesSubTipDes,lIndMar,nMonPro
		INTO #curSubDesCre
		FROM OPENXML (@IDOC, '/VFPData/cursubdescre',1)    
		WITH (ccodsolcre CHAR(10), ccodsubtipdes CHAR(1), ccoddescre CHAR(2),ccodtipdes CHAR(2),ccodsolsubtipcre CHAR(2),cdessubtipdes VARCHAR(150),lindmar BIT,nmonpro NUMERIC(14,2))
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
	-- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    
END

---------------------------------------------------------
DELETE FROM KPYDDesCreCon 
	WHERE ccodsolcre = @x_cCodSolCre
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    

INSERT INTO KPYDDesCreCon
	(
	cCodSolCre, cCodCtaCre, cCodDesCre, nMonPorDes, 
	cCodIndFij, cCodUsuReg, dFecingDes, dFechorsis, 
	cestCreCon, cDescriDes
	)
SELECT @x_cCodSolCre, @x_cCodCtaCre, ccoddescre, nmonporafe, 
	'F', @x_cCodUsu, @x_dFecSis, getdate(),
	@x_cEstcreCon, cDescriDes
	FROM #curDesCre
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END

DELETE FROM KPYDTipDesCre 
	WHERE ccodsolcre = @x_cCodSolCre
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    

INSERT INTO KPYDTipDesCre
	(
	cCodSolCre, cCodTipDes, cCodUsuPro,
	dFecModUsu, cCodDocSus, nMonTipDes
	)
SELECT @x_cCodSolCre, cCodTipDes, @x_cCodUsu,
	@x_dFecSis, 'N', nmontipdes
	FROM #curTipDes
IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION    
		RETURN
	END

	--=======================================================================================
	--REGISTRO DE TIPOS DE DESTINOS DE CRÉDITO CREDIECOLÓGICO
	--=======================================================================================
	IF @x_xcurProEco IS NOT NULL
	BEGIN
		DELETE FROM KPYDProEcolog
		WHERE ccodsolcre = @x_cCodSolCre
			AND lConEstado = 1
		IF @@ERROR <> 0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END  

		INSERT INTO KPYDProEcolog (cCodSolCre,cCodDesCre,cCodTipDes,cCodTipEco,nMonProEco,lConEstado)
		SELECT @x_cCodSolCre,cCodDesCre,cCodTipDes,cCodTipEco,nMonProEco,1
		FROM #curproeco
		WHERE lIndMar = 1
		IF @@ERROR <> 0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN
			END
		DROP TABLE #curproeco
	END
	
	--=======================================================================================
	--REGISTRO DE SUB TIPOS DE DESTINOS DE CRÉDITO (EJ. MIBAÑO Y WATERCREDIT)
	--=======================================================================================
	IF @x_xcurSubDesCre IS NOT NULL
	BEGIN
		DELETE FROM KPYDSubTipDes
		WHERE ccodsolcre = @x_cCodSolCre
		AND lConEstado = 1
		IF @@ERROR <> 0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END  

		INSERT INTO KPYDSubTipDes (cCodSolCre,cCodSubTipDes, cCodDesCre, cCodTipDes, cCodSolSubTipCre, nMonSolSubTipDes, lConEstado)
		SELECT @x_cCodSolCre,cCodSubTipDes,cCodDesCre,cCodTipDes,cCodSolSubTipCre,nMonPro,1
		FROM #curSubDesCre
		WHERE lIndMar = 1
		IF @@ERROR <> 0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN
			END
		DROP TABLE #curSubDesCre
	END
	--=======================================================================================
/**********************************************************************************************************************************************************************************************/
GO
	GRANT EXEC ON [dbo].[KPY_ModDesCre_sp] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisSolSubTipDes_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisSolSubTipDes_sp]
GO
/****************************************************************************************************************************************************
* Copyright © 2015 CMAC Huancayo -. All rights reserved  
*   
* Objetivo				: Lista las soluciones de un sub tipo de Destin de Crédito (Ej: MIBAÑO y WATERCREDIT).
*   
* Escrito por			: HERBERT VARGAS
* Email/Movil/Phone		: hvargas@cajahuancayo.com.pe
*          
* Fecha creación		: 2015.10.14
*          
* Sistema / Modulo		: VITALIS / CRÉDITOS
*        
* Modificaciones:            
*	Fecha		Responsable		Descripcion del cambio   
	EXEC KPY_LisSolSubTipDes_sp
		@x_cCodSolCre = '0020041378',
		@x_cCodDesCre = '5',
		@x_cCodTipDes = '69',
		@x_cCodTipDesSan = 'B'
*
*****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[KPY_LisSolSubTipDes_sp]
	@x_cCodSolCre CHAR(10),
	@x_cCodDesCre CHAR(2),
	@x_cCodTipDes CHAR(2)
AS  
SET NOCOUNT ON
BEGIN
	
	SELECT	cCodSolCre = @x_cCodSolCre,cCodDesCre=@x_cCodDesCre,cCodTipDes=@x_cCodTipDes,A.cCodSubTipDes,
			A.cDesSubTipDes,
			lIndMar =	CASE
							WHEN ISNULL(B.nMonSolSubTipDes,0.00)  = 0.00 THEN CAST(0 AS BIT)
							ELSE CAST(1 AS BIT)
						END,
			nMonPro = ISNULL(B.nMonSolSubTipDes,0.00),
			A.cCodSolSubTipCre
	FROM KPYTSolSubTipDes A
		LEFT JOIN KPYDSubTipDes B
			ON A.cCodSubTipDes = B.cCodSubTipDes
				AND A.cCodSolSubTipCre = B.cCodSolSubTipCre
				AND A.lConEstado = 1
				AND B.lConEstado = 1
				AND B.cCodSolCre = @x_cCodSolCre
				AND B.cCodDesCre = @x_cCodDesCre
				AND B.cCodTipDes = @x_cCodTipDes
END
--**************************************************************************************************************************************************
GO
	GRANT EXEC ON [dbo].[KPY_LisSolSubTipDes_sp] TO ADM_ADM_rl	
GO


/*====================
KPY_ManSolCre_sp
======================*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[KPY_ManSolCre_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_ManSolCre_sp]
GO
/*********************************************************************************************
*     Copyright © 2014 CMAC Huancayo -. All rights reserved.	
*                                           
*     Objetivo: Actualiza datos de solicitud de creditos
*  
*     Escrito por:                 GLOPEZ
*     Email/Movil/Phone:           GLOPEZ@CMAC-HUANCAYO.COM.PE
*  
*     Fecha creación: 2006-12-12
*  
*     Sistema / Modulo: VITALIS / CREDITOS
*
*     Modificaciones:
*           Fecha       Creador			Motivo
*           2007.02.06  glopez            no se debe evaluar aun por el scoring
*           2007.04.22  GLOPEZ            Registro en Personas observadas si Solicitud es DEnegada Definitiva
*           2007.07.28  GLOPEZ            Procedimiento de modalidades de desembolso
*           2007.08.20  GLOPEZ            Solo para solicitudes con motivo de Otorgamiento de créditos
                                               debe vincularse con cuenta
*           2008.01.04  OPEREZ            Se controlo el motivo de solicitud para creditos automaticos
*           2008.02.13  OPEREZ           Se agrego el filtro por oficinas en las consultas a la tabla KPYTTipActSco
*           2008.05.26  OPEREZ            Se aumento a 1000 la longitud de la variable @x_MsgValPar
*           2008.07.05  AROBLE           Se agrego el campo de adeudado
*           2008.07.21  AROBLE           Para registro de gastos y seguros 
*           2008.10.18  AROBLE           Actualiza el monto de tasa de la aseguradora en la tabla de gastos 
*           2009.03.05  ASALAZ           Se Modifico el calculo del scoring 
*			2009.06.06  LMARIN           Cambios hipotecarios
*           2009.07.08  ASALAZ           Se agregó filtrar por el codigo de solicitud al actualizar el maestro de 
                                               la tabla del credit scoring
*           2010.03.08  ASALAZ           Cambio de calculo del Credit Scoring Post Targeting
*           2010.03.16  OPEREZ            Se cambio la forma de guardar los datos en la tabla kpydcrerefina
*           2010.03.25  OPEREZ            Se incremento la longitud del campo "CCODINTCON" de 3 a 5
*           2010.04.16  ASALAZ            Se adicionó al Credit Scoring Solicitudes de Ampliación
*           2010.04.22  OPEREZ            Se esta quitando el sp de validacion de parametros
*           2010.06.28  AROBLE            Se adecua de acuerdo al nuevo codigo correlativo de gasto
*           2010.07.07  OPEREZ            Se esta controlando el valor nulo del XML
*           2011.08.09  ASALAZ            Se adicionó al Credit Scoring Solicitudes modalidad principal
*			2011.11.29  MALFAR		      Se cambio la forma de guardar datos en el campo cCodUsuIng de la tabla 
*										  KPYMSOLICITUD   
*			2012.10.16	OPEREZ			  Se esta validando los creditos agropecuarios a libre amortizacion que deben ser a una sola cuota (JCRIOLLO). 	
*			2012.10.27	YGONZA			  Se esta grabando el campo cCodMotSol con su valor.		
*			2013.05.06	CMUCHA			  Guarda valores de afiliación al seguro desgravamen.
*			2013.12.12	FASTUH			  Se agrego validacion de tasa de interes moratorio.
*			2014.01.02	CMUCHA			  Se agrega clientes afiliados al seguro y se retornan mensajes de validación
*			2014.01.14  FASTUH			  Se agrego cursor con datos de tipo de garantia para cartas fianza.
*			2014.03.27	ASALAZ			  Se valida es estado de ls siguiente variable @lnactSco para la activación
*										  del Scoring.
*			2014.09.29	FASTUH			  Se quito validación de tasa moratoria para reprogramaciones
*			2014.11.19	YGONZA			  Se esta agregando parametro xml de productos de linea crediecologica. 
			2015.10.15	HVARGA			  Se agrega el parámetro @x_xcurSubDesCre

*     Sintaxis de ejemplo:
*           No es posible por tener parámetros de tipo XML
*
**********************************************************************************************/
CREATE PROCEDURE KPY_ManSolCre_sp
      @x_cursol         TEXT,
      @x_curamp         TEXT,
      @x_DesCre         TEXT,
      @x_TipDes         TEXT,
      @x_MotDen         TEXT,
      @x_cCodSol        CHAR(10),
      @x_cEstSol        CHAR(1),
      @x_ccodSit        CHAR(1),
      @x_PrePag         CHAR(1)= 'N',
      @x_ActSco         VARCHAR(50)       OUTPUT,
      @x_MonAcu         NUMERIC(14,2)     OUTPUT,
      @x_MsgValPar      VARCHAR(1000)     OUTPUT,
      @x_cCodOficin     CHAR(3),
      @x_cDesMotivo     VARCHAR(100),
      @x_nTasIntMin     NUMERIC(14,4),
      @x_cCodOfiCta     CHAR(3),
      @x_xDetGasTos     TEXT,
      @x_cNivRie        VARCHAR(50)=''    OUTPUT,
      @x_cDesRazEva     VARCHAR(50) ='' OUTPUT,
      @x_cModSco        CHAR(1)=''        OUTPUT ,
      @x_cCodUsuSco     CHAR(6)='',
	  @x_xCliAfiSeg     XML,
	  @x_cMsgRetTrx     VARCHAR(200) OUTPUT,
	  @x_xGarCarFia		XML,
	  @x_xcurProEco		TEXT,
	  @x_xcurSubDesCre	TEXT
AS
SET NOCOUNT ON   

SET @x_cMsgRetTrx = 'OK' 

DECLARE @IDOC                INT, 
            @x_cCodUsu        CHAR(6),
            @x_dFecSis        DATETIME,
            @nValScoSol       NUMERIC(14, 2), -- VALOR DEL SCORE
            @cTipActSco       VARCHAR(3),       -- TIPO DE ACTA DE COMITE
            @nNumScoCli       INT,              -- NUMERO DE CONSULTA DE SCORE
            @cCodCliente      CHAR(12),
            @cCodUsuIng       CHAR(6),
            @dFecSolCre       SMALLDATETIME,
            @nMonSolCre       NUMERIC(14,2),
            @nMonTipCam       NUMERIC(14,4),
            @cCodMoneda       CHAR(1),
            @pcMotSol         CHAR(1), 
            @nCapAmpli        NUMERIC(14,4),
            @cCodTipCre       CHAR(3),
            @cCodSubPro       CHAR(6),
            @nMorAntAmo       SMALLINT,
            @nPlazo                 INT,
            @nNumCuoApr       INT,
            @nTasInt          NUMERIC(14,4),
            @x_ccodexpaho     CHAR(9),
            @x_ccodexpKpy     CHAR(9),
            @x_cCodModCre     CHAR(2),
            @x_cCodTipCre	  CHAR(2),	
			@x_cCodProduc	  CHAR(2),	
			@x_cCodSubPro	  CHAR(2)
            
BEGIN TRANSACTION

      
IF @x_cursol IS NOT NULL 
BEGIN
      --- Preparando Documento XML    
      EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_cursol    
    
      SELECT
      cCodSolCre,cCodTipSol,cCodClient,cCodMoneda,nMonSolCre,cCodUsuAna,nNumCuoSol, nPlaSolCre,dFecSolCre,    
      cCodUsuSol,cMonedaApr,nMonSugAna, cDescriSol,nMonAprCre,nNumCuoApr,nPlaAprCre,dFecAprCre,cObsAnaCre,    
      cCodExpCli,cCodEstSol,cCodOficin,cCodActAna,cCodTipAct,cCodComite,cCodPlazo,dFecModCre,    
      cCodUsuIng,
      lHistoria =CASE WHEN lHistoria = 'TRUE' 
                             THEN 1 
                             ELSE 0 
                        END,    
      cCreNuevo,cCreNorRef,
      cCodMotSol,
      cCodTipCre,ccodproduc,cCodSubPro,cCodRecurs,    
      cCodTipRec,ntasintcom,cCodSitSol,nNumDiaGra,nnumdiagraapr,dFecDesRef,dFecVenRef,    
      lCuotaCons =CASE WHEN lCuotaCons = 'TRUE' 
                             THEN 1 
                             ELSE 0 
                        END,    
      cLibAmoCre,cTipPeriodo,cCodTipCuo,cCodModCre,nDiaFecFij,nNumDesemb,cTipDocIde,cNroDocIde,cClaSolCre,    
      dIniLinSol,dFinLinSol,dIniLinApr, dFinLinApr,cCodLinCre,    
      lTieneLin=CASE WHEN lTieneLin = 'TRUE' 
                             THEN 1 
                             ELSE 0 
                        END,    
      cCodConven,
      lConConven=CASE WHEN lConConven = 'TRUE' 
                             THEN 1 
                             ELSE 0 
                        END,    
      nNroLinFin,ctiptascom,cCodIntCon,ctiptasmor,ntasintmor,nNroTasCom,nNroTasMor, cIndGenOP, ccodparcam,
      ccodciiusol, criecrecam, ccodmoddes, ccodctaaho,ccodinsfin, cnomtitular, ccodcorade
      INTO #CURSOLICI    
      FROM OPENXML (@IDOC, '/VFPData/cursolicitud',1)    
      WITH    
            (ccodsolcre char(10),ccodtipsol char(3),ccodclient char(14),ccodmoneda char(1),nmonsolcre numeric(14,4),    
            ccodusuana char(6),nnumcuosol smallint, nplasolcre smallint,dfecsolcre datetime,    
            ccodususol char(6),cmonedaapr char(1),nmonsugana numeric(14,4), cdescrisol varchar(40),nmonaprcre numeric(14,4),    
            nnumcuoapr smallint,nplaaprcre smallint,dfecaprcre datetime,cobsanacre text,    
            ccodexpcli char(9),ccodestsol char(1),ccodoficin char(3),ccodactana char(7),ccodtipact char(3),ccodcomite char(3),    
            ccodplazo char(1),dfecmodcre datetime,ccodusuing char(6),lhistoria varchar(10),ccrenuevo char(1),ccrenorref char(1),    
            ccodmotsol char(1),ccodtipcre char(2),ccodproduc char(2),ccodsubpro char(2),ccodrecurs char(2),    
            ccodtiprec char(2),ntasintcom numeric(14,4),ccodsitsol char(2) ,nnumdiagra smallint,nnumdiagraapr smallint,dfecdesref datetime,    
            dfecvenref datetime,lcuotacons varchar(10),clibamocre char(1),ctipperiodo char(1),ccodtipcuo char(1),ccodmodcre char(2),    
            ndiafecfij smallint,nnumdesemb smallint,ctipdocide char(1),cnrodocide char(15),cclasolcre char(1),    
            dinilinsol datetime,dfinlinsol datetime,dinilinapr datetime,dfinlinapr datetime,ccodlincre char(10),ltienelin varchar(10),    
            ccodconven char(6),lconconven varchar(10),nnrolinfin int,ctiptascom char(2),ccodintcon char(5),    
            ctiptasmor char(2),ntasintmor numeric(14,4),nnrotascom int,nnrotasmor int, cindgenop char(1), ccodparcam char(2),
            ccodciiusol char(4), criecrecam char(1), ccodmoddes char(1), ccodctaaho varchar(30), 
            ccodinsfin char(3), cnomtitular varchar(250), ccodcorade char(15))
      IF @@ERROR <>0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END    

--- Removiendo el Documento XML    
      EXEC SP_XML_REMOVEDOCUMENT @IDOC    
END

      EXEC SP_XML_PREPAREDOCUMENT @idoc OUTPUT, @x_xDetGasTos
      SELECT  ccodgascre, nmongascre, act, @x_ccodsol as ccodsolcre,      
                  nmonvalase, ncodgascor, nnumvalgas
      INTO #CurGastos
      FROM OPENXML(@idoc,'/VFPData/curgastos',1) 
    WITH (ccodgascre char(5), nmongascre  numeric(9,4),    act bit,
              ccodsolcre char(10),  nmonvalase  numeric(9,4), ncodgascor int,
			  nnumvalgas smallint)

      EXEC SP_XML_REMOVEDOCUMENT @idoc 


SELECT	@x_cCodUsu	= @x_cCodUsuSco, 
		@x_dFecSis	= dFecModCre ,
		@x_cCodTipCre = cCodTipCre ,	
		@x_cCodProduc = cCodProduc ,	
		@x_cCodSubPro = cCodSubPro,
		@x_cCodModCre = cCodModCre ,
		@nNumCuoApr = nNumCuoApr
FROM #CURSOLICI 

IF	@x_cCodTipCre +	@x_cCodProduc +	@x_cCodSubPro  IN ('020209','110205','120209','130209')
	AND @x_cCodModCre <> '06' AND @nNumCuoApr = 1
BEGIN
	SET @x_cMsgRetTrx = 'PARA CREDITOS AGROPECUARIOS A UNA SOLA CUOTA,' + CHAR(10) + CHAR(13) + 
						'LA MODALIDAD DEBE SER LIBRE AMORTIZACION'
	ROLLBACK TRANSACTION
	RETURN
END

--================================================
--  VALIDA DETALLE DE LINEA DE FINANCIAMIENTO 
--================================================
DECLARE @nNroLinFin INT,
		@nNroTasApl INT,
		@cCodMotSol CHAR(1)
	 
SELECT @nNroLinFin = nNroLinFin,
	   @nNroTasApl = nNroTasMor
FROM #CURSOLICI

IF @cCodMotSol <> '4'
BEGIN
	IF @nNroTasApl = 0 OR @nNroLinFin = 0 OR NOT EXISTS (SELECT nTasMorato FROM KPYDTasLinFin WHERE nNroLinFin = @nNroLinFin AND nNroTasApl = @nNroTasApl)
	BEGIN
		SET @x_cMsgRetTrx = 'CODIGO DE TASA MORATORIA APLICADO NO VALIDO,POR FAVOR REVISAR.'
		ROLLBACK TRANSACTION
		RETURN
	END
END 

--/**********************************************************************************************
--    MODIFICACIONES PARA EL CALCULO, REGISTRO Y RETORNO DEL SCORE Y MONTO ACUMULADO DE DEUDA
--***********************************************************************************************/

      
-- VARIABLES
SELECT    @cCodCliente = cCodClient,
		  @cCodMoneda = cMonedaApr,
		  @nMonSolCre = nMonAprCre,
		  @dFecSolCre = dFecModCre,
		  @cCodUsuIng = @x_cCodUsuSco,
		  @pcMotSol   = CCODMOTSOL,
		  @cCodTipCre = cCodTipCre,
		  @cCodSubPro = cCodTipCre+ccodproduc+cCodSubPro,
		  @nPlazo     = nPlaAprCre,
		  @nNumCuoApr = nNumCuoAPr,
		  @nTasInt    = nTasIntCom,
		  @x_cCodModCre = cCodModCre
FROM #CURSOLICI


SELECT @x_ccodexpaho = cCodExpcli
FROM CMACHYOCLI..clidexpediente  WITH (NOLOCK)
      WHERE cCodClient = @cCodCliente
            AND cTipExpCli = 'A'
            AND lconestado = 1

SELECT @x_ccodexpKpy = cCodExpcli
FROM CMACHYOCLI..clidexpediente  WITH (NOLOCK)
      WHERE cCodClient = @cCodCliente
            AND cTipExpCli = 'K'
            AND lconestado = 1

SET @x_ccodexpaho = ISNULL(@x_ccodexpaho,'')
SET @x_ccodexpKpy = ISNULL(@x_ccodexpKpy,'')

------------------------------------------------------------------------------------------------------------   
 --  Al aprobar una solicitud de crédito, por defecto la fecha de desembolso igual a la fecha de aprobación    
 --  Ademas por defecto el  Numero de Desembolsos = 1    
-------------------------------------------------------------------------------------------------------------   
      UPDATE #CURSOLICI 
            SET dFecDesRef=dFecAprCre,
                  nNumDesemb=1 
            WHERE (cCodEstsol = 'A' and cCodSitSol = 'P') or cCodEstSol='B'
      IF @@ERROR <>0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END  
      
            
      
      UPDATE KPYMSOLICITUD 
      SET  cCodTipSol   =#CURSOLICI.cCodTipSol ,    
            cCodClient  =#CURSOLICI.cCodClient,    
            cCodMoneda  =#CURSOLICI.cCodMoneda,    
            nMonSolCre  =#CURSOLICI.nMonSolCre,    
            cCodUsuAna  =#CURSOLICI.cCodUsuAna,    
            nNumCuoSol  =#CURSOLICI.nNumCuoSol,    
         nPlaSolCre  =#CURSOLICI.nPlaSolCre,    
            dFecSolCre  =#CURSOLICI.dFecSolCre,    
            cCodUsuSol  =#CURSOLICI.cCodUsuSol,    
            cMonedaApr  =#CURSOLICI.cMonedaApr,    
            nMonSugAna  =#CURSOLICI.nMonAprCre,    
            cDescriSol  =#CURSOLICI.cDescriSol,    
            nMonAprCre  =#CURSOLICI.nMonAprCre,    
            nNumCuoApr  =#CURSOLICI.nNumCuoApr,    
            nPlaAprCre  =#CURSOLICI.nPlaAprCre,    
            dFecAprCre  =#CURSOLICI.dFecAprCre,    
            cobsanacre  =#CURSOLICI.cobsanacre,    
            cCodExpCli  =#CURSOLICI.cCodExpCli,    
            cCodEstSol  =#CURSOLICI.cCodEstSol,    
            cCodOficin  =#CURSOLICI.cCodOficin,    
            cCodActAna  =#CURSOLICI.cCodActAna,
            cTipActSis  =#CURSOLICI.cCodTipAct,
            cCodTipAct  =#CURSOLICI.cCodTipAct,      ---- HASTA QUE SE EVALUE CON SCORING   
            cCodComite  =#CURSOLICI.cCodComite,    
            cCodPlazo   =#CURSOLICI.cCodPlazo,    
            dFecModCre  =#CURSOLICI.dFecModCre,    
            cCodUsuIng  =@x_cCodUsuSco,    
            lHistoria   =#CURSOLICI.lHistoria,    
            cCreNuevo   =#CURSOLICI.cCreNuevo,    
            cCreNorRef  =#CURSOLICI.cCreNorRef,    
            cCodMotSol  =#CURSOLICI.cCodMotSol,    
            cCodTipCre  =#CURSOLICI.cCodTipCre,    
            ccodproduc  =#CURSOLICI.ccodproduc,    
            cCodSubPro  =#CURSOLICI.cCodSubPro,    
            cCodRecurs  =#CURSOLICI.cCodRecurs,    
            cCodTipRec  =#CURSOLICI.cCodTipRec,    
            ntasintcom  =#CURSOLICI.ntasintcom,    
            cCodSitSol  =#CURSOLICI.cCodSitSol,    
            nNumDiaGra  =#CURSOLICI.nNumDiaGra,  
            nnumdiagraapr =#CURSOLICI.nNumDiaGraApr,
            dFecDesRef  =#CURSOLICI.dFecDesRef,    
            dFecVenRef  =#CURSOLICI.dFecVenRef,    
            lCuotaCons  =#CURSOLICI.lCuotaCons,    
            cLibAmoCre  =#CURSOLICI.cLibAmoCre,   
     cTipPeriodo =#CURSOLICI.cTipPeriodo,    
            cCodTipCuo  = '4',    
            cCodModCre  =#CURSOLICI.cCodModCre,    
            nDiaFecFij  =#CURSOLICI.nDiaFecFij,    
            nNumDesemb  =#CURSOLICI.nNumDesemb,    
            dIniLinSol  =#CURSOLICI.dIniLinSol,    
            dFinLinSol  =#CURSOLICI.dFinLinSol,    
            dIniLinApr  =#CURSOLICI.dIniLinApr,    
            dFinLinApr  =#CURSOLICI.dFinLinApr,    
            cCodLinCre  =#CURSOLICI.cCodLinCre,    
            lTieneLin   =#CURSOLICI.lTieneLin,    
            cCodConven  =#CURSOLICI.cCodConven,    
            lConConven  =#CURSOLICI.lConConven,    
            nNroLinFin  =#CURSOLICI.nNroLinFin,    
            ctiptascom  =#CURSOLICI.ctiptascom,    
            cCodIntCon  =#CURSOLICI.cCodIntCon,    
            ctiptasmor  =#CURSOLICI.ctiptasmor,    
            ntasintmor  =#CURSOLICI.ntasintmor,    
            nNroTasCom  =#CURSOLICI.nNroTasCom,    
            nNroTasMor  =#CURSOLICI.nNroTasMor,    
            cIndGenOP   =#CURSOLICI.cIndGenOP,
            ccodparcam  =#CURSOLICI.ccodparcam,
            ccodciiusol =#CURSOLICI.ccodciiusol,
            criecrecam  =#CURSOLICI.criecrecam,
           nValScoSol  = @nValScoSol,
            cTipActSco  = @cTipActSco, 
      nNumScoCli  = @nNumScoCli,
         ccodcorade  =#CURSOLICI.ccodcorade,
            lestNivSco  = 0,
            cClaSolCre = CASE WHEN #CURSOLICI.cCodTipCre='04' 
                                         THEN 'V'
                                         ELSE 'C'
                             END,
            lFlgMiVivi  = CASE WHEN #CURSOLICI.cCodTipCre='04' 
                                         THEN 1 
                                         ELSE 0 
                                   END         
      FROM KPYMSOLICITUD  WITH (NOLOCK)
            INNER JOIN #CURSOLICI     
                  ON(KPYMSOLICITUD.CCODSOLCRE = #CURSOLICI.CCODSOLCRE)    
      IF @@ERROR <>0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END    
	 
	/******Actualizar la tasa de interes de crerefina cuando es variacion ppg************************************/
	/************************************************************************************************************/
	UPDATE A
	SET A.nTasIntCom = B.ntasintcom,
		A.cTipTasCom = B.cTipTasCom,
		A.nTasIntMor = B.nTasIntMor,
		A.cTipTasMor = B.cTipTasMor
	FROM KPYDCreRefina A
		INNER JOIN #CURSOLICI B
			ON A.cCodSolCre = B.CCODSOLCRE
				AND B.cCodMotSol = '9'
				AND A.cCodTipRep = '2'      
	WHERE  A.cCodSolCre = B.CCODSOLCRE
					
	/***********************************************************************************************************/
	/***********************************************************************************************************/
	
/**************************************************************************************************
                             CAMBIOS PARA CREDITSCORING
***************************************************************************************************/
-- RECUPERAMOS EL SALDO CAPITAL DE LAS AMPLIACIONES

UPDATE B
SET B.nMonCapDes = A.nMonCapDes,
      B.nMonCapPag = A.nMonCapPag,
      B.nMonIntPro = A.nMonIntPro,
      B.nMonIntFec = A.nMonIntFec,
      B.nMonIntPag = A.nMonIntPag,
      B.nMonMorPro = A.nMonMorPro,
      B.nMonMorPag = A.nMonMorPag,
      B.nMonGasPro = A.nMonGasPro,
      B.nMonGasPag = A.nMonGasPag 
FROM KPYMCRECONVEN A
      INNER JOIN  KPYDCreRefina  B
            ON cCodCtaCre = cCtaCreAnt 
WHERE B.cCodSolCre = @x_cCodSol



SELECT @nCapAmpli = nMonCapDes - nMonCapPag 
FROM KPYDCreRefina 
WHERE cCodSolCre = @x_cCodSol

SET @nCapAmpli = ISNULL(@nCapAmpli,0)


DECLARE @lnactSco INT = 0

SET @lnactSco = 0


IF (@pcMotSol ='8' OR  @pcMotSol = '3') AND @x_cCodModCre IN('01','03') AND @lnactSco = 1 
BEGIN
            
      IF NOT EXISTS( SELECT nNumScoCli
                           FROM KPYMSCORINCRE A WITH (NOLOCK)
                                   INNER JOIN KPYMPesModSco B  WITH (NOLOCK)
                                         ON A.cTipModSco = B.cTipModSco
                             WHERE A.cCodCliente= @cCodCliente
                                   AND A.lestado = 1
                                   AND A.cTipModSco='PRE'
                     AND A.cCodoficin = @x_cCodOficin
                                   AND ISNULL(A.cCodSolcre,'') = @x_cCodSol )
      BEGIN
                  EXEC KPY_RetNivRiePreSco_SP 
                                         @dFecSolCre, 
                                         @cCodCliente, 
                                         @x_cCodUsuSco,
                                         'R',
                                         @x_cNivRie   OUTPUT,
                                         @nValScoSol  OUTPUT,
                                         @nNumScoCli  OUTPUT,
                                         @nMorAntAmo  OUTPUT,
                                         @x_cCodOficin,
                                         @x_cDesRazEva OUTPUT
                  SET @x_cNivRie = ''     
                  
                  UPDATE KPYMSCORINCRE  
                  SET cCodSolcre = @x_cCodSol
     WHERE cCodCliente = @cCodCliente
                        AND cCodoficin = @x_cCodOficin     
                        AND cCodSolcre IS NULL
                        AND cTipModSco = 'PRE'
                        AND lestado =1
                        
                  IF @@ERROR <>0    
                  BEGIN   
                        ROLLBACK TRANSACTION    
                        RETURN    
                  END   
      END

      EXEC KPY_RetNivRiePosSco_SP 
                                   @dFecSolCre, 
                                   @cCodCliente, 
                                   @x_cCodUsuSco,
                                   'R',
                                   @x_cCodSol,
                                   @x_cNivRie   OUTPUT,
                                   @nValScoSol  OUTPUT,
                                   @nNumScoCli  OUTPUT,
                                   @nMorAntAmo  OUTPUT,
                                   @x_cCodOficin,
                                   @x_cDesRazEva OUTPUT,
                                   @x_cModSco OUTPUT
                             
      IF @x_cModSco IN ('T','E')
      BEGIN  
            /*SCORING CUASI EXPERTO*/
            EXEC KPY_RetNivRieCuaSco_SP 
                                   @dFecSolCre, 
                                   @cCodCliente, 
                        @x_cCodUsuSco,
                                   'R',
                                   @x_cCodSol,
                                   @x_cNivRie   OUTPUT,
                                   @nValScoSol  OUTPUT,
                                   @nNumScoCli  OUTPUT,
                                   @nMorAntAmo  OUTPUT,
                                   @x_cCodOficin

            /*BUSCAR EL SCORING FINAL*/
            EXEC KPY_RetScoFin_SP 
                                   @dFecSolCre, 
                                   @cCodCliente, 
                                   @x_cCodOficin,
                                   @nValScoSol OUTPUT,
                                   @x_cNivRie  OUTPUT,     
                                   @x_cCodSol  

            IF @@ERROR <>0    
            BEGIN   
                  ROLLBACK TRANSACTION    
                  RETURN    
            END 
      END
      SELECT A.cCodctaCre, nMonSalCap = (nMonCapDes - nMonCapPag), cEstCreCon, cCodTipMon, TipCre = 'KPY'
            INTO #CurTotCtaCli
      FROM KpyMCreconVen A  WITH (NOLOCK)
            INNER JOIN kpytctarelcli B  WITH (NOLOCK)
                  On A.cCodCtaCre = B.cCodCtaCre
      WHERE cCodAplica = 'KPY' 
            AND cCodCliente = @cCodCliente
            AND cEstCreCon NOT IN ('X','E','G')
            
      INSERT INTO #CurTotCtaCli
      -- Cartas Fianza
      SELECT A.cCodCtaCre, nMonSalCap = A.nValCarFia, cEstCrecon = A.cEstCarFia, A.cCodTipMon, TipCre = 'FIA'
      FROM KpyMCreCarFia A  WITH (NOLOCK)
            INNER JOIN kpytctarelcli B  WITH (NOLOCK)
                  ON A.cCodCtaCre = B.cCodCtaCre
      WHERE cCodAplica = 'FIA' 
            AND B.cCodCliente = @cCodCliente
            AND A.cEstCarFia NOT IN ('X','E','G')

      -- DETERMINAMOS EL MONTO A ADICIONAR AL SALDO ACUMULADO SEGUN EL MOTIVO DE LA SOLICITUD 
      SET
      @nMonSolCre =     
            CASE 
                  WHEN @pcMotSol In('4','5')   THEN 0                                         -- Refinanciación  y Reprogramación
                  WHEN @pcMotSol In('3')       THEN @nMonSolCre - @nCapAmpli --Ampliación
                  ELSE @nMonSolCre 
            END
      -- RECUPERANDO EL TIPO DE CAMBIO
      SELECT @nMonTipCam =dbo.ADM_TipCam_fx(@dFecSolCre,'F')

      IF ISNULL(@nMonTipCam,0) = 0
            SET @nMonTipCam = 1.00

      -- DETERMINANDO EL MONTO TOTAL ACUMULADO CON EL QUE SE DETERMINARÁ EL NIVEL DE APROBACION
      SET @x_MonAcu = 0
      IF @cCodMoneda = '1'
          SELECT @x_MonAcu = ISNULL(SUM(     CASE WHEN cCodTipMon = '1'
                                                                 THEN nMonSalCap
                                                                 ELSE (nMonSalCap * @nMonTipCam)
                                                           END),0) + @nMonSolCre
            FROM #CurTotCtaCli
      ELSE
            SELECT @x_MonAcu = ISNULL(SUM(     CASE WHEN cCodTipMon = '2'
                                                                 THEN nMonSalCap
                                                                 ELSE (nMonSalCap / @nMonTipCam)
                                                           END),0) + @nMonSolCre
            FROM #CurTotCtaCli

      DROP TABLE #CurTotCtaCli


      DECLARE @x_SubPro CHAR(04),@x_cRecSol BIT,@x_cCodEstSol CHAR(1)
      SELECT      @x_SubPro = cCodTipCre + ccodproduc,
                  @x_cRecSol = 0
      FROM #CURSOLICI

      -- OBTENIENDO EL NIVEL DE APROBACION SEGUN EL MONTO ACUMULADO, EL SCORE Y LA MONEDA

      IF @x_cModSco IN('T','E')
      BEGIN
            -- OBTENIENDO EL NIVEL DE APROBACION SEGUN EL MONTO ACUMULADO, EL SCORE Y LA MONEDA
      
            
            SELECT @cTipActSco = A.cTipActSco, @x_ActSco = CASE 
                                                                                        WHEN A.cTipActSco = 'N01' THEN 'NIVEL 1-SENIOR II'
                                                                                        WHEN A.cTipActSco = 'N02' THEN 'NIVEL 2-COORDINADOR '
                                                                                        WHEN A.cTipActSco = 'N03' THEN 'NIVEL 3-ADMINISTRADOR'
                                                                                        WHEN A.cTipActSco = 'NAA' THEN 'NIVEL AUTO-ANALISTA'
                                                                                  END,
                     @x_cRecSol= cFlaEstSol,@x_cCodEstSol = cCodEstSol
            FROM KPYTNivAprSco A  WITH (NOLOCK)
                  INNER JOIN KPYTTipActSco B  WITH (NOLOCK)
                        ON A.cTipActSco = B.cTipActSco
            WHERE (@nValScoSol BETWEEN nScoIniNiv AND nScoFinNiv)
                  AND (@x_MonAcu > nMonIniNiv AND @x_MonAcu <= nMonFinNiv)
                  AND lEstNivSco = 1
                  And cCodTipMon = @cCodMoneda
                  AND cCodOficin = @x_cCodOficin
                  
            -- PERSONALIZANDO MENSAJES PARA CASOS NO CONTEMPLADOS POR EL SCORING
            SELECT 
                  @x_ActSco = 
              CASE 
                             WHEN @cCodTipCre = '01'      THEN 'POLITICAS PARA CREDITOS COMERCIALES'
                             WHEN @cCodTipCre = '04'      THEN 'POLITICAS PARA CREDITOS HIPOTECARIOS'
                             WHEN @cCodSubPro = '030207' THEN 'POLITICAS PARA CREDITOS CON CTS'
                             WHEN @cCodSubPro = '030106' THEN 'POLITICAS PARA CREDITOS CON PF'
                             WHEN @cCodSubPro = '030103' THEN 'POLITICAS PARA CREDITOS ADMINISTRATIVOS'
                             WHEN @cCodSubPro = '030104' THEN 'POLITICAS PARA CREDITOS A DIRECTORES'
                             WHEN CASE 
                                         WHEN @cCodMoneda = '1' THEN @x_MonAcu / @nMonTipCam 
                                         ELSE @x_MonAcu 
                                   END >= 30000 THEN 'MONTO ACUMULADO SUPERA LOS US$ 30,000'
                             WHEN @x_ActSco IS NULL  THEN 'NO TIENE NIVEl DE APROBACIÓN REGISTRADO'
                             ELSE @x_ActSco
                        END
            SET @x_ActSco = ISNULL(@x_ActSco,'')
            
                  
            IF @cTipActSco IS NOT NULL and @cTipActSco != ''
            BEGIN
                  UPDATE KPYMSOLICITUD SET     
                        nValScoSol  = @nValScoSol,
              cTipActSco  = @cTipActSco, 
                        nNumScoCli  = @nNumScoCli,
                        cCodEstSol  = CASE WHEN  @x_cRecSol = 1
                                                     THEN @x_cCodEstSol
                                                     ELSE cCodEstSol
                                               END,
                                                     
                        lestNivSco  = 1
                  FROM KPYMSOLICITUD WITH (NOLOCK)
                  WHERE KPYMSOLICITUD.cCodsolcre = @x_cCodSol 
                             AND CASE WHEN @x_cModSco IN ('T','E') 
                                               THEN 1 
												ELSE 0 
                                   END = 1     
                  IF @@ERROR <>0    
                  BEGIN    
                        ROLLBACK TRANSACTION   
                        RETURN    
                  END 
            END
            ELSE
            BEGIN
                  SET @x_cDesRazEva='NO TIENE NIVEL DE APROBACIÓN'
            END
      END
      
      /**************************************************************************************************
                  FIN DE CAMBIOS PARA CREDITSCORING
      ***************************************************************************************************/
END
      --Para credigas
      IF @cCodSubPro NOT IN ('020120','030120','010120')
      BEGIN
            DELETE FROM KPYDGasGenCre
            WHERE cCodSolCre = @x_cCodSol
            IF @@ERROR <>0    
                  BEGIN    
                        ROLLBACK TRANSACTION    
                        RETURN    
                  END    
            END

      INSERT INTO KPYDGasGenCre 
            (cCodSolCre, cCodGasCre, nMonGasGen, nMonGasIni, nMonSegAse, nCodGasCor, nNumValGas)
      SELECT 
             cCodSolCre, cCodGasCre, nmongascre, nmongascre, nMonValAse, nCodGasCor, nNumValGas
      FROM #CurGastos
      WHERE Act = 1 
      IF @@ERROR <> 0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END 
		
	--\\ Inserta afiliados a seguro //--	
	IF @x_xCliAfiSeg IS NOT NULL
	BEGIN
		EXECUTE KPY_InsCliAfiSeg_SP
					@x_cCodSolCre = @x_cCodSol,
					@x_xCliAfiSeg = @x_xCliAfiSeg,
					@x_cCodUsu    = @x_cCodUsu,
					@x_dFecSis    = @dFecSolCre
		IF @@ERROR <> 0    
		BEGIN
			ROLLBACK TRANSACTION
			RETURN  
		END
	END

	--\\ Actualiza seguimiento afiliación seguro desgrav. //--
	EXECUTE dbo.KPY_InsSegAfiIni_SP
				@x_cCodSol	  = @x_cCodSol,
				@x_cCodUsu    = @x_cCodUsu,
				@x_cCodOficin = @x_cCodOficin
      IF @@ERROR <> 0    
            BEGIN    
         ROLLBACK TRANSACTION    
                  RETURN    
            END    

      IF EXISTS(
            SELECT ccodsolcre 
FROM KPYHSolTasEsp  WITH (NOLOCK)
            WHERE cCodSolCre = @x_cCodSol)
            BEGIN
                  UPDATE KPYHSolTasEsp
                        SET cDesMotivo = @x_cDesMotivo,
                        cCodUsuReg = @x_cCodUsu,
                             dFecRegTas = @x_dFecSis,
                              dFecHorSis = GETDATE(),
                             nTasIntIni = @x_nTasIntMin,
                             nTasIntFin = @nTasInt
                  WHERE cCodSolCre = @x_cCodSol
                  IF @@ERROR <>0    
                        BEGIN    
                             ROLLBACK TRANSACTION    
                             RETURN    
                        END    
            END
      ELSE
            BEGIN
                  INSERT INTO KPYHSolTasEsp
                        (
                        cCodSolCre, dFecRegTas, dFecHorSis, nTasIntIni, 
                        nTasIntFin, cCodUsuReg, cDesMotivo
                        )
                  VALUES
                        (
                        @x_cCodSol, @x_dFecSis, GETDATE(), @x_nTasIntMin,
                        @nTasInt, @x_cCodUsu, @x_cDesMotivo
                        )
                  IF @@ERROR <>0    
                        BEGIN    
                             ROLLBACK TRANSACTION    
                             RETURN    
                        END    
            END

  -----ACTUALIZA ESTADO DE REFINANCIADOS    
      UPDATE KPYDCreRefina
            SET cCodEstRef = @x_cEstSol
      WHERE cCodSolCre = @x_cCodSol
      IF @@ERROR <>0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END  
            ---END  

      IF (@x_cEstSol = 'A' AND @x_ccodSit = 'P') or (@x_cEstSol = 'B')
      BEGIN
            /* DESTINO DEL CREDITO */
            EXEC KPY_ModDesCre_sp @x_DesCre, @x_TipDes, @x_cCodSol, '', @x_cCodUsu, @x_dFecSis,@x_xcurProEco, @x_xcurSubDesCre
            IF @@ERROR <>0    
                  BEGIN    
                        ROLLBACK TRANSACTION    
                        RETURN    
                  END
      END   

      IF @x_cEstSol = 'D'
      BEGIN
            /* denegación de solicitudes */
            DECLARE @pnIdeDoc INT
      
            SELECT @x_cCodUsu = @x_cCodUsuSco, @x_dFecSis = dFecModCre FROM #CURSOLICI 
      
            /* ASIGNACION DE GASTOS */
            EXEC sp_xml_preparedocument @pnIdeDoc OUTPUT, @x_MotDen

            SELECT      @x_cCodSol AS ccodsolcre, @x_cCodOficin AS ccodoficin,  
                        'DEN' AS ccodopcion, cCodMotAnu, cDesObs,
                        @x_cCodUsu as cCodUsu, getdate() as dfechorsis
                  INTO #curanurec
                  FROM OPENXML(@pnIdeDoc,'/VFPData/curanurec',1)
                        WITH (ccodmotanu char(3), cdesobs varchar(120))
            EXEC sp_xml_removedocument @pnIdeDoc

            INSERT INTO KPYDAnuRecDen
            (
                  cCodSolCre, cCodCliente, cCodUsuAna,
                  nMonSolici, cCodTipMon, cCodOficin,
                  cCodOpcion, cCodTipOpc, cDesObserv,
                  cCodUsuario, dFecHorSis
            )
            SELECT 
                  REC.ccodsolcre, SOL.cCodClient, SOL.ccodusuana,
                  CASE WHEN SOL.nMonAprCre = 0.00 
                        THEN SOL.nMonSolCre
                        ELSE SOL.nMonAprCre  
                  END, SOL.cCodMoneda, REC.ccodoficin, 
                  REC.ccodopcion, REC.cCodMotAnu,
                  REC.cDesObs, REC.cCodUsu, REC.dfechorsis
            FROM #curanurec REC  WITH (NOLOCK)
                  INNER JOIN KPYMSOLICITUD SOL  WITH (NOLOCK)
              ON REC.ccodsolcre = SOL.cCodSolCre
            IF @@ERROR <> 0
                  BEGIN
      ROLLBACK TRANSACTION
                        RETURN -1
                  END

            IF  @x_ccodSit = 'D'
  BEGIN
                        INSERT INTO CRICMACHYO..CRIMObservado
                             (
                             cCodProceso, cMesProceso, dFecProceso,
							 cCodSBS, cCodCuenta, cCodCliente, cNomDeudor,
                             cCodCoDeudor, cNomCoDeudor, cCodGirIFI, cCodGirador,
                              cNomGirador, cCodClaPer, cCodTipDocId, cNroDocIde,
                             cCodTipDocTr, cNroDocTri, cCodTipMon, cCodMotivo,
                             cCodExpAho, cCodExpCre, nImpDeuda, cCodCal,
                             cDatAdicio, cFlagDeuEli, cCodOfiPro, cCodUsuRes,
                             cCodOfiMod, cTipDetReg, nCanIFIRep, cTipCreGen,
                             cCodUsuAna
                             )
                        SELECT     sol.ccodOficin, cast(year(@x_dfecsis) as CHAR(4)) + right('00' + rtrim(cast(month(@x_dfecsis) as CHAR(2))),2),
                                   @x_dfecsis, cli.cCodSbs, cCodSolCre, cCodClient, replace(cli.cnomcliente,',',''),
                                   isnull(#detCony.ccodconyug,''), isnull(replace(#detCony.CNOMCLIENTE,',',''),''), '107', sol.ccodoficin, 
                                   cdesOficin, cCodClaPer, CASE WHEN ccodclaper = '1' THEN ccodtipdocid ELSE '' END,  CASE WHEN ccodclaper = '1' THEN cli.cnrodocide ELSE '' END,
                                    CASE WHEN ccodclaper <> '1' THEN '5' ELSE '' END,  CASE WHEN ccodclaper <> '1' THEN cnrodoctri ELSE '' END, ccodmoneda, '70218',
                                   @x_ccodexpaho, @x_ccodexpKpy, nmonsolcre, ISNULL(cClaFin,'') as cClaFin, 
                                   cDescriSol, 'A', sol.ccodOficin, @x_ccodusu, 
                                   sol.ccodOficin, null, null, null,
                                   ccodUsuAna
                        FROM KPYmSolicitud sol  WITH (NOLOCK)
                             INNER JOIN CMACHYOCLI..CLIMCLIENTES CLI  WITH (NOLOCK)
                                   ON sol.ccodclient = cli.ccodcliente
                             LEFT JOIN GENTOficinas OFI WITH (NOLOCK)
                                   ON sol.ccodoficin = ofi.ccodoficin
                             LEFT JOIN CRICMACHYO..URIRCCMAE RCC WITH (NOLOCK)
                                   ON cli.ccodsbs = rcc.ccodsbs
                             LEFT JOIN 
                                   (SELECT NAT.ccodcliente, ccodconyug, CNOMCLIENTE
                                               FROM cmachyocli..climpernat nat  WITH (NOLOCK)
                                                     INNER JOIN cmachyocli..climclientes cli  WITH (NOLOCK)
                                                           ON nat.ccodconyug = cli.ccodcliente
                                         WHERE NAT.ccodcliente = @cCodCliente ) AS #detCony
                             ON cli.ccodcliente = #detCony.ccodcliente
                        WHERE ccodSolCre = @x_cCodSol
                        IF @@ERROR <> 0
                             BEGIN
                                   ROLLBACK TRANSACTION
                                   RETURN -1
                             END
                  END
      END

-- INSERTA DATOS DE LA MODALIDAD DE DESEMBOLSO
      IF @pcMotSol = '8'
            BEGIN  
                  IF EXISTS (SELECT cCodSolCre FROM kpydmoddescre WHERE cCodSolCre = @x_cCodSol)
                        BEGIN
                             UPDATE kpydmoddescre
                                   SET cCodModDes = B.cCodModDes,
                                         cCodCtaAho = B.cCodCtaAho,
                                         cCodInsFin = B.cCodInsFin, 
                                         cNomTitular = B.cNomTitular, 
                                         cCodUsuMod = @x_ccodusu,
                  dFecVinCta = @x_dFecSis
                             FROM kpydmoddescre A INNER JOIN #CURSOLICI B
                               ON A.cCodSolCre = B.cCodSolCre
                        END
                  ELSE 
                        BEGIN
         INSERT INTO kpydmoddescre
                                   (cCodSolCre, cCodModDes, cCodCtaAho,
                                   cCodInsFin, cNomTitular, cCodEstVin,
                                   cCodUsuMod, dFecVinCta)
                              SELECT
                                   cCodSolCre, cCodModDes, cCodCtaAho,
                                   cCodInsFin, cNomTitular, 'V',
                                   @x_ccodusu, @x_dFecSis
                             FROM #CURSOLICI
                        END
                  IF @@ERROR <> 0
                        BEGIN
                             ROLLBACK TRANSACTION
                             RETURN -1
                        END
            END
      
	--  DATOS TIPO DE GARANTIA DE CARTA FIANZA 
		IF @x_xGarCarFia IS NOT NULL AND @pcMotSol = '6'
		BEGIN
			EXEC SP_XML_PREPAREDOCUMENT @idoc OUTPUT, @x_xGarCarFia
			SELECT  ccodsolcre, ccodtipgarfia, nporplafij, nporgarhip
			INTO #CurGarCarFia 
			FROM OPENXML(@idoc,'/VFPData/cursolgarfia',1) 
			WITH (ccodsolcre char(10), ccodtipgarfia char(1), nporplafij numeric(10,2),nporgarhip numeric(10,2))


			DELETE FROM KPYDTipGarCarFia
			WHERE cCodSolCre = @x_cCodSol

			INSERT INTO KPYDTipGarCarFia (cCodSolCre,cCodTipGarFia,nPorPlaFij,nPorGarHip,cCodUsuReg,dFecUsuReg)
			SELECT ccodsolcre, cCodTipGarFia, nPorPlaFij, nPorGarHip,@x_ccodusu,GETDATE()
			FROM #CurGarCarFia
		END

      SET @x_MsgValPar = ''

COMMIT TRANSACTION
/**********************************************************************************************************************************************************************************************/
GO
GRANT EXEC ON KPY_ManSolCre_sp TO adm_adm_rl
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_GenCreAut_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_GenCreAut_sp]
GO
/*******************************************************************************************
*	Copyright  2014 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo :				Generacion de Credito Automático
*  
*	Escrito por: 			PEREZ PEREZ, JOSE JESUS
*	Email/Movil/Phone:		operez@cmachuancayo.com.pe
*  
*	Fecha creacion: 2010.05.14
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*	Fecha  			Responsable		Descripcion del cambio
*	2011.01.25		AROBLE			Se adiciona el retorno de Linea 
*	2011.06.22		ASALAZ			Se adiciono un campo de evaluacon del scoring 
*	2012.01.07		OPEREZ			Se esta agregando el campo de jerarquia de nivel de aprobacion
*	2012.01.10		WTRINI			Se esta  genarando el destino de credito cuando es un tipo de credito adelanto de sueldo
*	2012.05.26		YGONZA			Se esta cambiando el campo @lcCodModCar CHAR(1) a CHAR(2) y 
*									tambien el campo cCodModCar del cursor @lCurDatCarFia
*	2012.06.21		YGONZA			Se hizo los cambios por agregar 2 campos a la tabla KPYMCreCarFia (cCodOblFia,cCodGrtFia)	
*	2012.07.07      CMUCHA			Se agregó campo lIndLeasin al retornar solicitud
*	2013.06.20		FASTUH			Se modifico segun nuevas adecuaciones en garantias.
*	2013.08.19		CMUCHA			Se actualiza cliente conyuge en KPYTCreMulCli
*	2013.09.19		CMUCHA			Se corrige la duplicidad en inserción de KPYTCreMulCli
*	2013.11.22		CMUCHA			Se agrega parametros a KPY_ManSolCre_SP y retorno de mensajes de validación
*	2014.01.14		FASTUH			Se agrego parametros a KPY_ManSolCre_SP 
*	2014.10.09		FASTUH			Se modifico para el registro de los montos de gravamen en soles 
*	2014.11.20		YGONZA			Se agrega parametro al sp KPY_ManSolCre_sp	
*	2015.06.09		FASTUH			Se agrego columna "nmontasgardol" a consulta de garantias 
	2015.07.13		YGONZA			Se considera tipo de credito cts
	2015.07.13		HVARGA			Se agrega validación ISNULL al resultado del SP KPY_RetCtaAhoCli_sp, para evitar 
									error de intento de inserción de valor Nulo en la tabla KPYDModDesCre
	2015.10.13		YGONZA			Actualiza estado del lote que garantiza Credijoyas
    2015.10.15		HVARGA			Se agrega 1 parámetro adicional al invocar el SP KPY_ManSolCre_sp

	Sintaxis de ejemplo:  

		EXEC KPY_GenCreAut_sp 
			@x_cCodCliente CHAR (12),
			@x_IntCreAut XML

*******************************************************************************************/
CREATE PROCEDURE KPY_GenCreAut_sp
	@x_cCodCliente CHAR(12),
	@x_cCodTipSol CHAR(2),
	@x_nMonSolCre NUMERIC (14,4),
	@x_cIndInsGar CHAR(1),
	@x_cCodFueIng CHAR(3),
	@x_xmlcursol TEXT,
	@x_currefina TEXT,
	@x_xmlIntCreAut XML ,
	@x_xmlGarCre XML,	
	@x_xDetGasTos TEXT,	
	@x_xDatCarFia XML,
	@x_cCodUsuGen CHAR(6),
	@x_cCodoficin CHAR(3),
	@x_cDesMotivo VARCHAR(100),
	@x_nTasIntMin NUMERIC (14,4),
	@x_cCodUsuSis VARCHAR(20),
	@x_cCodUsuSOP VARCHAR(20),
	@x_cVenOperac CHAR(3),
	@x_cSerTermin VARCHAR(20),
	@x_cCodCtaCre CHAR(18) OUTPUT,
	@x_cNroCarFia CHAR(14) OUTPUT,
	@x_lestNivSco BIT OUTPUT,
	@x_cResVal VARCHAR (20) OUTPUT,
	@x_cCodSolRet CHAR(10) OUTPUT,
	@x_cCodLinAut CHAR(10) OUTPUT
AS
SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON

DECLARE @lcCodSolCre CHAR(10),			@lcCodCIIUSol CHAR(4),			@ldFecSis DATE,
		@lccodmoneda CHAR(1),			@lnmonsolcre NUMERIC (14,4), 	@lccodconven CHAR(6),	
		@lEsConvenio BIT = 0,			@lcCodOficin CHAR(3),			@lcIndGenOP CHAR(1),
		@lnMonDesOPSol NUMERIC (14,2), 	@lnMonDesOPDol NUMERIC (14,2),	@lcTipAct VARCHAR(50),
		@lnMonAcu NUMERIC (14,4),		@lcmsg VARCHAR(200), 			@lcNivRieCli VARCHAR(50), 
		@lcDesRazEva VARCHAR(50),		@lcModSco VARCHAR(50),			@lcCarPer CHAR(3), 
		@lntipCamFij  NUMERIC(14,4),	@lcCodUsuAna CHAR(6),			@lcCodLinCre CHAR(10), 
		@lXMLCurGarLin XML,				@iDoc INT,						@lcCodDesCre CHAR(3), 
		@lcCodIns CHAR(3),				@lnplaaprcre INT,				@lntasintcom NUMERIC (14,4),
		@lcCodCliFav CHAR(12),			@lcCodTipGar CHAR(1), 			@lcCodModCar CHAR(2),		
		@lcObsCarFia VARCHAR(100),		@lcRefCarFia VARCHAR(MAX),		@ldFecCanFia  DATE,
		@lcCodOblFia VARCHAR(2),		@lcCodGrtFia VARCHAR(2),		@lcMsgRetTrx VARCHAR(200)

DECLARE @CurIntCreAut TABLE (	cCodLinCre CHAR(10),cCodCliente CHAR(12),
								CNOMCLIENTE VARCHAR(200),cCodRelCta CHAR(1),lIndAct BIT
							)

DECLARE @lCurDatCarFia TABLE(	cCodCliFav CHAR(12),cCodTipGar CHAR(1), cCodModCar CHAR(2),cCodOblFia VARCHAR(2),
								cCodGrtFia VARCHAR(2),cObsCarFia VARCHAR(100),cRefCarFia VARCHAR(MAX))							

DECLARE @CurMsjVal TABLE (cMenVal VARCHAR(200))

Exec sp_xml_preparedocument @idoc output, @x_xmlIntCreAut
	INSERT @CurIntCreAut
	SELECT  ccodlincre,ccodcliente ,cnomcliente ,
			ccodrelcta ,lindact
	FROM OPENXML(@idoc,'/VFPData/curintcreaut',1) 
    WITH (	ccodlincre char(10),ccodcliente char(12),cnomcliente varchar(200),
			ccodrelcta char(1),lindact bit
			)
	GROUP BY ccodlincre,ccodcliente ,cnomcliente ,
			 ccodrelcta ,lindact

EXEC sp_xml_removedocument @idoc
	

DECLARE @lCurDesCre TABLE (	cDescriDes VARCHAR(150),nmonPorAfe NUMERIC (14,2),
							cCodDesCre CHAR(2),cDesTipDes VARCHAR(150),
							lConEstado BIT,nMonTipDes NUMERIC (14,2),
							cCodTipDes CHAR(2),cIdeTipDes CHAR(6)
						)

CREATE TABLE #CURSOLICI	(	ccodsolcre char(10),ccodtipsol char(3),ccodclient char(14),ccodmoneda char(1),nmonsolcre numeric(14,4),    
							ccodusuana char(6),nnumcuosol smallint, nplasolcre smallint,dfecsolcre datetime,    
							ccodususol char(6),cmonedaapr char(1),nmonsugana numeric(14,4), cdescrisol varchar(40),nmonaprcre numeric(14,4),    
							nnumcuoapr smallint,nplaaprcre smallint,dfecaprcre datetime,cobsanacre text,    
							ccodexpcli char(9),ccodestsol char(1),ccodoficin char(3),ccodactana char(7),ccodtipact char(3),ccodcomite char(3),    
							ccodplazo char(1),dfecmodcre datetime,ccodusuing char(6),lhistoria varchar(10),ccrenuevo char(1),ccrenorref char(1),		    
							ccodmotsol char(1),ccodtipcre char(2),ccodproduc char(2),ccodsubpro char(2),ccodrecurs char(2),  		  
							ccodtiprec char(2),ntasintcom numeric(14,4),ccodsitsol char(2) ,nnumdiagra smallint,nnumdiagraapr smallint,dfecdesref datetime,    		
							dfecvenref datetime,lcuotacons varchar(10),clibamocre char(1),ctipperiodo char(1),ccodtipcuo char(1),ccodmodcre char(2),    		
							ndiafecfij smallint,nnumdesemb smallint,ctipdocide char(1),cnrodocide char(15),cclasolcre char(1),    
							dinilinsol datetime,dfinlinsol datetime,dinilinapr datetime,dfinlinapr datetime,ccodlincre char(10),ltienelin varchar(10),    		
							ccodconven char(6),lconconven varchar(10),nnrolinfin int,ctiptascom char(2),ccodintcon char(5),    		
							ctiptasmor char(2),ntasintmor numeric(14,4),nnrotascom int,nnrotasmor int, 
							cCodigoProd CHAR(6),cCodigoSubPro CHAR(6),cCodLinea CHAR(10),nMonCuoIni NUMERIC(14,4),
							nValTerreno NUMERIC(14,4), nValConstru NUMERIC(14,4), nValVivienda NUMERIC(14,4), lFlgMiVivi BIT,
							nMonSolAux  NUMERIC(14,4), nMonAprAux  NUMERIC(14,4), cNroInfPro VARCHAR(50) , cCodOrdPag CHAR(13),		 
							cindgenop char(1), ccodparcam char(2),ccodciiusol char(4), criecrecam char(1), nMonAhoAcu NUMERIC(14,4),
							cDesMotivo VARCHAR(100),cCodTipOpi CHAR(1),cCodInfRie CHAR(7),cCodAnaRie CHAR(6),ccodPromotor CHAR(6),
							ccodmoddes char(1), ccodctaaho varchar(30),ccodinsfin char(3), cnomtitular varchar(250), cDesTipDes VARCHAR (100),
							cDesInsFin VARCHAR(100),ccodcorade char(15)	,nCanEntFin INT, nCanEntCan	INT	, lestNivSco bit ,
							nJerNivApr int, lIndLeasin BIT
						)  
  
BEGIN TRANSACTION

-------------------------------------
-- INICIO - REGISTRA LA SOLICITUD
-------------------------------------
EXECUTE KPY_AgregaSolicitud_sp 
		@x_cursol = @x_xmlcursol,
		@x_cCodOficin = @x_cCodoficin,
		@x_cCodSolCre = @lcCodSolCre OUTPUT, 
		@x_currefina = @x_currefina,
		@x_curcanifi = '',
		@x_ccodusu = @x_cCodUsuGen
	IF @@ERROR <>0    
	BEGIN    
		RETURN    
	END  
-------------------------------------
-- FIN - REGISTRA LA SOLICITUD
-------------------------------------

---------------------------------------------------
-- INICIO - VALIDACION DE PARAMETROS DE AMPLIACION
---------------------------------------------------
DECLARE @lcCodMotSol CHAR(1)

SELECT @lcCodMotSol = cCodMotSol  
FROM KPYMSolicitud
WHERE cCodSolCre = @lcCodSolCre

IF @lcCodMotSol = '3'
BEGIN
	EXECUTE KPY_ValOpeCreAut_sp 
		@x_cCodSolCre = @lcCodSolCre,
		@x_cResVal = @x_cResVal OUTPUT 
		
	IF @@ERROR <> 0    
		BEGIN    
			ROLLBACK TRANSACTION
			RETURN    
		END	
	
	IF ISNULL(@x_cResVal,'') != 'OK'
		BEGIN
			SELECT * FROM ##CurMsjIni
			DROP TABLE ##CurMsjIni
			ROLLBACK TRANSACTION
			RETURN    
		END 
	DROP TABLE ##CurMsjIni		
END

SET @x_cResVal = ''

---------------------------------------------------
-- FIN - VALIDACION DE PARAMETROS DE AMPLIACION
---------------------------------------------------
------------------------------------------------
-- INICIO - VALIDACION DE PARAMETROS GENERALES
------------------------------------------------
EXECUTE KPY_ValParCreAut_sp
		@x_cCodSolCre = @lcCodSolCre, 
		@x_xmlDatCre  = @x_xmlcursol ,
		@x_cResVal    = @x_cResVal OUTPUT 
	IF @@ERROR <> 0    
	BEGIN    
		ROLLBACK TRANSACTION
		RETURN    
	END	

IF ISNULL(@x_cResVal,'') != 'OK'
BEGIN
	ROLLBACK TRANSACTION
	RETURN    
END 
-------------------------------------
-- FIN - VALIDACION DE PARAMETROS
-------------------------------------			

-------------------------------------------------------------
-- INICIO - VINCULACION DE LA EVALUACION CON LA SOLICITUD
-------------------------------------------------------------
EXECUTE KPY_VinEvaSolAut_sp
		@x_cCodCliente = @x_cCodCliente ,
		@x_cCodsolCre = @lcCodSolCre,
		@x_cCodUsuGen = @x_cCodUsuGen,
		@x_cCodoficin = @x_cCodoficin,
		@x_xmlGarCre  = @x_xmlGarCre
		
	IF @@ERROR <>0    
	BEGIN 
		ROLLBACK TRANSACTION   
		RETURN    
	END  	
-------------------------------------------------------------
-- FIN - VINCULACION DE LA EVALUACION CON LA SOLICITUD
-------------------------------------------------------------
  	
------------------------------------------
-- INICIO - PRE APROBACION DE SOLICITUD
------------------------------------------	
INSERT #CURSOLICI (	ccodsolcre ,ccodtipsol ,ccodclient ,ccodmoneda ,nmonsolcre,ccodusuana ,nnumcuosol , nplasolcre ,dfecsolcre ,   
					ccodususol ,cmonedaapr ,nmonsugana , cdescrisol ,nmonaprcre,nnumcuoapr ,nplaaprcre ,dfecaprcre ,cobsanacre ,    
					ccodexpcli ,ccodestsol ,ccodoficin ,ccodactana ,ccodtipact ,ccodcomite ,ccodplazo ,dfecmodcre ,ccodusuing ,
					lhistoria ,ccrenuevo ,ccrenorref ,ccodmotsol ,ccodtipcre ,ccodproduc ,ccodsubpro ,ccodrecurs , ccodtiprec ,
					ntasintcom ,ccodsitsol ,nnumdiagra ,nnumdiagraapr ,dfecdesref ,dfecvenref ,lcuotacons ,clibamocre ,ctipperiodo ,
					ccodtipcuo ,ccodmodcre ,ndiafecfij ,nnumdesemb ,ctipdocide ,cnrodocide ,cclasolcre ,dinilinsol ,dfinlinsol ,
					dinilinapr ,dfinlinapr ,ccodlincre ,ltienelin ,ccodconven ,lconconven ,nnrolinfin ,ctiptascom ,ccodintcon ,    		
					ctiptasmor ,ntasintmor ,nnrotascom ,nnrotasmor,cCodigoProd ,cCodigoSubPro ,cCodLinea ,nMonCuoIni ,nValTerreno , 
					nValConstru , nValVivienda , lFlgMiVivi ,nMonSolAux  , nMonAprAux, cNroInfPro  , cCodOrdPag ,cindgenop , ccodparcam ,
					ccodciiusol , criecrecam , nMonAhoAcu ,cDesMotivo ,cCodTipOpi ,cCodInfRie ,cCodAnaRie ,ccodPromotor ,ccodmoddes , 
					ccodctaaho,ccodinsfin , cnomtitular , cDesTipDes ,cDesInsFin ,ccodcorade ,nCanEntFin , nCanEntCan,lestNivSco,
					nJerNivApr,lIndLeasin
				  )
EXECUTE KPY_ConSolCre_sp  
		@x_cCodSolCre = @lcCodSolCre, 
		@x_cClaSolCre = '[CV]'
	IF @@ERROR <>0    
	BEGIN 
		ROLLBACK TRANSACTION      
		RETURN    
	END 

DECLARE @x_cCodCtaAho CHAR(18), @x_cNomTitCta VARCHAR(150)

IF @x_cCodTipSol IN ('07') -- Actualizando Modalidad de desembolso de adelanta sueldo con abono en cuenta
BEGIN
	EXECUTE KPY_RetCtaAhoCli_sp
			@x_cCodClient = @x_cCodCliente,
			@x_cCodCtaAho = @x_cCodCtaAho OUTPUT,
			@x_cNomTitCta = @x_cNomTitCta OUTPUT
			
	UPDATE #CURSOLICI
	SET cCodModDes = 'B',
		ccodctaaho = ISNULL(@x_cCodCtaAho,''),
		cnomtitular = ISNULL(@x_cNomTitCta,''),
		ccodinsfin = '107' -- Caja Huancayo
		
	IF @@ERROR <>0    
	BEGIN 
		ROLLBACK TRANSACTION      
		RETURN    
	END 
		
END

IF @x_cCodTipSol IN ('01','02','03') -- CREDITOS AUTOMATICOS MES Y CONSUMO
BEGIN
	INSERT @lCurDesCre (cDescriDes, nmonPorAfe ,
						cCodDesCre, cDesTipDes ,
						lConEstado, nMonTipDes ,
						cCodTipDes, cIdeTipDes)
	EXECUTE KPY_DevDesCreCli_sp
			@x_cCodCliente = @x_cCodCliente,
			@x_nMonSolCre  = @x_nMonSolCre,
			@x_cCodCIIUSol = @lcCodCIIUSol OUTPUT
		IF @@ERROR <>0    
		BEGIN 
			ROLLBACK TRANSACTION      
			RETURN    
		END
END		
ELSE
BEGIN
	SET @lcCodCIIUSol = 'CCCC'
	
	INSERT @lCurDesCre (cDescriDes ,nmonPorAfe ,
						cCodDesCre ,cDesTipDes ,
						lConEstado ,nMonTipDes ,
						cCodTipDes ,cIdeTipDes)
						
	VALUES ('CONSUMO',@x_nMonSolCre,'5','CONSUMO',1,@x_nMonSolCre,'23',	CASE 
													WHEN @x_cCodTipSol = '07' THEN '030313' 
													WHEN @x_cCodTipSol = '08' THEN '030316' 
													ELSE '030306'
												END)
																		
	IF @@ERROR <>0    
	BEGIN 
		ROLLBACK TRANSACTION      
		RETURN    
	END													
END
	
SELECT cDescriDes ,nmonPorAfe ,cCodDesCre 
INTO #curDesCre  
FROM @lCurDesCre 
GROUP BY cDescriDes ,nmonPorAfe ,cCodDesCre 

SELECT 	cDesTipDes ,lConEstado ,nMonTipDes ,
		cCodTipDes ,cCodDesCre ,cIdeTipDes 
INTO #curTipDes		
FROM @lCurDesCre 

SELECT	@lccodmoneda = ccodmoneda,
		@lnmonsolcre = nmonsolcre,
		@lccodconven = ccodconven ,
		@lcCodOficin = ccodoficin ,
		@lcCodUsuAna = ccodusuana ,
		@lnplaaprcre = nplaaprcre,
		@lntasintcom = ntasintcom
FROM #CURSOLICI

SELECT @lnMonDesOPSol = cValVarApl  
FROM ADMMVariable 
WHERE	cCodigoApl = 'KPY'
		AND cNomVarApl = 'gnMonDesOPSol'
		AND cCodOficin = @lcCodOficin

SELECT @lnMonDesOPDol = cValVarApl  
FROM ADMMVariable 
WHERE	cCodigoApl = 'KPY'
		AND cNomVarApl = 'gnMonDesOPDol'
		AND cCodOficin = @lcCodOficin


SELECT @lntipCamFij = cValVarApl  
FROM ADMMVariable 
WHERE	cCodigoApl = 'ADM'
		AND cNomVarApl = 'gntipCamFij'
		AND cCodOficin = @lcCodOficin	
	
SELECT @lcCodIns = cValVarApl  
FROM ADMMVariable 
WHERE	cCodigoApl = 'ADM'
		AND cNomVarApl = 'gcCodIns'
		AND cCodOficin = @lcCodOficin

SELECT @ldFecSis = cValVarApl  
FROM ADMMVariable 
WHERE	cCodigoApl = 'KPY'		   
		AND cNomVarApl = 'GDFECSIS'
		AND cCodOficin = @lcCodOficin			

EXECUTE KPY_RetIndCon_sp 
		@x_cCodConven = @lccodconven,
		@x_lEsConvenio = @lEsConvenio OUTPUT
	IF @@ERROR <>0    
	BEGIN 
		ROLLBACK TRANSACTION      
		RETURN    
	END			
	
IF @lccodmoneda = '1' 	
	SET @lcIndGenOP =	CASE 
							WHEN @lnmonsolcre >=  @lnMonDesOPSol THEN '2' 
							ELSE '1' 
						END
ELSE  				
	SET @lcIndGenOP =	CASE 
							WHEN @lnmonsolcre >=  @lnMonDesOPDol THEN '2' 
							ELSE '1' 
						END

IF @lccodconven <> 'XXXXXX' AND @lEsConvenio = 1
	SET @lcIndGenOP = '1'


UPDATE #CURSOLICI 
SET cTipPeriodo = '1',nNumDesemb = 1,
	dFecAprCre = @ldFecSis,dFecDesRef = @ldFecSis, 
	cIndGenOP = @lcIndGenOP, cCodSitSol = 'P',
	cCodCIIUSol = @lcCodCIIUSol ,cCodUsuIng = @x_cCodUsuGen

SET @lcMsgRetTrx = 'OK'

EXECUTE KPY_ManSolCre_sp 	
		@x_cursol	= NULL, 
		@x_curamp	= '', 
		@x_DesCre	= NULL, 
		@x_TipDes	= NULL, 
		@x_MotDen	= '', 
		@x_cCodSol	= @lcCodSolCre, 
		@x_ccodSit	= 'P', 
		@x_cEstSol	= 'A', 
		@x_PrePag	= 'N',
		@x_ActSco	= @lcTipAct OUTPUT,
		@x_MonAcu	= @lnMonAcu OUTPUT,
		@x_MsgValPar	= @lcmsg OUTPUT, 
		@x_cCodOficin	= @lcCodOficin,
		@x_cDesMotivo	= @x_cDesMotivo,
		@x_nTasIntMin	= @x_nTasIntMin,
		@x_ccodOfiCta	= '' ,
		@x_xDetGasTos	= @x_xDetGasTos,
		@x_cNivRie		= @lcNivRieCli OUTPUT ,
		@x_cDesRazEva	= @lcDesRazEva OUTPUT,
		@x_cModSco		= @lcModSco OUTPUT,
		@x_cCodUsuSco	= 'UCIE01',
		@x_xCliAfiSeg   = NULL,
		@x_cMsgRetTrx   = @lcMsgRetTrx OUTPUT,
		@x_xGarCarFia	= NULL,
		@x_xcurProEco   = NULL,
        @x_xcurSubDesCre= NULL
		
	IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION      
		RETURN    
	END
	IF @lcMsgRetTrx != 'OK'
	BEGIN
		ROLLBACK TRANSACTION
		SET @x_cResVal = 'NOEXIVAL'
		INSERT INTO @CurMsjVal VALUES (@lcMsgRetTrx)
		SELECT cMenVal FROM @CurMsjVal
		RETURN 
	END

	IF @x_cCodTipSol = '05'
	BEGIN 
		INSERT INTO KPYDTipGarCarFia (cCodSolCre,cCodTipGarFia,nPorPlaFij,nPorGarHip,cCodUsuReg,dFecUsuReg)
		VALUES (@lcCodSolCre,'1',0.00,0.00,@x_cCodUsuGen,GETDATE())
		IF @@ERROR <>0    
		BEGIN 
			ROLLBACK TRANSACTION      
			RETURN    
		END
	END 
------------------------------------------
-- FIN - PRE APROBACION DE SOLICITUD
------------------------------------------	
------------------------------------------
-- VALIDA SI LA SOLICITUD TIENE NIVEL DE 
-- APROBACIÓN DEL SCORING
------------------------------------------	
SET @x_lestNivSco = 1

------------------------------------------
-- INICIO - APROBACION DE SOLICITUD
------------------------------------------	
EXECUTE KPY_RetCarPer_sp 
		@x_dFecProApr = @ldFecSis,
		@x_cCodCarPer = @lcCarPer OUTPUT ,
		@x_cCodPerSon = @x_cCodUsuGen,
		@x_cCodOficin = @lcCodOficin
	IF @@ERROR <>0    
	BEGIN  
		ROLLBACK TRANSACTION  
		RETURN    
	END	
	
SET @lcTipAct = ISNULL(@lcTipAct,'') 	
	
EXECUTE KPY_ActEvaIntCom_sp 
		@x_cAprDenCom = '',
		@x_ccodsolcre = @lcCodSolCre ,
		@x_cCodIntcom = @x_cCodUsuGen, 
		@x_cEstSolCre = 'B', 
		@x_cSitSolCre = 'B',
		@x_lOpiFav = 1, 
		@x_lOpiDes = 0, 
		@x_cObsCom = '', 
		@x_ctipAct = @lcTipAct, 
		@x_cCodOrdVot = 1 ,
		@x_dfecsis = @ldFecSis, 
		@x_cCodUsu = @x_cCodUsuGen, 
	    @x_cObsApr = '', 
	    @x_cCarPer = @lcCarPer, 
	    @x_cConPer = ''
	IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION      
		RETURN    
	END	
------------------------------------------
-- FIN - APROBACION DE SOLICITUD
------------------------------------------
---------------------------------
-- INICIO - GENRACION DE LINEA
---------------------------------
	
DECLARE @lCurLin TABLE 	(cCodLinCre CHAR(10))

INSERT @lCurLin	 (cCodLinCre)
EXECUTE KPY_GenLinCre_sp 
		@x_cCodOficin = @lcCodOficin,   
		@x_cCodClient = @x_cCodCliente ,
		@x_cMonedaLin = @lccodmoneda ,
		@x_nMonLinCre = @lnmonsolcre ,
		@x_nTipCambio = @lntipCamFij ,
		@x_dFecIniLin = @ldFecSis,    
		@x_dFecFinLin = @ldFecSis ,
		@x_nMonConsum = @lnmonsolcre ,
		@x_cCodEstLin = 'A' ,
		@x_cCodSolCre = @lcCodSolCre,
		@x_cCodUsuAna = @lcCodUsuAna ,
		@x_cClaSolCre = 'C' ,
		@x_cCodUsuPro = @x_cCodUsuGen ,
		@x_dFecSistema= @ldFecSis,
		@x_cCodCIIU   = @lcCodCIIUSol ,
		@x_cCodLinCre = @lcCodLinCre OUTPUT , 
		@x_xCurIntApr = '' 
	IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION			
		RETURN    
	END	 
	
	SET @x_cCodLinAut = @lcCodLinCre
---------------------------------
-- FIN - GENRACION DE LINEA
---------------------------------
-----------------------------------------------
-- INICIO - VINCULACION DE GARANTIAS POR LINEA
-----------------------------------------------
--- ELIMINAMOS CONYUGE 
UPDATE KPYTCreMulCli
SET cCodEstRel = 'X'
WHERE cCodLinCre = @lcCodLinCre
	AND cCodRelCta = 'O'

--- CURSOR PARA SECUENCIAL DE LINEA CLIENTE
DECLARE @curSecLinCli TABLE (cCodClient CHAR(12), nSecLinCli INT)

INSERT INTO @curSecLinCli
SELECT A.cCodClient, nSecLinCli = MAX(ISNULL(A.nSecLinCli,0))
FROM KPYTCreMulCli A WITH(NOLOCK)
	INNER JOIN @CurIntCreAut B
		ON A.cCodClient = B.cCodCliente
GROUP BY A.cCodClient

--- CURSOR PARA GARANTIAS						
CREATE TABLE #curtemp (	ccodgarcli char (3), ccodcliente char (14), ccodlincre char (10), 
						nmongragar numeric (14,2), ccodrelcta char(2), operacion char(1), 
						nmonorigar numeric(14,2), nmontasgar numeric(14,2),	nmontasgardol numeric(14,2), ccodtipgar char(5),
						ntipcamgar numeric(14,4), ccodtipmon char(1),nporcobgar numeric (14,2), nporgragar numeric (10,4)
						)	

INSERT KPYTCreMulCli (	cCodLinCre,cCodClient,nSecLinCli,cCodRelCta,
						cCodUsuPro,dFecModRel,cCodEstRel,cCodEstCre
					 )
SELECT	cCodLinCre = @lcCodLinCre,cCodClient = A.cCodCliente,
		nSecLinCli = ROW_NUMBER() OVER(PARTITION BY A.cCodCliente ORDER BY A.cCodCliente DESC) + ISNULL(B.nSecLinCli,0),
		A.cCodRelCta, cCodUsuPro = @x_cCodUsuGen,
		dFecModRel = @ldFecSis, cCodEstRel = 'A', cCodEstCre = 'F'
FROM @CurIntCreAut A
	LEFT JOIN @curSecLinCli B
		ON A.cCodCliente = B.cCodClient
WHERE A.lIndAct = 1
	AND A.cCodRelCta != 'T'
IF @@ERROR <>0    
BEGIN    
	ROLLBACK TRANSACTION      
	RETURN    
END	 

IF @x_cCodTipSol IN ('01','02','03','07') -- CREDITOS AUTOMATICOS MES, CONSUMO Y ADELANTO DE SUELDO
BEGIN
	EXECUTE KPY_LisGarCreAut_sp 
			@x_cCodLinCre = @lcCodLinCre , 
			@x_dFecSis	  = @ldFecSis, 
			@x_cIndInsGar = @x_cIndInsGar,
			@x_XMLCurGarLin = @lXMLCurGarLin OUTPUT
		IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION      
			RETURN    
		END	       
		
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @lXMLCurGarLin
		INSERT #curtemp (	ccodgarcli,		ccodcliente,	ccodlincre,		nmongragar, 
							ccodrelcta,		operacion,		nmonorigar,		nmontasgar, 



							nmontasgardol,	ccodtipgar,		ntipcamgar,		ccodtipmon,
							nporcobgar,		nporgragar
						)
		SELECT	ccodgarcli, ccodcliente,	ccodlincre = @lccodlincre, 
				nmongragar = nmongragar , ccodrelcta,	operacion, 
				nmonorigar, nmontasgar, nmontasgardol,	ccodtipgar ,
				ntipcamgar, ccodtipmon ,	nporcobgar , nporgragar
		FROM OPENXML(@iDoc, 'datos/row', 1)
		WITH (	ccodgarcli char (3), ccodcliente char (14), ccodlincre char (10), 
				nmongragar numeric (14,2), ccodrelcta char(2), operacion char(1), 
				nmonorigar numeric(14,2), nmontasgar numeric(14,2), nmontasgardol numeric(14,2), ccodtipgar char(5),
				ntipcamgar numeric(14,4), ccodtipmon char(1),nporcobgar numeric (14,2), nporgragar numeric(10,4)
			)
	EXEC sp_xml_removedocument @idoc
END
ELSE 
BEGIN
	Exec sp_xml_preparedocument @idoc output, @x_xmlGarCre
		INSERT #curtemp (	ccodgarcli , ccodcliente ,	ccodlincre , 
							nmongragar , ccodrelcta ,	operacion , 
							nmonorigar , nmontasgar ,	nmontasgardol , ccodtipgar ,
							ntipcamgar , ccodtipmon ,	nporcobgar , nporgragar
						)
		SELECT	ccodgarcli, ccodcliente,	ccodlincre = @lccodlincre   , 
				nmongragar = nmongragar,	ccodrelcta,		operacion , 
				nmonorigar, nmontasgar ,	nmontasgardol,	ccodtipgar ,
				ntipcamgar, ccodtipmon ,	nporcobgar , nporgragar	
		From openxml(@idoc,'/VFPData/curgarlinxml',1) 
		With (	ccodgarcli char (3),		ccodcliente char (14),		ccodlincre char (10), 
				nmongragar numeric (14,2),	ccodrelcta char(2),			operacion char(1), 
				nmonorigar numeric(14,2),	nmontasgar numeric(14,2),	nmontasgardol numeric(14,2),	ccodtipgar char(5),
				ntipcamgar numeric(14,4),	ccodtipmon char(1),			nporcobgar numeric (14,2) , nporgragar numeric (10,4)
				)

	EXEC sp_xml_removedocument @idoc

END

EXECUTE KPY_InsGarLin_SP
		@x_CurXml = NULL, 
		@x_dFecSis = @ldFecSis, 
		@x_CCodUsu = @x_cCodUsuGen 
	IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION      
		RETURN    
	END	
-----------------------------------------------
-- FIN - VINCULACION DE GARANTIAS POR LINEA
-----------------------------------------------   
---------------------------------------
-- INICIO - GENERACION DE CREDITOS
---------------------------------------
IF @x_cCodTipSol != '05' --- <> CARTA FIANZA
BEGIN

	SELECT @lcCodDesCre = cCodDesCre 
	FROM #curDesCre

	CREATE TABLE #curCredit	(	cCodCtaCre CHAR(18), ccodsolcre char(10), clibamocre char(1),ccrenorref char(1), nmonaprcre numeric(14,4), 
								nnumcuoapr smallint ,nnumdiaapr smallint , nnumdiagra smallint , ntasintcom numeric(14,4) ,  lcuotacons BIT, 	
								nmoncapdes numeric(14,4),nmoncappag numeric(14,4),nmonintpro numeric(14,4),  nmonintpag  numeric(14,4) ,nmongaspro numeric(14,4), nmongaspag numeric(14,4) , 	
								nmonmorpro numeric(14,4) , nmonmorpag numeric(14,4), ndiaatrcre smallint , ndiaatrant smallint ,ndiaatracu smallint , ndiaatrmax smallint , 
								cmaringjud char(1),  ntipcamdes numeric(8,4),ccodusupro char(6), csolgarcre char(1),ccodinscre char(3) ,ccrerapido char(10),
								ndiafecfij smallint , ccodusures char(6) ,nindevafec numeric(14,4),nindevaant numeric(14,4),nsalcapdia numeric(14,4),nindevadia numeric(14,4) ,	 		
								nsalcapant numeric(14,4) ,nindevafea numeric(14,4),lconconven BIT, cCodDesCre CHAR(2),ccodtipcuo char(1), cestcrecon char(1),
								ccodplazo char(2) , ccodtipcre char(2) , ccodproduc  char(2),ccodsubpro char(2),ccodrecurs char(2),
								ccodtiprec char(2) ,ccodmodcre char(2), ccodconven char(6), ccodrefina char(1),ccodreestr char(1) , ccodjudici char(1) ,	
								ccodcastig char (1), ccodnotsis char(2), ccodnotana char(2) ,ccodusuana char(6), ccodtipmon char(1),cCodFueIng CHAR(3),
								ctipperiodo char(1),cUltNumDoc CHAR(6),ccodintcon char(5),nnumdesemb smallint,nnrolinfin int,ctiptascom char(2),
								ctiptasmor char(2),ntasintmor numeric(14,2),nnrotascom int,nnrotasmor int,cconrefagr char(1),nmonintfec numeric(14,2),
								lreddefcre BIT, dfecdesref datetime,dfecgencre datetime,  dfecdescre datetime,dfecmodcre datetime,dfecultpag datetime,
								dfecculcre datetime,dfecrescre datetime , dfecprosld datetime , cCodigoProd CHAR(6),cCodigoSubPro CHAR(6),
								nmoncuoini numeric(14,2), nMonTasGar NUMERIC(14,2),cdescofide char(3),ccodciiusol char(4), criecrecam char(1)
							)
								
	INSERT INTO #curCredit (cCodCtaCre,cCodSolCre,cLibAmoCre,cCreNorRef,nMonAprCre,
							nNumCuoApr,nNumDiaApr,nNumDiaGra,nTasIntCom,lCuotaCons,
							nMonCapDes,nMonCapPag,nMonIntPro,nMonIntPag,nMonGasPro,
							nMonGasPag,nMonMorPro,nMonMorPag,nDiaAtrCre,nDiaAtrAnt,
							nDiaAtrAcu,nDiaAtrMax,cMarIngJud,nTipCamDes,cCodUsuPro,
							cSolGarCre,cCodInsCre,cCreRapido,nDiaFecFij,cCodUsuRes,
							nInDevAFec,nInDevAAnt,nSalCapDia,nInDevADia,nSalCapAnt,
							nInDevAFeA,lConConven,cCodDesCre,cCodTipCuo,cEstCreCon,
							cCodPlazo, cCodTipCre,cCodProduc,cCodSubPro,cCodRecurs,
							cCodTipRec,cCodModCre,cCodConven,cCodRefina,cCodReestr,
							cCodJudici,cCodCastig,cCodNotAna,cCodUsuAna,cCodTipMon,
							cCodFueIng,cTipPeriodo,cUltNumDoc,cCodIntCon,nNumDesemb,
							nNroLinFin,cTipTasCom,cTipTasMor,nTasIntMor,nNroTasCom,
							nNroTasMor, cConRefAgr,nMonIntFec,lRedDefCre,dFecDesRef,
							dFecGenCre,dFecModCre,cCodigoProd,cCodigoSubPro,nMonCuoIni, 
							nMonTasGar,ccodciiusol,criecrecam)
	SELECT 	'' AS cCodCtaCre,cCodSolCre, 'N' AS cLibAmoCre, 'N' AS cCreNorRef ,nMonAprCre,
			nNumCuoApr,nPlaAprCre AS nNumDiaApr,nNumDiaGra,nTasIntCom, 1 AS lCuotaCons,
			0.0 AS nMonCapDes,0.00 AS nMonCapPag, 0.00 AS nMonIntPro, 0.00 AS nMonIntPag, 0.00 AS nMonGasPro,
			0.00 AS nMonGasPag,0.00 AS nMonMorPro,0.00 AS nMonMorPag, 0 AS nDiaAtrCre, 0 AS nDiaAtrAnt,
			0 AS nDiaAtrAcu, 0 AS nDiaAtrMax, 'N' AS cMarIngJud,@lntipCamFij AS nTipCamDes, @x_cCodUsuGen AS cCodUsuPro,
			'N' AS cSolGarCre,@lcCodIns AS cCodInsCre,'1' AS cCreRapido, 0 AS nDiaFecFij, '' AS cCodUsuRes,
			0 AS nInDevAFec, 0 AS nInDevAAnt,0 AS nSalCapDia,0 AS nInDevADia, 0 AS nSalCapAnt,
			0 AS nInDevAFeA, 0 AS lConConven, @lcCodDesCre  AS cCodDesCre,cCodTipCuo,'E' AS cEstCreCon,
			cCodPlazo,cCodTipCre,cCodProduc,cCodSubPro,cCodRecurs,
			cCodTipRec,cCodModCre,cCodConven,'N' AS cCodRefina,'N' AS cCodReestr,
			'N' AS cCodJudici, 'N' AS cCodCastig,  'N' AS cCodNotAna,cCodUsuAna,
			cMonedaApr AS cCodTipMon,@x_cCodFueIng AS cCodFueIng,cTipPeriodo, '' AS cUltNumDoc, '000' AS cCodIntCon,
			nNumDesemb,nNroLinFin,cTipTasCom,cTipTasMor,nTasIntMor,
			nNroTasCom,nNroTasMor, '' AS cConRefAgr, 0.00 AS nMonIntFec,  0 AS lRedDefCre,
			dFecDesRef,@ldFecSis AS dFecGenCre,@ldFecSis AS dFecModCre,
			cCodigoProd,cCodigoSubPro,0.00 AS nMonCuoIni, 0.00 AS nMonTasGar ,ccodciiusol = @lcCodCIIUSol,criecrecam				
	FROM #CURSOLICI	
	IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION      
		RETURN    
	END	 
		
	UPDATE #curCredit 
	SET cCodNotSis = NULL, dFecDesCre = NULL ,
		dFecUltPag = NULL, dFecCulCre = NULL,
		dFecResCre = NULL,dFecProSld = NULL
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION      
			RETURN    
		END	
		
	EXECUTE KPY_GenCreCon_sp 
			@x_credcon 	= NULL, 
			@x_cCodLinCre	= @lcCodLinCre , 	
			@x_cCodCliente	= @x_cCodCliente , 
			@x_cCodInsFin	= @lcCodIns, 	
			@x_cCodOficin	= @lcCodOficin, 	
			@x_cMonedaDes	= @lccodmoneda,	
			@x_cCodUsuPro	= @x_cCodUsuGen,	
			@x_cCodSolCre	= @lcCodSolCre ,	
			@x_dFecSistema	= @ldFecSis,		
			@x_lLinCreAut	= 1,	
			@x_lFlgMiVivi	= 0,	
			@x_cCodCtaCre	= @x_cCodCtaCre OUTPUT 
		IF @@ERROR <>0    
		BEGIN
			ROLLBACK TRANSACTION          
			RETURN    
		END	 
END 
ELSE 
BEGIN 
	Exec sp_xml_preparedocument @idoc output, @x_xDatCarFia
		INSERT @lCurDatCarFia (cCodCliFav ,cCodTipGar , cCodModCar,cCodOblFia,cCodGrtFia,cObsCarFia ,cRefCarFia )
		SELECT	cCodCliFav ,cCodTipGar , cCodModCar,cCodOblFia,cCodGrtFia ,cObsCarFia ,cRefCarFia 		
		From openxml(@idoc,'/VFPData/curdatcarfia',1) 
		With (	ccodclifav char(12),ccodtipgar char(1), ccodmodcar char(2),ccodoblfia varchar(2),ccodgrtfia varchar(2),
				cobscarfia varchar(100),crefcarfia varchar(MAX)
			)
	EXEC sp_xml_removedocument @idoc

	SELECT	@lcCodCliFav = cCodCliFav ,
			@lcCodTipGar = cCodTipGar , 
			@lcCodModCar = cCodModCar ,
			@lcCodOblFia = ccodoblfia,
			@lcCodGrtFia = ccodgrtfia,
			@lcObsCarFia = cObsCarFia ,
			@lcRefCarFia = cRefCarFia,
			@ldFecCanFia = DATEADD ("DAY",@lnplaaprcre,@ldFecSis)	
	FROM @lCurDatCarFia

	DECLARE @HorSis TIME(0) = GETDATE(), 
			@lConLocRem BIT = 1, 
			@lcCodKardex CHAR(15)

	EXEC KPY_GenCarFia_sp 
			@x_cCodCliente2 = @x_cCodCliente,
			@x_cCodCliente	= @lcCodCliFav, 
			@x_dFecsis		= @ldFecSis, 
			@x_cCodLinCre	= @lcCodLinCre, 
			@x_cCodIns 		= @lcCodIns, 
			@x_cCodOfi 		= @x_cCodoficin, 
			@x_dFecIniFia 	= @ldFecSis, 
			@x_dFecCanFia 	= @ldFecCanFia, 
			@x_mObsCarFia 	= @lcObsCarFia, 
			@x_mRefCarFia 	= @lcRefCarFia,
			@x_cCodUsu 		= @x_cCodUsuGen, 
			@x_cCodTipFia 	= @lcCodTipGar, 
			@x_cCodSolCre 	= @lcCodSolCre, 
			@x_cCodModFia 	= @lcCodModCar,
			@x_cCodOblFia	= @lcCodOblFia,
			@x_cCodGrtFia	= @lcCodGrtFia,
			@x_nPlaOtoFia 	= @lnplaaprcre, 
			@x_nTasComFia 	= @lntasintcom, 
			@x_cCodMotFia 	= 'N', 
			@x_nValCarFia 	= @lnmonsolcre, 
			@x_dFecSolFia 	= @ldFecSis, 
			@x_HoraTermin 	= @HorSis, 
			@x_cCodUsuSis 	= @x_cCodUsuSis, 
			@x_cCodUsuSOP 	= @x_cCodUsuSOP, 
			@x_cVenOperac 	= @x_cVenOperac, 
			@x_cSerTermin 	= @x_cSerTermin, 
			@x_lConLocRem 	= @lConLocRem, 
			@x_cCodTipMon 	= @lccodmoneda, 
			@x_cTipInsOri 	= @lcCodIns, 
			@x_nMonGravar	= @lnmonsolcre, 
			@x_cGruGastos 	= 'GA07', 
			@x_cCodTipGas	= '11', 
			@x_cCodCtaCre 	= @x_cCodCtaCre OUTPUT, 
			@x_cnroCarFia 	= @x_cNroCarFia OUTPUT, 
			@x_cCodKArdex	= @lcCodKardex OUTPUT
		IF @@ERROR <>0    
		BEGIN
			ROLLBACK TRANSACTION          
			RETURN    
		END	 			
END

---------------------------------------
-- FIN - GENERACION DE CREDITOS
---------------------------------------
IF @x_cCodTipSol IN ('01','02','03')-- CREDITOS AUTOMATICOS MES Y CONSUMO
BEGIN
	UPDATE KPYMCARCREAUT
	SET cEstCarSco = 'O',
		cCodCtaCreOto = @x_cCodCtaCre
	WHERE  cCodCliente = @x_cCodCliente
		AND lEstRegCar = 1
	IF @@ERROR <>0	
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
END

IF @x_cCodTipSol IN ('06')	-- CREDIJOYAS
BEGIN
	UPDATE KPYMLotPrenda
	SET	cCodLinCre	=	B.ccodlincre,	--	@lccodlincre,
		cCodCtaCre	=	@x_cCodCtaCre,
		cCodEstPre	=	'G'	--EN GARANTIA
	FROM KPYMLotPrenda A
	INNER JOIN #curtemp B
		ON		B.ccodgarcli	=	A.cCodGarCli
			AND	B.ccodcliente	=	A.cCodClient
	IF @@ERROR <> 0	
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

	UPDATE KPYDLotPrenda
	SET	cCodEstPre	=	'G'	--EN GARANTIA
	FROM KPYDLotPrenda A
	INNER JOIN KPYMLotPrenda M
		ON		M.cCodLotPre	=	A.cCodLotPre
			AND	M.ccodclient	=	A.cCodClient
	INNER JOIN #curtemp B
		ON		B.ccodgarcli	=	M.cCodGarCli
			AND	B.ccodcliente	=	M.cCodClient
	IF @@ERROR <> 0	
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
END

SET @x_cCodSolRet = @lcCodSolCre
		
COMMIT TRANSACTION
--=======================================================================================================================
GO
	GRANT EXEC ON [dbo].[KPY_GenCreAut_sp] TO ADM_ADM_rl	
GO

IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_IngProApr_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_IngProApr_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2005 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo: Graba datos de la propuesta de aprobacion para una solicitud dentro del formato de evaluacion RAPIDA
*  
*	Escrito por: 			Gregorio Lopez Pinto
*	Email/Movil/Phone:		glopez@cmac-huancayo.com.pe
*  
*	Fecha creación: 01/09/2005
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*	FECHA		USUARIO		DESCRIPCIÓN
*	2015.10.15	HVARGA		Se agrega 1 parámetro adicional al invocar al SP KPY_ModDesCre_sp
*	Sintaxis de ejemplo:
*		EXEC KPY_IngProApr_sp 'ARCHIVO XML', 'ARCHIVO XML', 'ARCHIVO XML', 'ARCHIVO XML', '0010012254', 'GLOPEZ', '31-08-2005'
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_IngProApr_sp]
	@x_xmldescrecon TEXT,
	@x_xmldetproapr TEXT,
	@x_xmlgarguarda TEXT,
	@x_xmlgirneg TEXT,
	@x_cCodSolCre CHAR(10),
	@x_cCodUsu CHAR(6),
	@x_dFecSis DATETIME
AS
SET NOCOUNT ON
DECLARE @pnIdeDetPro INT
DECLARE @pnIdeDesCre INT
DECLARE @pnIdeGirNeg INT
DECLARE @pnIdeGarant INT

BEGIN TRAN
	
	/* DETALLE DE CREDITOS */
	EXEC sp_xml_preparedocument @pnIdeDetPro OUTPUT, @x_xmldetproapr
		SELECT ccodsolcre, cnrodoctri, nnumhijos, ccodrepev, dfectasgar,
				ccodusuana, ccodcomite, ccodubicacion, nmonpropue, nmontasa,
				nnumcuota, nmoncuota, ccodciiu, tobservac
			INTO #curdetproapr
		 FROM OPENXML(@pnIdeDetPro,'/VFPData/curdetproapr',1)
					WITH 	(ccodsolcre char(10), cnrodoctri char(12), nnumhijos int, ccodrepev char(6), dfectasgar datetime, 
							ccodusuana char(6), ccodcomite char(3), ccodubicacion char(3), nmonpropue numeric(14,2), nmontasa numeric(14,4), 
							nnumcuota int, nmoncuota numeric(14,2), ccodciiu char(4), tobservac varchar(8000))
	EXEC sp_xml_removedocument @pnIdeDetPro	

	/* ELIMINAMOS EL REGISTRO ANTERIOR SI EXISTE */
	DELETE KPYDDetProApr WHERE ccodSolCre = @x_cCodSolCre
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			RETURN
		END

	/* INSERTAMOS EL REGISTRO MODIFICADO */
	INSERT INTO KPYDDetProApr
		(	cCodSolCre, cNroDocTri, nnumhijos, cCodRepev, dFecTasGar, cCodUsuAna,
			cCodCOmite, cCodUbicacion, nMonPropue, nMonTasa, nNumCuota, nMonCuota,
			cCodCIIU, tObservac)
	SELECT cCodSolCre, cNroDocTri, nnumhijos, cCodRepev, dFecTasGar, cCodUsuAna,
			cCodCOmite, cCodUbicacion, nMonPropue, nMonTasa, nNumCuota, nMonCuota,
			cCodCIIU, tObservac 
		FROM #curdetproapr
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			RETURN
		END

	/* ACTUALIZAMOS DATOS DE SOLICITUD */
	UPDATE KPYMSolicitud
		SET nMonSolCre = nMonPropue,
			nNumCuoSol = nNumCuota
	FROM KPYMSolicitud INNER JOIN #curdetproapr
		ON KPYMSolicitud.CCODSOLCRE = #curdetproapr.CCODSOLCRE
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			RETURN
		END

	/* DESTINO DEL CREDITO 	*/
	EXEC KPY_ModDesCre_sp @x_xmldescrecon, @x_cCodSolCre, '', @x_cCodUsu, @x_dFecSis, NULL, NULL	
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    

	/* GIRO NEGOCIO */
	EXEC sp_xml_preparedocument @pnIdeGirNeg OUTPUT, @x_xmlgirneg
		SELECT 	ccodsolcre, ccodgirneg, nnumdias, 
					ndia1, ndia2, ndia3,
	 				ndia4, ndia5, ndia6,
	  				ndia7, nprom 
			INTO #curGirNeg
		 FROM OPENXML(@pnIdeGirNeg,'/VFPData/curgirneg',1)
					WITH 	(ccodsolcre char(10), ccodgirneg char(3), nnumdias numeric(14,2), 
					ndia1 numeric(14,2), ndia2 numeric(14,2), ndia3 numeric(14,2),
	 				ndia4 numeric(14,2), ndia5 numeric(14,2), ndia6 numeric(14,2),
	  				ndia7 numeric(14,2), nprom numeric(14,2))
	EXEC sp_xml_removedocument @pnIdeGirNeg	

	/* ACTUALIZAMOS DATOS DE LA TABLA DE PROPUESTA DE CREDITOS */
	UPDATE kpyddetsolcre
			SET 	nNumDiaVen = nnumdias,
					nVenPriDia = ndia1,
					nVenSegDia = ndia2,
					nVenTerDia = ndia3,
					nVenCuaDia = ndia4,
					nVenQuiDia = ndia5,
					nVenSexDia = ndia6,
					nVenSepDia = ndia7,
					nProVentas = nprom
		FROM kpyddetsolcre INNER JOIN #curGirNeg
			ON kpyddetsolcre.cCodSolcre = #curGirNeg.cCodSolCre
			AND kpyddetsolcre.ccodgirneg = #curGirNeg.ccodgirneg
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    

	/*  GARANTIAS */
	EXEC sp_xml_preparedocument @pnIdeGarant OUTPUT, @x_xmlgarguarda
		SELECT 	@x_ccodsolcre as ccodsolcre, ctitgar, nmonrea, nvalcom
			INTO #curgarSol
		 FROM OPENXML(@pnIdeGarant,'/VFPData/curgarguarda',1)
					WITH 	(	ctitgar varchar(60),
								nmonrea numeric(14,2), nvalcom numeric(14,2))
	EXEC sp_xml_removedocument @pnIdeGarant	

	DELETE kpydgarsolici 
			WHERE cCodSolCre = @x_cCodSolCre
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN
		END
	
	INSERT INTO	kpydgarsolici
		(	cCodSolCre, cProGarant,
			nMonValRea, nMonValCom
		)
	SELECT 	cCodSolCre, ctitgar,
				nmonrea, nvalcom
		FROM #curgarSol 
	IF @@ERROR <>0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

COMMIT TRAN
GO
	GRANT EXEC ON [dbo].[KPY_IngProApr_sp] TO ADM_ADM_rl	
GO

IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_ResComCre_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_ResComCre_sp]
GO
/*********************************************************************************************
*	Copyright © 2008 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo: Actualiza datos de la resolución de comité de créditos
*  
*	Escrito por: 			GLOPEZ
*	Email/Movil/Phone:		GLOPEZ@CMAC-HUANCAYO.COM.PE
*  
*	Fecha creación: 2006-12-12
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:
*	Fecha   	Creador   	Motivo
*	2007-04-25	glopez		Se añade modificación de destinos de créditos
*	2009.01.10	OPEREZ		Se añadio la actualizacion del tipo de acta.
*	2009.01.20  AROBLE		Se añadio el cursor de gastos  
*	2010.07.01	AROBLE		Se adecua a la nueva estructura de gastos 
*	2012.06.15  CMUCHA		Se elimina tablas de planes de pago de leasing
*	2013.05.06	CMUCHA		Guarda valores de afiliación al seguro desgravamen.
*	2013.11.22	CMUCHA		Se agrega clientes afiliados al seguro.
*	2014.11.24	YGONZA		Se agrega parametro a KPY_ModDesCre_sp
*	2015.10.15	HVARGA		Se agrega 1 parametro adicional al SP KPY_ModDesCre_sp

*	Sintaxis de ejemplo:  
*			No es posible por tener parámetros de tipo XML

**********************************************************************************************/
CREATE PROCEDURE KPY_ResComCre_sp
	@x_cursol	TEXT,
	@x_curamp	TEXT,
	@x_DesCre	TEXT,
	@x_TipDes	TEXT,
	@x_MotDen	TEXT,
	@x_ComApr	TEXT,
	@x_cCodSol	CHAR(10),
	@x_cEstSol	CHAR(1),
	@x_ccodSit	CHAR(1),
	@x_PrePag	CHAR(1)= 'N',
	@x_ActSco	VARCHAR(50) OUTPUT,
	@x_MonAcu	NUMERIC(14,2) OUTPUT,
	@x_MsgValPar VARCHAR(100) OUTPUT,
	@x_cCodOficin CHAR(3),
	@x_cDesMotivo VARCHAR(100),
	@x_nTasIntMin NUMERIC(14,4),
	@x_cCodOfiCta CHAR(3),
	@x_xDetGasTos TEXT,
	@x_xCliAfiSeg XML
AS    
	SET NOCOUNT ON    
	SET XACT_ABORT  ON

	DECLARE @IDOC int,
			@x_cCodUsu CHAR(6),
			@x_dFecSis DATETIME,
			@pcTipAct CHAR(3),
			@pnIdeDoc INT,
			@x_cTabConsulta varchar(200),
			@x_cTabCursor varchar(5000)

BEGIN TRANSACTION
	--- Preparando Documento XML    
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_cursol    
    
SELECT
	cCodSolCre,cCodTipSol,cCodClient,cCodMoneda,nMonSolCre,cCodUsuAna,nNumCuoSol, nPlaSolCre,dFecSolCre,    
	cCodUsuSol,cMonedaApr,nMonSugAna, cDescriSol,nMonAprCre,nNumCuoApr,nPlaAprCre,dFecAprCre,cObsAnaCre,    
	cCodExpCli,cCodEstSol,cCodOficin,cCodActAna,cCodTipAct,cCodComite,cCodPlazo,dFecModCre,    
	cCodUsuIng,lHistoria =CASE WHEN lHistoria = 'TRUE' THEN 1 ELSE 0 END,    
	cCreNuevo,cCreNorRef,cCodMotSol,cCodTipCre,ccodproduc,cCodSubPro,cCodRecurs,    
	cCodTipRec,ntasintcom,cCodSitSol,nNumDiaGra,dFecDesRef,dFecVenRef,    
	lCuotaCons =CASE WHEN lCuotaCons = 'TRUE' THEN 1 ELSE 0 END,    
	cLibAmoCre,cTipPeriodo,cCodTipCuo,cCodModCre,nDiaFecFij,nNumDesemb,cTipDocIde,cNroDocIde,cClaSolCre,    
	dIniLinSol,dFinLinSol,dIniLinApr, dFinLinApr,cCodLinCre,    
	lTieneLin=CASE WHEN lTieneLin = 'TRUE' THEN 1 ELSE 0 END,    
	cCodConven,    
	lConConven=CASE WHEN lConConven = 'TRUE' THEN 1 ELSE 0 END,    
	nNroLinFin,ctiptascom,cCodIntCon,ctiptasmor,ntasintmor,nNroTasCom,nNroTasMor, cIndGenOP, ccodparcam,
	ccodciiusol, criecrecam
	INTO #CURSOLICI    
	FROM OPENXML (@IDOC, '/VFPData/cursolicitud',1)    
	WITH    
		(ccodsolcre char(10),ccodtipsol char(3),ccodclient char(14),ccodmoneda char(1),nmonsolcre numeric(14,4),    
		ccodusuana char(6),nnumcuosol smallint, nplasolcre smallint,dfecsolcre datetime,    
		ccodususol char(6),cmonedaapr char(1),nmonsugana numeric(14,4), cdescrisol varchar(40),nmonaprcre numeric(14,4),    
		nnumcuoapr smallint,nplaaprcre smallint,dfecaprcre datetime,cobsanacre text,    
		ccodexpcli char(9),ccodestsol char(1),ccodoficin char(3),ccodactana char(7),ccodtipact char(3),ccodcomite char(3),    
		ccodplazo char(1),dfecmodcre datetime,ccodusuing char(6),lhistoria varchar(10),ccrenuevo char(1),ccrenorref char(1),    
		ccodmotsol char(1),ccodtipcre char(2),ccodproduc char(2),ccodsubpro char(2),ccodrecurs char(2),    
		ccodtiprec char(2),ntasintcom numeric(14,4),ccodsitsol char(2) ,nnumdiagra smallint,dfecdesref datetime,    
		dfecvenref datetime,lcuotacons varchar(10),clibamocre char(1),ctipperiodo char(1),ccodtipcuo char(1),ccodmodcre char(2),    
		ndiafecfij smallint,nnumdesemb smallint,ctipdocide char(1),cnrodocide char(15),cclasolcre char(1), 
		dinilinsol datetime,dfinlinsol datetime,dinilinapr datetime,dfinlinapr datetime,ccodlincre char(10),ltienelin varchar(10),    
		ccodconven char(6),lconconven varchar(10),nnrolinfin int,ctiptascom char(2),ccodintcon char(3),    
		ctiptasmor char(2),ntasintmor numeric(14,4),nnrotascom int,nnrotasmor int, cindgenop char(1), ccodparcam char(2),
		ccodciiusol char(4), criecrecam char(1))
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    
    
 --- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    

	--Cargando el curso de gastos 
	Exec sp_xml_preparedocument @idoc output, @x_xDetGasTos
	select  ccodgascre,					 nmongascre,  act, 
			@x_ccodsol	as ccodsolcre,   nMonValAse,  nCodGasCor
			nCodGasCor, nnumvalgas
	Into #CurGastos
	From openxml(@idoc,'/VFPData/curgastos',1) 
    With (ccodgascre char(5),	nmongascre  numeric(9,4),		act bit,
		  ccodsolcre char(10),	nmonvalase  numeric(9,4),	    ncodgascor int,
		  nnumvalgas smallint)

	Exec sp_xml_removedocument @idoc 



SELECT	@x_cCodUsu = cCodUsuIng, 
		@x_dFecSis = dFecModCre,
		@pcTipAct = cCodTipAct
FROM #CURSOLICI 

--/**********************************************************************************************
--	MODIFICACIONES PARA EL CALCULO, REGISTRO Y RETORNO DEL SCORE Y MONTO ACUMULADO DE DEUDA
--***********************************************************************************************/
DECLARE	@nValScoSol NUMERIC(14, 2), 	-- VALOR DEL SCORE
	@cTipActSco VARCHAR(3), 	-- TIPO DE ACTA DE COMITE
	@nNumScoCli INT,		-- NUMERO DE CONSULTA DE SCORE
	@cCodCliente CHAR(12),
	@cCodUsuIng CHAR(6),
	@dFecSolCre SMALLDATETIME,
	@nMonSolCre NUMERIC(14,2),
	@nMonTipCam NUMERIC(14,2),
	@cCodMoneda CHAR(1),
	@pcMotSol CHAR(1), 
	@nCapAmpli Numeric(14,4),
	@cCodTipCre Char(3),
	@cCodSubPro CHAR(6),
	@nMorAntAmo SMALLINT,
	@nPlazo INT,
	@nNumCuoApr INT,
	@nTasInt NUMERIC(14,4)
	
-- VARIABLES
SELECT 	@cCodCliente = cCodClient,
	@cCodMoneda	= cMonedaApr,
	@nMonSolCre	= nMonAprCre,
	@dFecSolCre	= dFecSolCre,
	@cCodUsuIng	= cCodUsuIng,
	@pcMotSol	= CCODMOTSOL,
	@cCodTipCre	= cCodTipCre,
	@cCodSubPro = cCodTipCre+ccodproduc+cCodSubPro,
	@nPlazo		= nPlaAprCre,
	@nNumCuoApr = nNumCuoAPr,
	@nTasInt	= nTasIntCom
FROM #CURSOLICI
------------------------------------------------------------------------------------------------------    
 --  Al aprobar una solicitud de crédito, por defecto la fecha de desembolso igual a la fecha de aprobación    
 --  Ademas por defecto el  Numero de Desembolsos = 1    
   
	UPDATE #CURSOLICI 
		SET dFecDesRef=dFecAprCre,
			nNumDesemb=1 
		WHERE (cCodEstsol = 'A' and cCodSitSol = 'P') or cCodEstSol='B'
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    
	
	UPDATE KPYMSOLICITUD SET     
		cCodMoneda	=#CURSOLICI.cCodMoneda,
		cCodUsuAna	=#CURSOLICI.cCodUsuAna,
		nNumCuoSol	=#CURSOLICI.nNumCuoSol,
		nPlaSolCre	=#CURSOLICI.nPlaSolCre,
		cMonedaApr	=#CURSOLICI.cMonedaApr,
		cDescriSol	=#CURSOLICI.cDescriSol,
		nMonAprCre	=#CURSOLICI.nMonAprCre,
		nNumCuoApr	=#CURSOLICI.nNumCuoApr,
		nPlaAprCre	=#CURSOLICI.nPlaAprCre,
		dFecAprCre	=#CURSOLICI.dFecAprCre,
		cobsanacre	=#CURSOLICI.cobsanacre,
		cCodEstSol  =#CURSOLICI.cCodEstSol,
		cCodPlazo   =#CURSOLICI.cCodPlazo,
		dFecModCre  =#CURSOLICI.dFecModCre,    
		cCodUsuIng  =#CURSOLICI.cCodUsuIng,
		lHistoria   =#CURSOLICI.lHistoria,    
		cCreNuevo   =#CURSOLICI.cCreNuevo,    
		cCreNorRef  =#CURSOLICI.cCreNorRef,    
		cCodMotSol  =#CURSOLICI.cCodMotSol,    
		cCodTipCre  =#CURSOLICI.cCodTipCre,    
		ccodproduc  =#CURSOLICI.ccodproduc,    
		cCodSubPro  =#CURSOLICI.cCodSubPro,    
		cCodRecurs	=#CURSOLICI.cCodRecurs,    
		cCodTipRec	=#CURSOLICI.cCodTipRec,    
		ntasintcom	=#CURSOLICI.ntasintcom,   
		cCodSitSol	=#CURSOLICI.cCodSitSol,    
		nNumDiaGra	=#CURSOLICI.nNumDiaGra,    
		dFecDesRef	=#CURSOLICI.dFecDesRef,    
		dFecVenRef	=#CURSOLICI.dFecVenRef,    
		lCuotaCons	=#CURSOLICI.lCuotaCons,    
		cLibAmoCre	=#CURSOLICI.cLibAmoCre,   
		cTipPeriodo	=#CURSOLICI.cTipPeriodo,    
		cCodTipCuo	= CASE WHEN #CURSOLICI.cCodTipCuo = '1' THEN  '4' ELSE '4' END,    
		cCodModCre	=#CURSOLICI.cCodModCre,    
		nDiaFecFij	=#CURSOLICI.nDiaFecFij,    
		nNumDesemb	=#CURSOLICI.nNumDesemb,    
		dIniLinSol	=#CURSOLICI.dIniLinSol,    
		dFinLinSol	=#CURSOLICI.dFinLinSol,    
		dIniLinApr	=#CURSOLICI.dIniLinApr,    
		dFinLinApr	=#CURSOLICI.dFinLinApr,    
		cCodLinCre	=#CURSOLICI.cCodLinCre,    
		lTieneLin	=#CURSOLICI.lTieneLin,    
		cCodConven	=#CURSOLICI.cCodConven,    
		lConConven	=#CURSOLICI.lConConven,    
		nNroLinFin	=#CURSOLICI.nNroLinFin,    
		ctiptascom	=#CURSOLICI.ctiptascom,    
		cCodIntCon	=#CURSOLICI.cCodIntCon,    
		ctiptasmor	=#CURSOLICI.ctiptasmor,    
		ntasintmor	=#CURSOLICI.ntasintmor,    
		nNroTasCom	=#CURSOLICI.nNroTasCom,    
		nNroTasMor	=#CURSOLICI.nNroTasMor,    
		cIndGenOP	=#CURSOLICI.cIndGenOP,
		ccodparcam	=#CURSOLICI.ccodparcam,
		cTipActSis	=#CURSOLICI.ccodtipact
	FROM KPYMSOLICITUD 
		INNER JOIN #CURSOLICI     
			ON(KPYMSOLICITUD.CCODSOLCRE=#CURSOLICI.CCODSOLCRE)    
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    

	IF @cCodSubPro NOT IN ('020205','030215','120205','130205')

	BEGIN
		DELETE FROM KPYDGasGenCre
		WHERE cCodSolCre = @x_cCodSol
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
		END

	INSERT INTO KPYDGasGenCre 
		(cCodSolCre, cCodGasCre, nMonGasGen, nMonGasIni, nMonSegAse, nCodGasCor, nNumValGas)
	SELECT 
		 @x_cCodSol, cCodGasCre, nmongascre, nmongascre, nMonValAse, nCodGasCor, nNumValGas
	FROM #CurGastos
	WHERE Act = 1
	 
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END  

	--\\ Inserta afiliados a seguro //--	
	IF @x_xCliAfiSeg IS NOT NULL
	BEGIN
		EXECUTE KPY_InsCliAfiSeg_SP
					@x_cCodSolCre = @x_cCodSol,
					@x_xCliAfiSeg = @x_xCliAfiSeg,
					@x_cCodUsu    = @x_cCodUsu,
					@x_dFecSis    = @dFecSolCre
		IF @@ERROR <> 0    
		BEGIN
			ROLLBACK TRANSACTION
			RETURN  
		END
	END		
		
	--\\ Actualiza seguimiento afiliación seguro desgrav. //--
	EXECUTE dbo.KPY_InsSegAfiIni_SP
				@x_cCodSol	  = @x_cCodSol,
				@x_cCodUsu    = @x_cCodUsu,
				@x_cCodOficin = @x_cCodOficin
      IF @@ERROR <>0    
            BEGIN    
                  ROLLBACK TRANSACTION    
                  RETURN    
            END

	IF EXISTS(
		SELECT ccodsolcre 
			FROM KPYHSolTasEsp
		WHERE cCodSolCre = @x_cCodSol)
		BEGIN
			UPDATE KPYHSolTasEsp
				SET cDesMotivo = @x_cDesMotivo,
					cCodUsuReg = @x_cCodUsu,
					dFecRegTas = @x_dFecSis,
					dFecHorSis = getdate(),
					nTasIntIni = @x_nTasIntMin,
					nTasIntFin = @nTasInt
			WHERE cCodSolCre = @x_cCodSol
			IF @@ERROR <>0    
				BEGIN    
					ROLLBACK TRANSACTION    
					RETURN    
				END    
		END
	ELSE
		BEGIN
			INSERT INTO KPYHSolTasEsp
				(
				cCodSolCre, dFecRegTas, dFecHorSis, nTasIntIni, 
				nTasIntFin, cCodUsuReg, cDesMotivo
				)
			VALUES
				(
				@x_cCodSol, @x_dFecSis, GETDATE(), @x_nTasIntMin,
				@nTasInt, @x_cCodUsu, @x_cDesMotivo
				)
			IF @@ERROR <>0    
				BEGIN    
					ROLLBACK TRANSACTION    
					RETURN    
				END    
		END

	DECLARE @pcMsgValPar VARCHAR(100)
	
	EXEC KPY_RetParCre_sp @x_cCodSol, @cCodCliente, 
			@nNumCuoApr, @nPlazo, @nMonTipCam, @nMonSolCre,
			@x_dFecSis, @pcMsgValPar OUTPUT
	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RETURN -1
		END

	SET @x_MsgValPar = ISNULL(@pcMsgValPar,'')
	IF @x_MsgValPar <> ''
		BEGIN
			ROLLBACK TRANSACTION
			RETURN -1
		END

	/* DESTINO DEL CREDITO 	*/
	EXEC KPY_ModDesCre_sp @x_DesCre, @x_TipDes, @x_cCodSol, '', @x_cCodUsu, @x_dFecSis,NULL, NULL
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END

	-- Eliminacion del PLna de DEsembolso y de Pagos
	-- Eliminar de leasing --
	DELETE FROM KPYDPlanPagSolLsg	
	WHERE cCodSolCre = @x_cCodSol
	IF @@ERROR<>0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END	
	
	DELETE FROM KPYDPlanPagSol 
	WHERE cCodSolCre = @x_cCodSol
	IF @@ERROR<>0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END
	
	DELETE FROM KPYMPlaPagSol 
	WHERE cCodSolCre = @x_cCodSol
	IF @@ERROR<>0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END

	-- Eliminar de leasing --
	DELETE FROM KPYDPlaDesSolLsg
	WHERE cCodSolCre = @x_cCodSol
	IF @@ERROR<>0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END	

	DELETE FROM KPYDPlaDesSol 
	WHERE cCodSolCre = @x_cCodSol
	IF @@ERROR<>0
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END

COMMIT TRANSACTION
--*************************************************************************************************************************
GO
	GRANT EXEC ON [dbo].[KPY_ResComCre_sp] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_UpdateSolicitud_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_UpdateSolicitud_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2014 CMAC Huancayo -. All rights reserved.  
*                                           
*	Objetivo: Actualiza datos de solicitud de creditos
*  
*	Escrito por: 			GLOPEZ
*	Email/Movil/Phone:		GLOPEZ@CMAC-HUANCAYO.COM.PE
*  
*	Fecha creación: 2003-06-01
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:
*		Fecha   	Creador   	Motivo
*   2005-10-17		GLOPEZ		Se agrega el parametro de Reprogramacion con o sin Pre - Pago
*	2006-02-13		VEGASA		Se Agrega datos para la evaluacion del Scoring Targeting del Cliente
*	2006-09-22		VEGASA		Se Agrega datos para la evaluacion del Scoring Evaluation del Cliente
*	2006-10-09		GLOPEZ		Debe registrar el motivo de Denegación de solicitudes
*	2014.11.24		YGONZA		Se agrega parametro a KPY_ModDesCre_sp
*	2015.10.15		HVARGA		Se agrega 1 parametro adicional al SP KPY_ModDesCre_sp

*	Sintaxis de ejemplo:  
*		EXEC KPY_UpdateSolicitud_sp '', '', '', '0010171570', 'B', 'S'
*
***********************************************************************************************************************************************************************************************/  
CREATE PROCEDURE [dbo].[KPY_UpdateSolicitud_sp]    
	@x_cursol TEXT,
	@x_curamp TEXT,
	@x_DesCre TEXT,
	@x_TipDes TEXT,
	@x_MotDen TEXT,
	@x_cCodSol CHAR(10),
	@x_cEstSol CHAR(1),
	@x_PrePag CHAR(1)= 'N',
	@x_ActSco VARCHAR(50) OUTPUT,
	@x_MonAcu Numeric(14,2) OUTPUT,
	@x_cCodOficin CHAR(3)
AS    
	SET NOCOUNT ON    
	SET XACT_ABORT  ON

	BEGIN TRANSACTION
	DECLARE @IDOC int
	DECLARE @x_cCodUsu CHAR(6)
	DECLARE @x_dFecSis DATETIME
	
	--- Preparando Documento XML    
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_cursol    
    
SELECT
	cCodSolCre,cCodTipSol,cCodClient,cCodMoneda,nMonSolCre,cCodUsuAna,nNumCuoSol, nPlaSolCre,dFecSolCre,    
	cCodUsuSol,cMonedaApr,nMonSugAna, cDescriSol,nMonAprCre,nNumCuoApr,nPlaAprCre,dFecAprCre,cObsAnaCre,    
	cCodExpCli,cCodEstSol,cCodOficin,cCodActAna,cCodTipAct,cCodComite,cCodPlazo,dFecModCre,    
	cCodUsuIng,lHistoria =CASE WHEN lHistoria = 'TRUE' THEN 1 ELSE 0 END,    
	cCreNuevo,cCreNorRef,cCodMotSol,cCodTipCre,ccodproduc,cCodSubPro,cCodRecurs,    
	cCodTipRec,ntasintcom,cCodSitSol,nNumDiaGra,dFecDesRef,dFecVenRef,    
	lCuotaCons =CASE WHEN lCuotaCons = 'TRUE' THEN 1 ELSE 0 END,    
	cLibAmoCre,cTipPeriodo,cCodTipCuo,cCodModCre,nDiaFecFij,nNumDesemb,cTipDocIde,cNroDocIde,cClaSolCre,    
	dIniLinSol,dFinLinSol,dIniLinApr, dFinLinApr,cCodLinCre,    
	lTieneLin=CASE WHEN lTieneLin = 'TRUE' THEN 1 ELSE 0 END,    
	cCodConven,    
	lConConven=CASE WHEN lConConven = 'TRUE' THEN 1 ELSE 0 END,    
	nNroLinFin,ctiptascom,cCodIntCon,ctiptasmor,ntasintmor,nNroTasCom,nNroTasMor, cIndGenOP, ccodparcam,
	ccodciiusol, criecrecam
	INTO #CURSOLICI    
	FROM OPENXML (@IDOC, '/VFPData/cursolicitud',1)    
	WITH    
		(ccodsolcre char(10),ccodtipsol char(3),ccodclient char(14),ccodmoneda char(1),nmonsolcre numeric(14,4),    
		ccodusuana char(6),nnumcuosol smallint, nplasolcre smallint,dfecsolcre datetime,    
		ccodususol char(6),cmonedaapr char(1),nmonsugana numeric(14,4), cdescrisol varchar(40),nmonaprcre numeric(14,4),    
		nnumcuoapr smallint,nplaaprcre smallint,dfecaprcre datetime,cobsanacre text,    
		ccodexpcli char(9),ccodestsol char(1),ccodoficin char(3),ccodactana char(7),ccodtipact char(3),ccodcomite char(3),    
		ccodplazo char(1),dfecmodcre datetime,ccodusuing char(6),lhistoria varchar(10),ccrenuevo char(1),ccrenorref char(1),    
		ccodmotsol char(1),ccodtipcre char(2),ccodproduc char(2),ccodsubpro char(2),ccodrecurs char(2),    
		ccodtiprec char(2),ntasintcom numeric(14,4),ccodsitsol char(2) ,nnumdiagra smallint,dfecdesref datetime,    
		dfecvenref datetime,lcuotacons varchar(10),clibamocre char(1),ctipperiodo char(1),ccodtipcuo char(1),ccodmodcre char(2),    
		ndiafecfij smallint,nnumdesemb smallint,ctipdocide char(1),cnrodocide char(15),cclasolcre char(1),    
		dinilinsol datetime,dfinlinsol datetime,dinilinapr datetime,dfinlinapr datetime,ccodlincre char(10),ltienelin varchar(10),    
		ccodconven char(6),lconconven varchar(10),nnrolinfin int,ctiptascom char(2),ccodintcon char(3),    
		ctiptasmor char(2),ntasintmor numeric(14,4),nnrotascom int,nnrotasmor int, cindgenop char(1), ccodparcam char(2),
		ccodciiusol char(4), criecrecam char(1))
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    
    
 --- Removiendo el Documento XML    
	EXEC SP_XML_REMOVEDOCUMENT @IDOC    

/**********************************************************************************************
	MODIFICACIONES PARA EL CALCULO, REGISTRO Y RETORNO DEL SCORE Y MONTO ACUMULADO DE DEUDA
***********************************************************************************************/
DECLARE	@nValScoSol NUMERIC(14, 2), 	-- VALOR DEL SCORE
	@cTipActSco VARCHAR(3), 	-- TIPO DE ACTA DE COMITE
	@nNumScoCli INT,		-- NUMERO DE CONSULTA DE SCORE
	@cCodCliente CHAR(12),
	@cCodUsuIng CHAR(6),
	@dFecSolCre SMALLDATETIME,
	@nMonSolCre NUMERIC(14,2),
	@nMonTipCam NUMERIC(14,2),
	@cCodMoneda CHAR(1),
	@pcMotSol CHAR(1), 
	@nCapAmpli Numeric(14,4),
	@cCodTipCre Char(3),
	@cCodSubPro CHAR(6),
	@nMorAntAmo SMALLINT
	
-- VARIABLES
SELECT 	@cCodCliente = cCodClient,
	@cCodMoneda	= cMonedaApr,
	@nMonSolCre	= nMonAprCre,
	@dFecSolCre	= dFecSolCre,
	@cCodUsuIng	= cCodUsuIng,
	@pcMotSol	= CCODMOTSOL,
	@cCodTipCre	= cCodTipCre,
	@cCodSubPro = cCodTipCre+ccodproduc+cCodSubPro
FROM #CURSOLICI

/**************************************************************************************************
					CAMBIOS PARA CREDITSCORING
***************************************************************************************************/

-- RECUPERANDO EL SCORE Y NUMERO DE CONSULTA MODELO TARGETING
EXEC KPY_RetValScoTar_SP 
	@dFecSolCre, 
	@cCodCliente, 
	@cCodUsuIng, 
	'R' , 
	@nValScoSol OUTPUT, 
	@nNumScoCli OUTPUT, 
	@nMorAntAmo OUTPUT

IF @@ERROR <>0    
	BEGIN    
		ROLLBACK TRANSACTION    
		RETURN    
	END    

DECLARE @x_cTabConsulta VARCHAR(200), @x_cTabCursor VARCHAR(5000)
SET @x_cTabConsulta = 'Kpy_LisSalTotCli_SP ' +
	CHAR(39) + @cCodCliente + CHAR(39)

CREATE TABLE #CurTotCtaCli
(cCodCtaCre CHAR(18), nMonSalCap NUMERIC(14,2), cEstCreCon CHAR(1), cCodTipMon CHAR(1), TipCre  CHAR(3))

-- Cursor para consolidar los datos    
DECLARE curTabRep CURSOR FOR
SELECT cnomBD + '.dbo.' + @x_cTabConsulta AS cNomServer     
FROM GentOficinas rel
	Inner Join ADMTServidor Ser (NOLOCK) ON rel.cCodOficin = ser.ccodoficin
WHERE Rel.lConestado = 1
ORDER BY ser.ccodoficin

Open curTabRep     
FETCH NEXT FROM curTabRep     
INTO @x_cTabCursor     
WHILE @@FETCH_STATUS = 0
BEGIN     
	BEGIN    
		INSERT INTO #CurTotCtaCli
		EXECUTE (@x_cTabCursor)
	END    
	FETCH NEXT FROM curTabRep     
	INTO @x_cTabCursor     
END     
CLOSE curTabRep     
DEALLOCATE curTabRep

-- RECUPERAMOS EL SALDO CAPITAL DE LAS AMPLIACIONES
IF @pcMotSol = '3'
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @IDOC OUTPUT, @x_curamp  
		SELECT @nCapAmpli = nSalCap
		FROM OPENXML (@IDOC, '/VFPData/currefina',1)  
	 WITH (nsalcap numeric(14,4))   
	EXEC SP_XML_REMOVEDOCUMENT @IDOC 
END
ELSE
	SET @nCapAmpli = 0
-- DETERMINAMOS EL MONTO A ADICIONAR AL SALDO ACUMULADO SEGUN EL MOTIVO DE LA SOLICITUD 
Set
@nMonSolCre = 	
	CASE 
		WHEN @pcMotSol In('4','5') THEN 0 -- Refinanciación  y Reprogramación
		WHEN @pcMotSol In('3') THEN @nMonSolCre - @nCapAmpli --Ampliación
		ELSE @nMonSolCre 
	END
-- RECUPERANDO EL TIPO DE CAMBIO
SELECT @nMonTipCam =dbo.ADM_TipCam_fx(@dFecSolCre,'F')
-- DETERMINANDO EL MONTO TOTAL ACUMULADO CON EL QUE SE DETERMINARÁ EL NIVEL DE APROBACION
SET @x_MonAcu = 0
IF @cCodMoneda = '1'
	SELECT @x_MonAcu = ISNULL(SUM(CASE WHEN cCodTipMon = '1' THEN nMonSalCap ELSE (nMonSalCap * @nMonTipCam) END),0) + @nMonSolCre
	FROM #CurTotCtaCli
ELSE
	SELECT @x_MonAcu = ISNULL(SUM(CASE WHEN cCodTipMon = '2' THEN nMonSalCap ELSE (nMonSalCap / @nMonTipCam) END),0) + @nMonSolCre
	FROM #CurTotCtaCli
DROP TABLE #CurTotCtaCli

-- SI EL CLIENTE PERTENECE A TARGETING
IF @nValScoSol != -1
BEGIN

	-- OBTENIENDO EL NIVEL DE APROBACION SEGUN EL MONTO ACUMULADO, EL SCORE Y LA MONEDA
	SELECT @cTipActSco = A.cTipActSco, @x_ActSco = B.cDesTipAct +' - '+ B.cDesInsApr
	FROM KPYTNivAprSco A
	INNER JOIN KPYTTipActSco B
			ON A.cTipActSco = B.cTipActSco
	WHERE (@nValScoSol BETWEEN nScoIniNiv AND nScoFinNiv)
		AND (@x_MonAcu > nMonIniNiv AND @x_MonAcu <= nMonFinNiv)
		AND lEstNivSco = 1
		And cCodTipMon = @cCodMoneda
		And cCodTipMod = 'T'
END
ELSE
BEGIN
-- SI EL CLIENTE PERTENECE A EVALUATION
	DECLARE @x_SubPro CHAR(04)
	SELECT 	@x_SubPro = cCodTipCre + ccodproduc
	FROM #CURSOLICI

	EXEC KPY_RetValScoEva_SP 
		@x_dFecSis		= @dFecSolCre, 
		@x_cCodCli		= @cCodCliente, 
		@x_cCodUsu		= @cCodUsuIng,
		@x_TipRet		= 'R', 
		@x_ValScor		= @nValScoSol OUTPUT, 
		@x_nNumScoCli	= @nNumScoCli OUTPUT,
		@x_nAtrAntAmo	= @nMorAntAmo OUTPUT,
		@x_TipProSub	= @cCodSubPro

	-- OBTENIENDO EL NIVEL DE APROBACION SEGUN EL MONTO ACUMULADO, EL SCORE Y LA MONEDA
	SELECT @cTipActSco = A.cTipActSco, @x_ActSco = B.cDesTipAct +' - '+ B.cDesInsApr
	FROM KPYTNivAprSco A
		INNER JOIN KPYTTipActSco B
			On A.cTipActSco = B.cTipActSco
	WHERE (@nValScoSol BETWEEN nScoIniNiv AND nScoFinNiv)
		AND (@x_MonAcu > nMonIniNiv AND @x_MonAcu <= nMonFinNiv)
		AND lEstNivSco = 1
		And cCodTipMon = @cCodMoneda
		And cCodTipMod = 'E'
		And cCodTipcre = Left(@x_SubPro,2)
		And cCodProduc Like Case When Left(@x_SubPro,2) = '03' Then '%' Else Right(@x_SubPro,2) End
END
-- PERSONALISANDO MENSAJES PARA CASOS NO CONTEMPLADOS POR EL SCORING
SELECT 
	@x_ActSco = 
		CASE 
			WHEN @cCodTipCre = '01' THEN 'POLITICAS PARA CREDITOS COMERCIALES'
			WHEN @cCodTipCre = '04' THEN 'POLITICAS PARA CREDITOS HIPOTECARIOS'
			WHEN @cCodSubPro = '030207' THEN 'POLITICAS PARA CREDITOS CON CTS'
			WHEN @cCodSubPro = '030106' THEN 'POLITICAS PARA CREDITOS CON PF'
			WHEN @cCodSubPro = '030103' THEN 'POLITICAS PARA CREDITOS ADMINISTRATIVOS'
			WHEN CASE 
					WHEN @cCodMoneda = '1' THEN @x_MonAcu / @nMonTipCam 
					ELSE @x_MonAcu 
				END >= 30000 THEN 'MONTO ACUMULADO SUPERA LOS US$ 30,000'
			ELSE	@x_ActSco
		END
-- SUBIENDO EL NIVEL DE APROBACIÓN PARA CASOS DE CREDITOS QUE PERTENECEN A LA POBLACION DE TARGETING CON
-- DIAS DE ATRASO MAYOR A 360, CASOS EN LOS QUE LAS VARIABLES DE MORA NO LO CASTIGAN
IF @nMorAntAmo > 360
BEGIN
	SELECT @cTipActSco = 
		CASE 
			WHEN @cTipActSco = 'AUT' THEN 'ANA'
			WHEN @cTipActSco = 'ANA' THEN 'AGE'
			WHEN @cTipActSco = 'AGE' THEN 'CEN'
			WHEN @cTipActSco = 'CEN' THEN 'GER'
			WHEN @cTipActSco = 'GER' THEN 'POL'
			ELSE @cTipActSco
		END
	
	SELECT @x_ActSco = cDesTipAct +' - '+ cDesInsApr 
	FROM KPYTTIPACTSCO 
	WHERE CTIPACTSCO = @cTipActSco
END

/**************************************************************************************************
		FIN DE CAMBIOS PARA CREDITSCORING
***************************************************************************************************/
------------------------------------------------------------------------------------------------------    
 --  Al aprobar una solicitud de crédito, por defecto la fecha de desembolso igual a la fecha de aprobación    
 --  Ademas por defecto el  Numero de Desembolsos = 1    
   
	UPDATE #CURSOLICI SET dFecDesRef=dFecAprCre,nNumDesemb=1 WHERE cCodEstSol='B'    
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    
	
	UPDATE KPYMSOLICITUD SET     
		cCodTipSol	=#CURSOLICI.cCodTipSol,    
		cCodClient	=#CURSOLICI.cCodClient,    
		cCodMoneda	=#CURSOLICI.cCodMoneda,    
		nMonSolCre	=#CURSOLICI.nMonSolCre,    
		cCodUsuAna	=#CURSOLICI.cCodUsuAna,    
		nNumCuoSol	=#CURSOLICI.nNumCuoSol,    
		nPlaSolCre	=#CURSOLICI.nPlaSolCre,    
		dFecSolCre	=#CURSOLICI.dFecSolCre,    
		cCodUsuSol	=#CURSOLICI.cCodUsuSol,    
		cMonedaApr	=#CURSOLICI.cMonedaApr,    
		nMonSugAna	=#CURSOLICI.nMonSugAna,    
		cDescriSol	=#CURSOLICI.cDescriSol,    
		nMonAprCre	=#CURSOLICI.nMonAprCre,    
		nNumCuoApr	=#CURSOLICI.nNumCuoApr,    
		nPlaAprCre	=#CURSOLICI.nPlaAprCre,    
		dFecAprCre	=#CURSOLICI.dFecAprCre,    
		cobsanacre	=#CURSOLICI.cobsanacre,    
		cCodExpCli  =#CURSOLICI.cCodExpCli,    
		cCodEstSol  =#CURSOLICI.cCodEstSol,    
		cCodOficin  =#CURSOLICI.cCodOficin,    
		cCodActAna  =#CURSOLICI.cCodActAna,    
		cCodTipAct  =#CURSOLICI.cCodTipAct,    
		cCodComite  =#CURSOLICI.cCodComite,    
		cCodPlazo   =#CURSOLICI.cCodPlazo,    
		dFecModCre  =#CURSOLICI.dFecModCre,    
		cCodUsuIng  =#CURSOLICI.cCodUsuIng,    
		lHistoria   =#CURSOLICI.lHistoria,    
		cCreNuevo   =#CURSOLICI.cCreNuevo,    
		cCreNorRef  =#CURSOLICI.cCreNorRef,    
		cCodMotSol  =#CURSOLICI.cCodMotSol,    
		cCodTipCre  =#CURSOLICI.cCodTipCre,    
		ccodproduc  =#CURSOLICI.ccodproduc,    
		cCodSubPro  =#CURSOLICI.cCodSubPro,    
		cCodRecurs	=#CURSOLICI.cCodRecurs,    
		cCodTipRec	=#CURSOLICI.cCodTipRec,    
		ntasintcom	=#CURSOLICI.ntasintcom,    
		cCodSitSol	=#CURSOLICI.cCodSitSol,    
		nNumDiaGra	=#CURSOLICI.nNumDiaGra,    
		dFecDesRef	=#CURSOLICI.dFecDesRef,    
		dFecVenRef	=#CURSOLICI.dFecVenRef,    
		lCuotaCons	=#CURSOLICI.lCuotaCons,    
		cLibAmoCre	=#CURSOLICI.cLibAmoCre,   
		cTipPeriodo	=#CURSOLICI.cTipPeriodo,    
		cCodTipCuo	= CASE WHEN #CURSOLICI.cCodTipCuo = '1' THEN  '4' ELSE '4' END,    
		cCodModCre	=#CURSOLICI.cCodModCre,    
		nDiaFecFij	=#CURSOLICI.nDiaFecFij,    
		nNumDesemb	=#CURSOLICI.nNumDesemb,    
		dIniLinSol	=#CURSOLICI.dIniLinSol,    
		dFinLinSol	=#CURSOLICI.dFinLinSol,    
		dIniLinApr	=#CURSOLICI.dIniLinApr,    
		dFinLinApr	=#CURSOLICI.dFinLinApr,    
		cCodLinCre	=#CURSOLICI.cCodLinCre,    
		lTieneLin	=#CURSOLICI.lTieneLin,    
		cCodConven	=#CURSOLICI.cCodConven,    
		lConConven	=#CURSOLICI.lConConven,    
		nNroLinFin	=#CURSOLICI.nNroLinFin,    
		ctiptascom	=#CURSOLICI.ctiptascom,    
		cCodIntCon	=#CURSOLICI.cCodIntCon,    
		ctiptasmor	=#CURSOLICI.ctiptasmor,    
		ntasintmor	=#CURSOLICI.ntasintmor,    
		nNroTasCom	=#CURSOLICI.nNroTasCom,    
		nNroTasMor	=#CURSOLICI.nNroTasMor,    
		cIndGenOP	=#CURSOLICI.cIndGenOP,
		ccodparcam	=#CURSOLICI.ccodparcam,
		ccodciiusol	=#CURSOLICI.ccodciiusol,
		criecrecam	=#CURSOLICI.criecrecam,
	 	nValScoSol	= @nValScoSol,
		cTipActSco	= @cTipActSco, 
		nNumScoCli	= @nNumScoCli
	FROM KPYMSOLICITUD INNER JOIN #CURSOLICI     
	ON(KPYMSOLICITUD.CCODSOLCRE=#CURSOLICI.CCODSOLCRE)    
	IF @@ERROR <>0    
		BEGIN    
			ROLLBACK TRANSACTION    
			RETURN    
		END    
    
	IF @pcMotSol  = '3'  
		BEGIN  
			EXEC KPY_RegCreAmplia_sp
			@x_curAmplia = @x_curamp,    
			@x_cCodSolCre = @x_cCodSol  
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END    
		END  

	IF @pcMotSol  = '4'
		BEGIN  
		   -----ACTUALIZA ESTADO DE REPROGRAMADOS 
			UPDATE KPYDCreRefina
				SET cCodEstRef = @x_cEstSol,
					cMotCamPla = '2',
					CIndPrePag = @x_PrePag
			WHERE cCodSolCre = @x_cCodSol
			IF @@ERROR <>0    
				BEGIN    
					ROLLBACK TRANSACTION    
					RETURN    
				END
		END
	ELSE
		BEGIN
		   -----ACTUALIZA ESTADO DE REFINANCIADOS    
			UPDATE KPYDCreRefina
				SET cCodEstRef = @x_cEstSol
			WHERE cCodSolCre = @x_cCodSol
			IF @@ERROR <>0    
				BEGIN    
					ROLLBACK TRANSACTION    
					RETURN    
				END    
		END  
	
	IF @x_cEstSol = 'B'
	BEGIN
		/* DESTINO DEL CREDITO 	*/
		SELECT @x_cCodUsu = cCodUsuIng, @x_dFecSis = dFecModCre FROM #CURSOLICI 
	
		EXEC KPY_ModDesCre_sp @x_DesCre, @x_TipDes, @x_cCodSol, '', @x_cCodUsu, @x_dFecSis,NULL, NULL
		IF @@ERROR <>0    
			BEGIN    
				ROLLBACK TRANSACTION    
				RETURN    
			END
	END	

	IF @x_cEstSol = 'D'
	BEGIN
		/* denegación de solicitudes */
		DECLARE @pnIdeDoc INT
	
		SELECT @x_cCodUsu = cCodUsuIng, @x_dFecSis = dFecModCre FROM #CURSOLICI 
	
		--- ASIGNACION DE GASTOS 
		EXEC sp_xml_preparedocument @pnIdeDoc OUTPUT, @x_MotDen

		SELECT	@x_cCodSol AS ccodsolcre, @x_cCodOficin AS ccodoficin,  
				'DEN' AS ccodopcion, cCodMotAnu, cDesObs,
				@x_cCodUsu as cCodUsu, getdate() as dfechorsis
			INTO #curanurec
			 FROM OPENXML(@pnIdeDoc,'/VFPData/curanurec',1)
				WITH (ccodmotanu char(3), cdesobs varchar(120))
		EXEC sp_xml_removedocument @pnIdeDoc

		INSERT INTO KPYDAnuRecDen
		(
			cCodSolCre, cCodCliente, cCodUsuAna,
			nMonSolici, cCodTipMon, cCodOficin,
			cCodOpcion, cCodTipOpc, cDesObserv,
			cCodUsuario, dFecHorSis
		)
		SELECT 
			REC.ccodsolcre, SOL.cCodClient, SOL.ccodusuana,
			CASE WHEN SOL.nMonAprCre = 0.00 
				THEN SOL.nMonSolCre
				ELSE SOL.nMonAprCre  
			END, SOL.cCodMoneda, REC.ccodoficin, 
			REC.ccodopcion, REC.cCodMotAnu,
			REC.cDesObs, REC.cCodUsu, REC.dfechorsis
		fROM #curanurec REC 
			INNER JOIN KPYMSOLICITUD SOL (nolock)
			ON REC.ccodsolcre = SOL.cCodSolCre
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -1
			END

	END

COMMIT TRANSACTION
--*************************************************************************************************************************
GO
	GRANT EXEC ON [dbo].[KPY_UpdateSolicitud_sp] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisDeptoMB_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisDeptoMB_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	OBJETIVO				: Lista los departamentos para las soluciones MiBaño
*	ESCRITO POR				: HERBERT VARGAS.
*	EMAIL/MOVIL				: hvargas@cajahuancayo.com.pe 
*	FECHA CREACIÓN			: 2015.10.16
*	SISTEMA / MODULO		: VITALIS / KPY
* 
*	MODIFICACIONES			:
*	Fecha	/	Responsable		/	Descripcion del cambio

*	SINTAXIS DE EJEMPLO		:  
		EXEC [KPY_LisDeptoMB_sp]
***********************************************************************************************************************************************************************************************/
CREATE PROCEDURE [DBO].[KPY_LisDeptoMB_sp]
AS
SET NOCOUNT ON
BEGIN
	SELECT 
		cCodDepart,		cNomDepart
	FROM GENTDepartame
	WHERE cCodDepart IN ('15')
END
GO
	GRANT EXEC ON [dbo].[KPY_LisDeptoMB_sp] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisProvinsMB_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisProvinsMB_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	OBJETIVO				: Lista las provincias de un Departamento para las soluciones MiBaño
*	ESCRITO POR				: HERBERT VARGAS.
*	EMAIL/MOVIL				: hvargas@cajahuancayo.com.pe 
*	FECHA CREACIÓN			: 2015.10.16
*	SISTEMA / MODULO		: VITALIS / KPY
* 
*	MODIFICACIONES			:
*	Fecha	/	Responsable		/	Descripcion del cambio

*	SINTAXIS DE EJEMPLO		:  
		EXEC [KPY_LisProvinsMB_sp]
***********************************************************************************************************************************************************************************************/
CREATE PROCEDURE [DBO].[KPY_LisProvinsMB_sp]
	@x_cCodDepart CHAR(2)
AS
SET NOCOUNT ON
BEGIN
	SELECT cCodProvin,		cNomProvin
	FROM GENTProvincia
	WHERE cCodDepart = @x_cCodDepart
END
GO
	GRANT EXEC ON [dbo].[KPY_LisProvinsMB_sp] TO ADM_ADM_rl	
GO


IF EXISTS (SELECT * FROM dbo.sysObjects WHERE id = object_id(N'[dbo].[KPY_LisDistriMB_sp]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[KPY_LisDistriMB_sp]
GO
/***********************************************************************************************************************************************************************************************
*	Copyright © 2015 CMAC Huancayo -. All rights reserved.  
*                                           
*	OBJETIVO				: Lista los distritos de una provincia y Departamento para las soluciones MiBaño
*	ESCRITO POR				: HERBERT VARGAS.
*	EMAIL/MOVIL				: hvargas@cajahuancayo.com.pe 
*	FECHA CREACIÓN			: 2015.10.16
*	SISTEMA / MODULO		: VITALIS / KPY
* 
*	MODIFICACIONES			:
*	Fecha	/	Responsable		/	Descripcion del cambio

*	SINTAXIS DE EJEMPLO		:  
		EXEC [KPY_LisDistriMB_sp]
***********************************************************************************************************************************************************************************************/
CREATE PROCEDURE [DBO].[KPY_LisDistriMB_sp]
	@x_cCodDepart CHAR(2),
	@x_cCodProvin CHAR(2)
AS
SET NOCOUNT ON
BEGIN
	SELECT cCodDistri,		cNomDistri
	FROM GENTDistrito
	WHERE cCodDepart = @x_cCodDepart
	AND cCodProvin = @x_cCodProvin
END

GO
	GRANT EXEC ON [dbo].[KPY_LisDistriMB_sp] TO ADM_ADM_rl	
GO










