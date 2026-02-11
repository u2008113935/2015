
	/*
	Para solicitar por favor, el total de créditos desembolsados en los meses
	Enero 2015 - Julio 2015, segun el archivo adjunto, se requiere dicha data 
	para presenar información a la Gerencia.

		FECHA DESEMBOLSO, CODIGO DE CRÉDITO, MONTO DESEMBOLSADO,MONEDA
		,MONTO DESEMBOLSADO CONVERTIDO,	TEM, TIPO DE CRÉDITO

	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01'				
				)
	--Select @nTipCambio

	Select
		ROW_NUMBER() 
			OVER(PARTITION BY year(C.DFECDESCRE)
					ORDER BY MONTH (C.DFECDESCRE) ) AS Secuencia 
		,Anio= year(C.DFECDESCRE), Mes = MONTH (C.DFECDESCRE)
		,NombreMes =DATENAME(month, C.DFECDESCRE)				
		,CodigoCredito = C.cCodCtaCre
		,FechaDesembolso = left(cast(C.dFecDesCre as date),10) 	 
		,MontoDesembolso = C.nMonCapDes
		,Moneda =
			Case C.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end
		,MontoDesembolsoEnSoles =
			Case C.cCodTipMon
			when '1' then C.nMonCapDes
			when '2' then @nTipCambio * C.nMonCapDes 
			end
		,STC.cDesTipCre AS 'TipoCredito'
		,STC.cDesSubTip AS 'SubTipoCredito'		
		,STC.cDesProCre AS 'ProductoCrediticio' 		
		,STC.cDesSubcRE AS 'SubProductoCrediticio' 
		,TEM=C.nTasintCom	
	From [KPYMCRECONVEN] C (NOLOCK)	
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON C.cCodTipCre = STC.cCodTipCre AND C.cCodProduc = STC.cCodProduc 
				AND C.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
	Where C.cEstCreCon in ('F','H','I','G')
		and left(cast(C.dFecDesCre as date),10) >= '2015-01-01'
		and left(cast(C.dFecDesCre as date),10) <= '2015-07-31'
	Order By left(cast(C.dFecDesCre as date),10)
