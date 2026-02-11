

			/*********************************************************************
			*	Copyright © 2009 CMAC Huancayo -. All rights reserved.  			                                           
			*	Objetivo:				RETORNA LAS FECHAS DE LOS EEFF DEL CLIENTE  
			*	Escrito por: 			OPEREZ
			*	Email/Movil/Phone:		operez@cajahuancayo.com.pe			
			*	Fecha creación: 2009.05.25
			*	Sistema / Modulo:	VITALIS / CLIENTES
			*	Modificaciones:    
			*		Fecha  		Responsable		Descripcion del cambio			
			*	Sintaxis de ejemplo:  
			*		EXEC CLI_RetFecEEFFCli_sp
						@x_cCodCliente = '107012830090'			
			*****************************************************************************/  
			/*
			CREATE PROCEDURE [dbo].[CLI_RetFecEEFFCli_sp]
				@x_cCodCliente CHAR (12)
			AS

			SET NOCOUNT ON

			SELECT	nCodEEFFCli,
					dFecEvaEEFF = 'Fec. EEFF:' + CONVERT(VARCHAR(10),dFecEEFF,120),
					dFecCiePer	,
					dFecModEEFF = dFecEEFF
			FROM CMACHYOCLI.dbo.CLIMCtaEEFFCli
			WHERE	CCODCLIENTE = @x_cCodCliente		
			ORDER BY dFecEEFF desc
			*/

			/*
			Solicito la base de datos de los créditos no minoristas de aquellos que 
			faltan sus Estados financieros al cierre de junio 2015. 
			
			*/

	/*
			SELECT	nCodEEFFCli,
					dFecEvaEEFF = 'Fec. EEFF:' + CONVERT(VARCHAR(10),dFecEEFF,120),
					dFecCiePer	,
					dFecModEEFF = dFecEEFF
			FROM CMACHYOCLI.dbo.CLIMCtaEEFFCli
			WHERE	CCODCLIENTE = '107022295032' --@x_cCodCliente					
			ORDER BY dFecEEFF desc


			Select * 
			FROM CMACHYOCLI.dbo.CLIMCtaEEFFCli
			where CCODCLIENTE = '107050087124'
			ORDER BY dFecEEFF desc

				Select * 
				FROM CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli
				where CCODCLIENTE = '107050087124'
					and dFecEEFF in (Select max(dFecEEFF) 
										FROM CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli
										where CCODCLIENTE = '107050087124')
				ORDER BY dFecEEFF desc

			Select --LEN(cCodCliente),
				*
			--FROM HYO00402.CMACHYOCLI.dbo.CLIMCtaEEFFCli
			FROM CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli
			--where CCODCLIENTE = '107050087124'
			ORDER BY dFecEEFF desc			
			

			Select * from #CLIMCtaEEFFCli
			Delete from #CLIMCtaEEFFCli
			-- Drop table #CLIMCtaEEFFCli
	*/

			Create table #CLIMCtaEEFFCli (	 
			nCodEEFFCli	int,
			cCodCliente	char(12),
			dFecCiePer	datetime,
			dFecEEFF	datetime,
			nCodIntCont	int,
			cConAudita	char(1),
			cOpeMonExt	char(1),
			nTipcamFij	numeric(9),
			cCodRegEEFF	char(6),
			dFecRegEEFF	datetime,
			cCodModEEFF	char(6),
			dFecModEEFF	datetime,
			dFecAudEEFF	datetime )
			
			----------------------------fECHA EEFF-----------------------
			Declare @codclie char(12) --, @monpaggas money, @fechapag date							
				
				Declare cEEFF01 CURSOR FOR
					select distinct CCODCLIENTE 
					from CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli (NOLOCK)

				OPEN cEEFF01
				FETCH cEEFF01 into @codclie
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #CLIMCtaEEFFCli 					
					Select 
						nCodEEFFCli,cCodCliente,dFecCiePer=left(cast(dFecCiePer as date),10)
						,dFecEEFF = left(cast(dFecEEFF as date),10),nCodIntCont,cConAudita
						,cOpeMonExt,nTipcamFij,cCodRegEEFF
						,dFecRegEEFF= left(cast(dFecRegEEFF as date),10)
						,cCodModEEFF,dFecModEEFF = left(cast(dFecModEEFF as date),10)
						,dFecAudEEFF = left(cast(dFecAudEEFF as date),10)
					FROM CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli
					where CCODCLIENTE = @codclie
						and dFecEEFF in (Select max(dFecEEFF) 
											FROM CMACHYOCLI_MANIANA.dbo.CLIMCtaEEFFCli
											where CCODCLIENTE = @codclie)												
			
				FETCH cEEFF01 INTO @codclie
				END
				CLOSE cEEFF01
				DEALLOCATE cEEFF01
				-------------------------------------------------------------------
				
				/*
				Select 
						nCodEEFFCli,cCodCliente,dFecCiePer=left(cast(dFecCiePer as date),10)
						,dFecEEFF = left(cast(dFecEEFF as date),10),nCodIntCont,cConAudita
						,cOpeMonExt,nTipcamFij,cCodRegEEFF
						,dFecRegEEFF= left(cast(dFecRegEEFF as date),10)
						,cCodModEEFF,dFecModEEFF = left(cast(dFecModEEFF as date),10)
						,dFecAudEEFF = left(cast(dFecAudEEFF as date),10)
				From #CLIMCtaEEFFCli
				Where dFecCiePer <= '2015-01-01' 
				Order By dFecEEFF Desc
				*/

			Select * into #tab01 from (
				Select 
						nCodEEFFCli,cCodCliente,dFecCiePer=left(cast(dFecCiePer as date),10)
						,dFecEEFF = left(cast(dFecEEFF as date),10),nCodIntCont,cConAudita
						,cOpeMonExt,nTipcamFij,cCodRegEEFF
						,dFecRegEEFF= left(cast(dFecRegEEFF as date),10)
						,cCodModEEFF,dFecModEEFF = left(cast(dFecModEEFF as date),10)
						,dFecAudEEFF = left(cast(dFecAudEEFF as date),10)
				From #CLIMCtaEEFFCli
				Where dFecEEFF <= '2015-06-30' 
				--Order By dFecEEFF Desc
				) as tmp
 
			
			/*
			Select * from #tab01
			Where cCodCliente = '107010643198'
			Order By dFecEEFF Desc
			
			Select cCodCliente, count(cCodCliente)
			from #tab01
			Group By cCodCliente
			Having count(cCodCliente) > 1
			*/
			
			Select 
				CodigoCliente = A.cCodCliente, NombreCliente = isnull(C.cNomCliente,'SIN REGISTRO')
				,FechaCierrePeriodo = A.dFecCiePer, FechaEEFF = A.dFecEEFF				
				--,A.dFecRegEEFF				
				--,CodAsesorRegEEFF = A.cCodRegEEFF,NombreAsesor = isnull(B.cNomPerson,'SIN REGISTRO')				
				,CodAsesor = K.cCodUsuAna,NombreAsesor = isnull(B.cNomPerson,'SIN REGISTRO')				
				,CodOficin = B.cCodOficin, Oficina = O.cDesOficin	
				--,CESE = case when B.dFecCesIns is null then 'NO' else 'SI' end
				--,FecchaCese = isnull(left(CAST(B.dFecCesIns as date),10),'')
				
				,CodigoCredito = K.cCodCtaCre
				,STC.cDesTipCre AS 'TipoCredito'
				,STC.cDesSubTip AS 'SubTipoCredito'			 
				,STC.cDesProCre AS 'ProductoCrediticio' 			 
				,STC.cDesSubcRE AS 'SubProductoCrediticio'
				,EstadoCredito =
					 Case K.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
				--,K.cEstCreCon 				
			From #tab01 A				
				left join [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C  
					on C.cCodCliente = A.cCodCliente				
				left join [GENMCRECLI] G
					on G.cCodCliente = A.cCodCliente								
				left join [KPYMCRECONVEN] K
					on K.cCodCtaCre = G.cCodCtaCre
				left join [sipmpersonal] B
					ON B.cCodPerson = K.cCodUsuAna		
				inner join [GENTOficinas] O 
					ON O.cCodOficin = K.cCodOficin				
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON K.cCodTipCre = STC.cCodTipCre AND K.cCodProduc = STC.cCodProduc 
						AND K.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'	
				INNER JOIN [KPYTConCredit] D
					ON D.cCondicCon = G.cCondicCon		
			Where K.cCodTipCre in ('05','06','07','08','09','10','11','12') 				 
				and K.cEstCreCon in ('F','H')	
				 --and A.cCodCliente = '107010643198'
			Order By A.dFecEEFF Desc

			/*
			
			Drop table #tab01 
			Drop table #CLIMCtaEEFFCli

			*/

			/*
			SELECT * FROM [KPYTSUBTIPCRE] STC WHERE STC.lEstado = '1' ORDER BY cCodTipCre
			Select top 5 * from [sipmpersonal]
			select top 5 * FROM [KPYMCRECONVEN] C (NOLOCK)
			select top 5 * FROM [GENMCRECLI] G 
				inner join [GENMCRECLI] B
					on A.cCodCliente = B.cCodCliente
				inner join [KPYMCRECONVEN] C
					on C.cCodCtaCre = B.cCodCtaCre
			*/