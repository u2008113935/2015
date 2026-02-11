Select --top 5
	 CLIM.cNroDocIde as 'NroDocumento'
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	,CRE.cCodCtaCre	,CRE.nMonCapDes 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	,CRE.nTasIntCom as 'TEM' 
	,CRE.cCodTipCre, STC.cDesTipCre, STC.cDesSubTip, STC.cDesProCre
	,CRE.cCodSubPro, STC.cDesSubCre
	,EC.cDescriEst , O.cDesOficin AS 'NOMBRE_AGENCIA'
from [kpymcreconven] CRE (NOLOCK)
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon	
		INNER JOIN [GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin	
where CRE.cCodTipCre = '03'
		and CRE.nTasIntCom < '1.20'
		and CRE.cEstCreCon in ('G','F','H','I')
		and cDesSubCre != 'ADELANTO DE SUELDO'