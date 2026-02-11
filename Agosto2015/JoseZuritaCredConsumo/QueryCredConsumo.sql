		
		
		/*
			CREATE PROCEDURE Kpy_IngDeuIntSol_SP  
				 @x_cCodSol CHAR(10),  
				 @x_IngDeu CHAR(1),
				 @x_nTipCon CHAR(1), 
				 @x_nNumEvaMes INT
			AS  
			BEGIN  
			  SET NOCOUNT ON
		
				/*CREAMOS TABLAS DE DETALLES*/
	
				DECLARE @TABLA1 TABLE(cCodSolCre CHAR(10) ,nNumEvaMes INT)
				DECLARE @TABLA2 TABLE(cCodSolCre CHAR(10) ,nNumEvaMes INT)
	
				INSERT INTO @TABLA1
				SELECT TOP 1 cCodSolCre,nNumEvaMes 
					FROM KpyDEvaSolici
					WHERE cCodSolCre = @x_cCodSol
								   
				INSERT INTO @TABLA2
				SELECT TOP 1 cCodSolCre,nNumEvaMes 
					FROM KpyDEvaSolici
					WHERE nNumEvaMes = @x_nNumEvaMes
								   							   
	
				IF @x_nTipCon = 'S'
					BEGIN
						 SELECT Modo = 'U',  
						  cCodSolcre, nSecIngDeu, 
						  cDesIngDeu=CASE WHEN ISNULL(A.nCodDetCon,0)=0 THEN A.cDesIngDeu
										  ELSE DET.cNomDetCon 
									 END , 
						  nMonIngDeu,   
						  cCodRelCta = CONVERT(VARCHAR(3),cCodRelCta),   
						  cCodTipMon = CONVERT(VARCHAR(3),cCodTipMon),   
						  cTipIngDeu, cTipIngres, A.nNumEvaMes,
						  nCodDetCon=CASE WHEN ISNULL(A.nCodDetCon,0)=0 THEN ISNULL(A.nCodDetCon,0)
										  ELSE DET.nCodDetCon 
									 END,						 
						ISNULL(A.lIndSusDeu,1) AS lIndSusDeu,
						ISNULL(A.nMonCapCre,0.00)  AS nMonCapCre    	    
						 FROM KpyDIngDeuInt A				 
							 INNER JOIN  @TABLA1 EVA
								ON A.nNumEvaMes = EVA.nNumEvaMes					
							 LEFT  JOIN KPYDDocEvaCon DET
								ON  ISNULL(A.nCodDetCon,0)=DET.nCodDetCon 			
						 WHERE EVA.cCodSolCre = @x_cCodSol  
						  AND cTipIngDeu = @x_IngDeu  
					END
				ELSE
					BEGIN
						 SELECT Modo = 'U',  
						  cCodSolcre, nSecIngDeu, cDesIngDeu, nMonIngDeu,   
						  cCodRelCta = CONVERT(VARCHAR(3),cCodRelCta),   
						  cCodTipMon = CONVERT(VARCHAR(3),cCodTipMon),   
						  cTipIngDeu, cTipIngres, A.nNumEvaMes 
						 FROM KpyDIngDeuInt A				
							  INNER JOIN @TABLA2 EVA
								ON A.nNumEvaMes = EVA.nNumEvaMes	
						 WHERE A.nNumEvaMes = @x_nNumEvaMes
						  AND cTipIngDeu = @x_IngDeu  
					END
		
		
			END 

		Select top 1 * from KpyDIngDeuInt
		Select top 1 * from KpyDEvaSolici		
		Select * from KPYDDocEvaCon
		
		Select top 1 cCodLinCre,* from [GENMCRECLI]
		Select top 1 cCodSolCre,cCodLinCre,* from KpyMSolicitud		

		*/			
		
	--01
		-- Drop table #tab01

		SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		Set @nTipCambio = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) ='2015-08-01' 
			) 

		Select * into #tab01 from (
				Select 
						/*
						ROW_NUMBER() 
						OVER(PARTITION BY year(C.DFECDESCRE)
							ORDER BY MONTH (C.DFECDESCRE) ) AS Secuencia, 
						*/
					Anio= year(C.DFECDESCRE), Mes = MONTH (C.DFECDESCRE)
					,NombreMes =DATENAME(month, C.DFECDESCRE)
					,C.cCodCtaCre, cCodLinCre01 = B.cCodLinCre , cCodLinCre02 = G.cCodLinCre 
					,G.cCodCliente
					,C.cCodTipCre
					 ,S.cDesTipCre AS 'TipoCredito'
					 ,S.cDesSubTip AS 'SubTipoCredito'
					 ,C.cCodProduc
					 ,S.cDesProCre AS 'ProductoCrediticio' 
					 ,C.cCodSubPro	
					 ,S.cDesSubcRE AS 'SubProductoCrediticio' 							
					--Datos del credito			
					,C.nMonCapDes as 'MontoDesembolso' 
					,(C.nMonCapDes - C.nMonCapPag) AS 'SaldoCapital'
					,case C.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,MontoDesembolsadoenSoles = 
						case C.cCodTipMon
						WHEN '1' THEN C.nMonCapDes
						WHEN '2' THEN @nTipCambio * C.nMonCapDes
						END					
					,SaldoCapitalenSoles = 
						case C.cCodTipMon
						WHEN '1' THEN (C.nMonCapDes - C.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (C.nMonCapDes - C.nMonCapPag)
						END									
					,left(cast(C.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,TEM=C.nTasintCom	
					,NumeroCuotas=C.nNumCuoApr,DiasAtraso = C.nDiaAtrCre, C.cEstCreCon										 
					,EstadoCredito =
					 Case C.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					,B.cCodTipGar
					,DE.cNomDetCon
					,C.cCodOficin, O.cDesOficin
				FROM [KPYMCRECONVEN] C (NOLOCK)
					INNER JOIN [GENMCRECLI] G 
						ON G.cCodCtaCre = C.cCodCtaCre	
					INNER JOIN KPYDGarLinCre B
						on B.cCodLinCre = G.cCodLinCre 
					INNER JOIN [KPYTSUBTIPCRE] S
						ON C.cCodTipCre = S.cCodTipCre AND C.cCodProduc = S.cCodProduc 
							AND C.cCodSubPro = S.cCodSubPro and S.lEstado = '1'
					INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = G.cCondicCon			 
					inner join KpyMSolicitud SO
						ON SO.cCodLinCre = G.cCodLinCre
					inner join KpyDEvaSolici E
						ON E.cCodSolCre = SO.cCodSolCre
					inner join KpyDIngDeuInt I
						on I.nNumEvaMes = E.nNumEvaMes
					inner join KPYDDocEvaCon DE
						on DE.nCodDetCon = I.nCodDetCon 
					INNER JOIN [GENTOficinas] O 
						ON O.cCodOficin = C.cCodOficin and O.lConEstado = '1'		
				Where B.cCodTipGar = 'NRNOG' AND B.cCodEstGar = 'A'
					and C.cEstCreCon in ('F','G')
					--and left(cast(C.dFecDesCre as date),10) > '2013-01-01'
					AND (C.cCodTipCre = '03') -- and S.cDesSubcRE = 'PLAZO FIJO')
					and DE.nCodDetCon in ('6','7')
				--Order By G.cCodCliente
				) as tmp
							
			-- Select * from #tab01

			Select * into #tab02 from (Select top 1 * from #tab01) as tmp

			-- Select * from #tab02
			Delete from #tab02

		--INDEXANDO
			CREATE NONCLUSTERED INDEX #tab01_cCodCtaCre_IXN ON #tab01(cCodCtaCre)						

			-- Select len(cCodCtaCre) from #tab01

	--02
	------------------------CURSOR 1ER CREDITO-----------------------------------
				Declare @codcred char(18)
					Declare cSoloCred CURSOR FOR	
						
						Select distinct cCodCtaCre from #tab01

					OPEN cSoloCred
						FETCH cSoloCred into @codcred
						WHILE (@@FETCH_STATUS=0)
						BEGIN	
				
						  Insert Into #tab02
						  Select top 1 * 										
							from #tab01
							where cCodCtaCre = @codcred									
					
						FETCH cSoloCred INTO @codcred
						END
						CLOSE cSoloCred
						DEALLOCATE cSoloCred
		-----------------------------------------------------------------------------
			
			Select 
				A.Anio,A.Mes,A.NombreMes, A.cCodCtaCre, A.cCodCliente	
				,NombreCliente = C.cNomCliente, A.cNomDetCon 
				,A.TipoCredito, A.SubTipoCredito, A.ProductoCrediticio, A.SubProductoCrediticio
				,A.MontoDesembolso, A.SaldoCapital, A.Moneda, A.MontoDesembolsadoenSoles
				,A.SaldoCapitalenSoles, A.FechaDesembolsoCredito, A.TEM, A.NumeroCuotas
				, A.DiasAtraso,A.EstadoCredito, A.cCodTipGar,A.cCodOficin, A.cDesOficin
			from #tab02 A
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
				ON A.cCodCliente = C.cCodCliente 	
			Order By Anio,Mes			
			
			/*
			Drop table #tab01
			Drop table #tab02
			
			*/

			/*	
			Select * from #tab01
			Where cCodCtaCre ='107009101002703484'			

			Select * from KPYDGarLinCre where cCodLinCre = '0090028066'

			Select cCodCtaCre,count(cCodCtaCre)
			from #tab01
			Group By cCodCtaCre
			Having count(cCodCtaCre) = 1

			Select cCodCtaCre,count(cCodCtaCre)
			from #tab02
			Group By cCodCtaCre
			Having count(cCodCtaCre) > 1

			*/