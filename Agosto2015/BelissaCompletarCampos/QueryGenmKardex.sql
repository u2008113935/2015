
		/*
		Select Top 1 nMonTotKar,nSalCapita
			,cCodUsuSis, cCodUsuSOp, cVenOperac, cSerTermin,cCodUsuOpe,cCodInsDes
			,*
		From GENMKARDEX
		*/

	SELECT 
		/*
		--@pcCodTipKar, @pcCodKardex, @x_dFecSis, @x_HoraTermin, @pcCodEstTrx, NULL,
		GETDATE(), --@x_cCodUsuSis, @x_cCodUsuSOP, @x_cVenOperac, @x_cSerTermin, 	@plConLocRem,
		--@x_cCodCta, @pcCodTipOpe, @pcCodSubOpe, @x_cCodTipMon, @pcCodTipPag, @x_cCodUsu,
		--@pcNumUltDoc,@x_nMonSalDes + @pnSalIntDev,	dbo.KPY_DEVCLAPERSON_FX(@x_cCodCta),@pcCtaActiva,@x_cCodIns,@lcCodOfiKar,
		--@x_cTipInsOri,	'QQQ',	@x_cCodIns, @lcCodOfiKar, @x_cTipInsOri, @pcCodUsuApo,
		cCondicCon, cCodTipRec, cCodRecurs, cCodPlazo, cCondicCre, cConCreAnt,
		cEstCreCon, cCodProduc, cCodSubPro --@x_nMOnSalAnt
		,nMonIntPro--, @x_nMOnSalDes, 
		nMOnIntPro, nTasIntCom, 'P', 'PRO', cCodTipCre, ndiaAtrCre
		*/
		*
	FROM KPYMCReConven INNER JOIN GENMCRECLI 
		ON KPYMCReConven.cCodCtaCre = GENMCRECLI.cCodCtacre
			and KPYMCReConven.cCodCtaCre = '107002101009493470' -- @x_cCodCta

	Select * 
	from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENMKARDEX B
	Where B.cCodCuenta = '107002101009462957'

	Select * 
	from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.kpymcreconven A
	Where A.cCodctacre = '107002101009462957'



				/**********************************************************************************************************
			*	Copyright  2011 CMAC Huancayo -. All rights reserved.  
			*                                           
			*	Objetivo : Cambio de linea de financiamiento
			*  
			*	Escrito por: 			GREGORIO LOPEZ PINTO
			*	Email/Movil/Phone:		glopez@cajahuancayo.com.pe
			*  
			*	Fecha creacion: 
			*  
			*	Sistema / Modulo:	VITALIS / CREDITOS
			*
			*	Modificaciones:    
			*		Fecha  		Responsable		Descripcion del cambio
			*		2007-09-29	glopez			Se añade justificación de cambio de Linea de Financiamiento
			*		2008-05-11	glopez			Se eliminó la linea de actualización de Moneda en el KPYMCreConven
			*		2008-12-21  AROBLE			Se actualiza el nivel del cliente cuando se cambia de consumo a mes - com
			*		2010.01.18	AROBLE			Se valida para que no permite realizar si el credito tiene afiliado seguros	
			*		2010.02.23	AROBLE			Se cosidera solo los gastos pendientes del credito 
			*		2010.03.08	AROBLE			Se adecua para que cuando el credito solo tiene seguro desgravamen se actualiza el codigo en la nueva linea				
			*		2010.05.14	AROBLE			Se valida para el cambio de linea de financiamiento en seguros 
			*		2010.07.01	AROBLE			Se adecua de acuerdo a la nueva estructura de gastos
			*		2011.02.22	OPEREZ			Se corrigio la generacion del kardex con el codigo de oficina de la cuenta.
			*		2011.03.11	OPEREZ			Se incluyo la actualizacion del campo cLibAmoCre de libre amortizacion.
			*		2011.05.02	OPEREZ			Se esta controlando si el credito cumple para libre amortizacion.
			*		2011.05.12	OPEREZ			El codigo de agencia se esta tomando de la cuenta para la generacion del codigo de kardex.
			*		2011.11.14	OPEREZ			Se esta considerando el codigo de agencia de la cuenta para las agencias del kardex.
			*		2013.12.11	CMUCHA			Se actualiza código de gastos en tabla de afiliados al seguro
			*		2014.03.20	CMUCHA			Se mejora actualización de gastos, evitando duplicidad
			*
			*	Sintaxis de ejemplo:  

			**********************************************************************************************************/
			CREATE PROCEDURE KPY_CamLinFin_sp
				@x_cCodCta CHAR(18),	
				@x_cCodTipCre CHAR(2), 
				@x_cCodProduc CHAR(2),  
				@x_cCodSubPro CHAR(2),
				@x_cCodTipRec CHAR(2), 
				@x_cCodRecurs CHAR(2),
				@x_cCodModCre CHAR(2),
				@x_cCodTipMon CHAR(1),
				@x_cCodPlazo  CHAR(1),
				@x_nMOnSalAnt NUMERIC(14,2),
				@x_nMOnSalDes NUMERIC(14,2),
				@x_nNroLinFin INT,
				@x_cCodOfi	  CHAR(3),
				@x_cCodIns    CHAR(3),
				@x_dFecSis	  DATETIME,
				@x_HoraTermin CHAR(8),
				@x_cCodUsuSis CHAR(6),
				@x_cCodUsuSOP VARCHAR(20),
				@x_cVenOperac CHAR(3),
				@x_cSerTermin VARCHAR(20),
				@x_cCodUsu	  CHAR(6),
 				@x_cTipInsOri CHAR(2),
				@x_cMotCambio VARCHAR(250)
			AS
				DECLARE @lnNumSegAfi INT, @lcTipCreAnt CHAR(2),@lcCodOfi CHAR(3), @lcCodOfiKar CHAR(3), 
						@cCodSolCre CHAR(10), @nGasCorAnt INT
	
				SELECT	@lcTipCreAnt = cCodTipCre ,
						@lcCodOfiKar = ccodoficin,
						@cCodSolCre = cCodSolCre
				FROM KPYMCreConVen
				WHERE cCodCtaCre = @x_cCodCta
	
		
				SET @lcCodOfi = SUBSTRING(@x_cCodCta,4,3)
	

				SELECT DISTINCT cCodTipSeg 
				INTO #CurAux
				FROM KPYMCRECONVEN A
					INNER JOIN KpyDGasGenCre B
						ON A.cCodSolCre = B.cCodSolCre 
					INNER JOIN KpyTGasGenCre C
						ON  B.nCodGasCor = C.nCodGasCor
					INNER JOIN GENMCreCli D
						ON A.cCodCtaCre = D.cCodCtaCre 
					INNER JOIN KPYDPlanPagCre F
						ON A.cCodCtaCre = F.cCodCtaCre 
							AND cCodUltPla = F.cCodPlaPag 
					INNER JOIN HIPDGasGenCuo E
						ON D.cCodCtaCre = E.cCodCtaCre 
							AND cCodUltPla = E.cCodPlaPag 
							AND F.cNumCuoPla = E.cNumCuoPla 
				WHERE A.cCodCtaCre = @x_cCodCta
					AND cCodTipSeg IN ('001','002','003','004')
					AND F.cCodEstCuo = 'E'


				SELECT @lnNumSegAfi = COUNT(*)
				FROM #CurAux
				WHERE cCodTipSeg IN ('002','003','004')
		
				IF @lcTipCreAnt <> @x_cCodTipCre 
					BEGIN
						IF @lnNumSegAfi > 0
							BEGIN 
								RAISERROR ('EL CRÉDITO TIENE AFILIADO SEGUROS, DEBE DESAFILIARLOS PARA EL CAMBIO DE LÍNEA, COORDINARLO CON SOPORTE CREDITICIO', 15, 1) WITH NOWAIT
								RETURN
							END
					END


				IF EXISTS(SELECT * FROM #CurAux WHERE cCodTipSeg = '001')
					BEGIN
						DECLARE @lcSegDesNue CHAR(5), @lnCodGasCor INT
						SELECT @lcSegDesNue = cCodGasCre,
							   @lnCodGasCor = nCodGasCor 
						FROM KpyTGasGenCre
						WHERE  cCodTipCre = @x_cCodTipCre
							AND cCodProduc = @x_cCodProduc
							AND cCodSubPro = @x_cCodSubPro
							AND cCodTipMon = @x_cCodTipMon
							AND cCodOficin = @lcCodOfi
							AND cCodTipRec = @x_cCodTipRec
							AND cCodRecurs = @x_cCodRecurs
							AND lConEstado = 1
							AND cEstCreCon = 'F'
							AND cCodTipSeg = '001'
				 
			
						IF ISNULL(@lcSegDesNue,'') = ''
							BEGIN 
								RAISERROR ('NO EXISTE SEGURO DESGRAVAMEN PARA LA NUEVA LINEA, COORDINARLO CON SOPORTE CREDITICIO', 15, 1) WITH NOWAIT
								RETURN
							END				
			
						--\\ Actualizar gastos de solicitud //--
						UPDATE B
						SET B.cCodGasCre = @lcSegDesNue,
							B.nCodGasCor = @lnCodGasCor
						FROM KpyDGasGenCre B
							INNER JOIN KpyTGasGenCre C
								ON  B.nCodGasCor = C.nCodGasCor
						WHERE B.cCodSolCre = @cCodSolCre
							AND C.cCodTipSeg = '001'
					
						--\\ Actualizar en clientes afiliados //--
						SELECT B.cCodSolCre, B.cCodCliente, B.cTipRelAfi
						INTO #curGasCor
						FROM KPYDCliAfiSeg B
						WHERE B.cCodSolCre = @cCodSolCre
							AND B.lConEstado = 1

						DELETE A
						FROM KPYDCliAfiSeg A
						WHERE A.cCodSolCre = @cCodSolCre

						INSERT INTO KPYDCliAfiSeg
						SELECT @cCodSolCre,  @lnCodGasCor, cCodCliente, cTipRelAfi, 1,
							   @x_cCodUsu, GETDATE(), @x_cCodUsu, GETDATE()
						FROM #curGasCor
			
					END 

	
				DECLARE @pcNumUltDoc CHAR(6), @pcCodUsuApo CHAR(4),
						@pcCodTipKar CHAR(3), @pnSalIntDev NUMERIC(14,2),
						@pcCodTIpOpe CHAR(4), @pcCodPlaPag CHAR(3),
						@pcCodSUbOpe CHAR(4), @pcCodTipTrx CHAR(1),
						@pcCodTipPag CHAR(1), @pcCodAfecta CHAR(3),
						@pcCodEstTrx CHAR(1), @plConLocRem bit,
						@pcCtaActiva CHAR(1),
						@lnNumCuoApr INT,
						@lnMonIntFec NUMERIC(14,2),
						@lnMonIntPag NUMERIC(14,2)

				SET @pcNumUltDoc = dbo.GEN_AsiSecCta_fx(@x_cCodCta,'KPY')

				---------- SALDO DE INTERES DEVENGADO
				SELECT @pnSalIntDev = nSalIntDev 
				FROM KPYMCReConven 
				WHERE cCodCtaCre = @x_cCodCta
				----------	
				IF @x_cCodModCre = '06'
				BEGIN	
					SELECT	@lnNumCuoApr = nNumCuoApr ,
							@lnMonIntFec = nMonIntFec,
							@lnMonIntPag = nMonIntPag 
					from KPYMCRECONVEN  
					WHERE cCodCtaCre = @x_cCodCta
		
					IF @lnNumCuoApr > 1
					BEGIN
						RAISERROR ('El Crédito debe ser a una sola cuota', 15, 1) WITH NOWAIT
						RETURN
					END
		
					IF @lnMonIntPag > @lnMonIntFec 
					BEGIN
						RAISERROR ('El Interes Pagado Supera el Interes a la Fecha', 15, 1) WITH NOWAIT
						RETURN
					END
		
				END	
	
				DECLARE @x_nNumCam tinyint 
				set @x_nNumCam = 0
				SELECT
						@x_nNumCam = COUNT(*), 
						@x_nMOnSalDes = SUM(nmoncapdes - nmoncappag) 
					FROM KPYMCRECONVEN 
					WHERE CCODCTACRE = @x_cCodCta
						AND 
						(	cCodTipCre <> @x_cCodTipCre OR
			 				cCodProduc <> @x_cCodProduc OR
							cCodSubPro <> @x_cCodSubPro OR
							cCodTipRec <> @x_cCodTipRec OR
							cCodRecurs <> @x_cCodRecurs OR
							cCodModCre <> @x_cCodModCre OR
							cCodPlazo	<>	@x_cCodPlazo )
				SET @x_nNumCam = ISNULL(@x_nNumCam,0)

				IF @x_nNumCam = 0
				BEGIN
					RAISERROR ('NO SE REALIZO CAMBIOS EN LA LINEA', 15, 1) WITH NOWAIT
					RETURN
				END

			BEGIN TRANSACTION
			--------------------------------------------------------------------------------------------


	
				DECLARE @pcCodKardex CHAR(15)
				SET @pcCodKardex=''
	
				/*Si el cambio de linea es de Consumo a Mes - Comercial se actualiza el nivel 
				  del cliente (pequeño y microempresario)*/
				IF @lcTipCreAnt = '03' AND @x_cCodTipCre IN ('01','02')
					BEGIN 
						UPDATE C
						SET cCodNivEmp = 1  --Persona Juridica Micro por defecto
						FROM KPYMCRECONVEN A
							INNER JOIN GENMCRECLI B
								ON A.CCODCTACRE = B.CCODCTACRE
							INNER JOIN CmacHyoCli..Climclientes	C
								ON B.cCodcliente = C.cCodCliente	
						WHERE  A.cCodCtaCre = @x_cCodCta
							AND (cCodNivEmp IS NULL OR cCodNivEmp = 0)
						IF @@ERROR<>0
							BEGIN
								ROLLBACK TRANSACTION
								RETURN
							END
					END
				/*Fin de Si el cambio de linea es de Consumo a Mes - Comercial se actualiza el nivel 
				  del cliente (pequeño y microempresario)*/	 

				DECLARE @pnResult Int	-- Resultado del bloqueo de contadores
				EXEC @pnResult = SP_GETAPPLOCK @Resource = 'KPY_GenCorrelativo_sp', @LockMode = 'Exclusive'
				IF @pnResult < 0
				Begin
					RollBack Transaction
					Return
				End
				EXEC KPY_GenCorrelativo_sp  @pcCodKardex OUTPUT,'CCODKARKPY',12,@lcCodOfi
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
				SET @pcCodKardex = @lcCodOfi + @pcCodKardex

				SET @pcCodTipKar = 'KPY'
				SET @pcCodTipOpe = '1025' --- Cambiar con el correctro 
				SET @pcCodSubOpe = 'NR01'
				SET @pcCodTipPag = 'E'
				SET @pcCtaActiva = 'A'
				SET @pcCodUsuApo = 'QQQQ'
				SET @pcCodPlaPag = dbo.KPY_CodPlaAct_fx(@x_cCodCta)
				SET @pcCodTipTrx = 'P'   --- POR DEFINIR
				SET @pcCodAfecta = 'PRO'	
				SET @plConLocRem = 1
				SET @pcCodEstTrx = 'N'

				INSERT GENMKARDEX
					(cCodTipKar, cCodKardex, dFecKardex, cHorKardex, cCodEstTrx, cCodKarExt,			--- Registro del Kardex
					 dFecHorSis, cCodUsuSis, cCodUsuSOp, cVenOperac, cSerTermin, lConLocRem, 
					 cCodCuenta, cCodTipOpe, cCodSubOpe, cCodTipMon, cCodTipPag, cCodUsuOpe, 
					 cNumDocume, nMonTotKar, cCodClaPer, cCtaActiva, cCodInsOri, cCodOfiOri,
					 cTipInsOri, cInsProCta, cCodInsDes, cCodOfiDes, cTipInsDes, cCodUsuApo,			--- Operacion  en Trámite
					 cCodConCre, cCodTipRec, cCodRecurs, cCodPlazo,	 cCodSitCre1, cCodSitCre2,			--- Crédito
					 cEstCuenta, cCodTipPro, cCodTipSub, nCapAntPro, nIntAntPro,  nSalCapita,	
					 nSalIntere, nTasIntOpe, cCodtipTrx, cCodAfecta, cCodTipCre, nNumDiaMor)
				SELECT 
						@pcCodTipKar, @pcCodKardex, @x_dFecSis, @x_HoraTermin, @pcCodEstTrx, NULL,
						GETDATE(), @x_cCodUsuSis, @x_cCodUsuSOP, @x_cVenOperac, @x_cSerTermin, 	@plConLocRem,
						@x_cCodCta, @pcCodTipOpe, @pcCodSubOpe, @x_cCodTipMon, @pcCodTipPag, @x_cCodUsu,
						@pcNumUltDoc,@x_nMonSalDes + @pnSalIntDev,	dbo.KPY_DEVCLAPERSON_FX(@x_cCodCta),	@pcCtaActiva,	@x_cCodIns,	@lcCodOfiKar,
						@x_cTipInsOri,	'QQQ',	@x_cCodIns, @lcCodOfiKar, @x_cTipInsOri, @pcCodUsuApo,
						cCondicCon, cCodTipRec, cCodRecurs, cCodPlazo, cCondicCre, cConCreAnt,
						cEstCreCon, cCodProduc, cCodSubPro, @x_nMOnSalAnt, nMonIntPro, @x_nMOnSalDes, 
						nMOnIntPro, nTasIntCom, 'P', 'PRO', cCodTipCre, ndiaAtrCre
					FROM KPYMCReConven INNER JOIN GENMCRECLI 
					ON KPYMCReConven.cCodCtaCre = GENMCRECLI.cCodCtacre
						and KPYMCReConven.cCodCtaCre = @x_cCodCta
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
	
				--- Registrando EN el Detalle del Kardex EL SALDO DE CAPITAL
				INSERT KPYDKARCREDIT
				(cCodTipKar, cCodKardex, cCodConOpe, cCodSecKar, 	
				 nMonTrxKar, cCodCtaCre, cCodPlaPag, cNumCuoPla,
				 cCodTipTrx, cCodAfecta)
				VALUES
				(
				@pcCodTipKar, @pcCodKardex, 'KP01', '001',
				@x_nMOnSalDes, @x_cCodCta, dbo.KPY_CodPlaAct_fx(@x_cCodCta), '000',
				@pcCodTipTrx, @pcCodAfecta
				)
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END


				--- REGISTRANDO EN EL DETALLE DEL KARDEX EL SALDO DE INTERES DEVENGADO
				INSERT KPYDKARCREDIT
					(cCodTipKar, cCodKardex, cCodConOpe, cCodSecKar, 	
					 nMonTrxKar, cCodCtaCre, cCodPlaPag, cNumCuoPla,
					 cCodTipTrx, cCodAfecta)
				VALUES
					(
					@pcCodTipKar, @pcCodKardex, 'IN01', '001',
					@pnSalIntDev, @x_cCodCta, dbo.KPY_CodPlaAct_fx(@x_cCodCta), '000',
					@pcCodTipTrx, @pcCodAfecta
					)
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
				--- 
	

				 --- REGISTRANDO VALORES ANTERIORES/NUEVOS EN LINEAS DE FINANCIAMIENTO  
				 INSERT KPYDCamLinFin
					   (cCodCtaCre, cTipCreAnt, cProducAnt, cSubProAnt,
						cTipRecAnt, cRecurAnt, cModCreAnt, cPlazoAnt, nNroLinAnt,
						cTipCreNue, cProducNue, cSubProNue, cTipRecNue, cRecurNue,
						cModCreNue, cPlazoNue, nNroLinNue, cMotCambio, dFecHorSis, cCodUsuCam)
				 SELECT 
					   @x_cCodCta, cCodTipCre, cCodProduc, cCodSubPro,
						cCodTipRec, cCodRecurs, cCodModCre, cCodPlazo, nNroLinFin,
						@x_cCodTipCre, @x_cCodProduc, @x_cCodSubPro, @x_cCodTipRec, @x_cCodRecurs, 
						@x_cCodModCre, @x_cCodPlazo, @x_nNroLinFin, @x_cMotCambio, GETDATE(), @x_cCodUsu
					FROM KPYMCreConven
				WHERE ccodctacre = @x_cCodCta
				 IF @@ERROR<>0
					BEGIN
					ROLLBACK TRANSACTION
					RETURN
				 END
	 

	  
				UPDATE KPYMCreConven 
					SET cCodTipCre = @x_cCodTipCre,
						cCodProduc = @x_cCodProduc,
						cCodSubPro = @x_cCodSubPro,
						cCodTipRec = @x_cCodTipRec,
						cCodRecurs = @x_cCodRecurs,
						cCodModCre = @x_cCodModCre,
						cCodPlazo  = @x_cCodPlazo,
						nNroLinFin = @x_nNroLinFin,
						cUltNumDoc = @pcNumUltDoc,
						cLibAmoCre =	CASE 
											WHEN @x_cCodModCre = '06' THEN 'S' 
											ELSE 'N' 
										END
				WHERE cCodCtaCre = @x_cCodCta
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
		
				UPDATE A
				SET cLibAmoCre =		CASE 
											WHEN @x_cCodModCre = '06' THEN 'S' 
											ELSE 'N' 
										END												
				FROM KPYDPLADESEMB A
					INNER JOIN genmcrecli B
						ON A.ccodctacre  = B.ccodctacre 
						AND cCodGruDes = RIGHT(cCodUltPla,2)
				WHERE a.ccodctacre = @x_cCodCta
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END

	
				SET @pcCodKardex=''

				EXEC KPY_GenCorrelativo_sp  @pcCodKardex OUTPUT,'CCODKARKPY',12,@lcCodOfi
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
				SET @pcCodKardex = @lcCodOfi + @pcCodKardex

				SET @pcCodTipKar = 'KPY'
				SET @pcCodTipOpe = '1026' --- Cambiar con el correctro 
				SET @pcCodSubOpe = 'NR01'
				SET @pcCodTipPag = 'E'
				SET @pcCtaActiva = 'A'
				SET @pcCodUsuApo = 'QQQQ'
				SET @pcCodPlaPag = dbo.KPY_CodPlaAct_fx(@x_cCodCta)
				SET @pcCodTipTrx = 'P'   --- POR DEFINIR
				SET @pcCodAfecta = 'PRO'	
				SET @plConLocRem = 1
				SET @pcCodEstTrx = 'N'

				INSERT GENMKARDEX
				(cCodTipKar, cCodKardex, dFecKardex, cHorKardex, cCodEstTrx, cCodKarExt,			--- Registro del Kardex
				 dFecHorSis, cCodUsuSis, cCodUsuSOp, cVenOperac, cSerTermin, lConLocRem, 
				 cCodCuenta, cCodTipOpe, cCodSubOpe, cCodTipMon, cCodTipPag, cCodUsuOpe, 
				 cNumDocume, nMonTotKar, cCodClaPer, cCtaActiva, cCodInsOri, cCodOfiOri,
				 cTipInsOri, cInsProCta, cCodInsDes, cCodOfiDes, cTipInsDes, cCodUsuApo,													--- Operacion  en Trámite
				 cCodConCre, cCodTipRec, cCodRecurs, cCodPlazo,	 cCodSitCre1,	cCodSitCre2,			--- Crédito
				 cEstCuenta, cCodTipPro, cCodTipSub, nCapAntPro, nIntAntPro,	nSalCapita,	
				 nSalIntere, nTasIntOpe, cCodtipTrx, cCodAfecta, cCodTipCre, nNumDiaMor)
				SELECT 
				@pcCodTipKar, @pcCodKardex, @x_dFecSis, @x_HoraTermin, @pcCodEstTrx, NULL,
				GETDATE(), @x_cCodUsuSis, @x_cCodUsuSOP, @x_cVenOperac, @x_cSerTermin, 	@plConLocRem,
				@x_cCodCta, @pcCodTipOpe, @pcCodSubOpe, @x_cCodTipMon, @pcCodTipPag, @x_cCodUsu,
				@pcNumUltDoc, @x_nMonSalDes + @pnSalIntDev,	dbo.KPY_DEVCLAPERSON_FX(@x_cCodCta),	@pcCtaActiva,	@x_cCodIns,	@lcCodOfiKar,
				@x_cTipInsOri,	'QQQ',	@x_cCodIns, @lcCodOfiKar, @x_cTipInsOri, @pcCodUsuApo,
				cCondicCon, cCodTipRec, cCodRecurs, @x_cCodPlazo, cCondicCre, cConCreAnt,
				cEstCreCon, cCodProduc, cCodSubPro, @x_nMOnSalAnt, nMonIntPro, @x_nMOnSalDes, 
				nMOnIntPro, nTasIntCom, 'P', 'PRO', cCodTipCre, ndiaAtrCre 
				FROM KPYMCReConven INNER JOIN GENMCRECLI 
				ON KPYMCReConven.cCodCtaCre = GENMCRECLI.cCodCtacre
					and KPYMCReConven.cCodCtaCre = @x_cCodCta
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END
	
				--- Registrando el Detalle del Kardex del Credito
				INSERT KPYDKARCREDIT
				(cCodTipKar, cCodKardex, cCodConOpe, cCodSecKar, 	
				 nMonTrxKar, cCodCtaCre, cCodPlaPag, cNumCuoPla,
				 cCodTipTrx, cCodAfecta)
				VALUES
				(
				@pcCodTipKar, @pcCodKardex, 'KP01', '001',
				@x_nMOnSalDes, @x_cCodCta, dbo.KPY_CodPlaAct_fx(@x_cCodCta), '000',
				@pcCodTipTrx, @pcCodAfecta
				)
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END

				--- REGISTRANDO EN EL DETALLE DEL KARDEX EL SALDO DE INTERES DEVENGADO
				INSERT KPYDKARCREDIT
					(cCodTipKar, cCodKardex, cCodConOpe, cCodSecKar, 	
					 nMonTrxKar, cCodCtaCre, cCodPlaPag, cNumCuoPla,
					 cCodTipTrx, cCodAfecta)
				VALUES
					(@pcCodTipKar, @pcCodKardex, 'IN01', '001',
					 @pnSalIntDev, @x_cCodCta, dbo.KPY_CodPlaAct_fx(@x_cCodCta), '000',
					 @pcCodTipTrx, @pcCodAfecta)
				IF @@ERROR<>0
					BEGIN
						ROLLBACK TRANSACTION
						RETURN
					END

				DROP TABLE #CurAux

			COMMIT TRANSACTION

	-------------------------------------------------------------------------------

			/***********************************************************************************************************************************************************************************************
		*	Copyright © 2009 CMAC Huancayo -. All rights reserved.  
		*                                           
		*	Objetivo : CONUSLTA DATOS GENERALES DE CREDITOS  
		*  
		*	Escrito por: 			GREGORIO LOPEZ PINTO
		*	Email/Movil/Phone:		glopez@cmac-huancayo.com.pe
		*  
		*	Fecha creación: 2003.06.01
		*  
		*	Sistema / Modulo:	VITALIS / CREDITOS
		*
		*	Modificaciones:    
		*		Fecha  		Responsable		Descripcion del cambio
		*		2006-06-26	GLOPEZ			se añade la tabla de definicion 
		*		2009.01.26	OPEREZ			Se agregó el campo de tipo de campaña.
		*		2009.03.31	OPEREZ			Se corrigió el cruce de las tablas maestras 
		*									de creditos y de solicitud.
		*		2010.02.02	OPEREZ			Se agrego los campos de dias de aprobacion del credito
		*		2010-06-14	ASALAZ			Se contemplo el estado del registro de tabla tipo de créditos
		*
		*	Sintaxis de ejemplo:  
	
			EXEC KPY_DatCreCon_sp @x_cCodCta ='107002101002956027'	
		*
		***********************************************************************************************************************************************************************************************/  
		CREATE PROCEDURE [dbo].[KPY_DatCreCon_sp]
			@x_cCodCta CHAR(18)
		AS
			BEGIN
			
				SELECT   
					CRE.CCODTIPCRE, CRE.CCODPRODUC + TIP.cCodProEqu AS CCODPRODUC, CRE.CCODSUBPRO, CRE.CCODTIPREC, CRE.CCODRECURS,   
					CRE.NNROLINFIN, CRE.CCODMODCRE,cCodParCam , CRE.CCODTIPMON, CRE.CCODPLAZO,  
					CRE.CTIPTASCOM, CRE.CTIPTASMOR, CRE.NTASINTCOM, CRE.NTASINTMOR, CRE.CCODSOLCRE,  
					CRE.CLIBAMOCRE,   
					CON.CDESCONVEN,  
					CDESCRECON = DES.CDESCRIDES,   
					LIN.cdesLinFin,   
					GEN.cCodLinCre,    
					(nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) + ISNULL(nMonGasPro,0))    
					- (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0) + ISNULL(CRE.nMOnMorPag,0) +     
					ISNULL(CRE.nMOnGasPag,0)) As nMOnSalCre,   
					dbo.Gen_ForCarFec_fx(dFecIngJud) AS dFecIngJud,    
					dbo.Gen_ForCarFec_fx(dFecCasCre) AS dFecCasCre ,
					cre.ccodoficin ,cre.nnumcuoapr,cre.nnumdiaapr,cre.nnumdiagra
				FROM KPYMCRECONVEN CRE 
					LEFT JOIN KPYMSOLICITUD SOL
						ON CRE.CCODSOLCRE = SOL.CCODSOLCRE
					LEFT JOIN GENMCRECLI GEN     
						ON (CRE.CCODCTACRE = GEN.CCODCTACRE)    
					INNER JOIN KPYMLinFinCre LIN     
						ON (CRE.nNroLinFin = LIN.nNroLinFin)    
					INNER JOIN KPYTSubtipCre TIP
						ON CRE.cCodTipCre = TIP.cCodTipCre
						AND CRE.cCodProduc = TIP.cCodProduc
						AND CRE.cCodSubPro = TIP.cCodSubPro
						AND TIP.lEstado = CASE 
											WHEN CRE.cEstCreCon IN ('G') AND CRE.dFecCulCre <= '20100630'
												THEN 0
												ELSE 1 
										  END 
					LEFT JOIN KJUMCreJudici JUD    
						ON(CRE.CCODCTACRE = JUD.CCODCTACRE)    
					LEFT JOIN KPYTDESCRECON DES  
						ON(CRE.CCODDESCRE = DES.CCODDESCRE)  
					LEFT JOIN KPYMCONVENIOS CON  
						ON(CON.CCODCONVEN = CRE.CCODCONVEN)  
				WHERE CRE.cCodCtaCre = @x_cCodCta     
			
			END  