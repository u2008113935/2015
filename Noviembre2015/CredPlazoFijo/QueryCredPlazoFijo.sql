
	/*
		Número de créditos con garantía de plazo fijo desembolsados en el mes por agencias.

	*/


	SET LANGUAGE spanish;
			--Tipo cambio a junio 2015
			DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
			set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01' 
					) 

			--Select * into #tab01 from (
				Select 
					--	/*
						ROW_NUMBER() 
						OVER(PARTITION BY C.cCodOficin	
							ORDER BY left(cast(C.dFecDesCre as date),10))  AS Secuencia, 
					--	*/
					--Anio= year(C.DFECDESCRE), Mes = MONTH (C.DFECDESCRE)
					--,NombreMes =DATENAME(month, C.DFECDESCRE)
					Agencia = O.cDesOficin	
					,C.cCodCtaCre --, cCodLinCre01 = B.cCodLinCre , cCodLinCre02 = G.cCodLinCre 
					,G.cCodCliente
					--,C.cCodTipCre
					 ,S.cDesTipCre AS 'TipoCredito'
					 ,S.cDesSubTip AS 'SubTipoCredito'
					--,C.cCodProduc
					 ,S.cDesProCre AS 'ProductoCrediticio' 
					--,C.cCodSubPro	
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
					,NumeroCuotas=C.nNumCuoApr										 
					,EstadoCredito =
					 Case C.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					,B.cCodTipGar
					,TipoGarantia =    
						(Select cdestipgar from GENDGARANTIA TIPGAR
							where lconestado = '1' and ccodgarant = B.cCodTipGar)

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
					INNER JOIN [GENTOficinas] O 
						ON O.cCodOficin = C.cCodOficin and O.lConEstado = '1'
										 
				Where B.cCodTipGar = 'RPDPF' AND B.cCodEstGar = 'A'
					and left(cast(C.dFecDesCre as date),10) >= '2014-10-01'
					AND (C.cCodTipCre = '03' and S.cDesSubcRE = 'PLAZO FIJO')
				
				--	) as tmp

				/*
					Select * from KPYDGARLINCRE GARLIN (NOLOCK) 
					Select * from GENDGARANTIA TIPGAR
					where lconestado = '1'
				*/