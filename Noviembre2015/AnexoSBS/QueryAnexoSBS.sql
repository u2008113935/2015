
	-- Select * from AnexoSBS


	Select C.CodigoCliente
		,CC.cNomCliente
	    ,A.cCodCtaCre, 
		STC.cDesTipCre AS 'TipoCredito'
		,STC.cDesSubTip AS 'SubTipoCredito'			 
		,STC.cDesProCre AS 'ProductoCrediticio' 			 
		,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
		,A.nMonCapDes as 'MontoDesembolso' 
		,(A.nMonCapDes - A.nMonCapPag) AS 'SaldoCapital'
		,case A.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
		,EstadoCredito =
				 Case A.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMCREconven A
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENMCreCli B
			ON A.cCodCtaCre = B.cCodCtaCre
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
			ON A.cCodTipCre = STC.cCodTipCre AND A.cCodProduc = STC.cCodProduc 
				AND A.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'		
		inner join AnexoSBS C
			on C.CodigoCliente COLLATE SQL_Latin1_General_CP1_CI_AS	= B.cCodCliente
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CC 
			ON CC.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS = C.CodigoCliente
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.KPYTEstCreCon EC 
			ON EC.cEstCreCon = A.cEstCreCon
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTConCredit] D
			ON D.cCondicCon = B.cCondicCon			
	WHERE A.cEstCreCon = 'F'
		AND 	
	ORDER BY C.CodigoCliente