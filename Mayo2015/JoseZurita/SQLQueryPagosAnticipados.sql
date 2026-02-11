
SELECT --TOP 5 
		CLIM.cNroDocIde as 'NroDocumento1'
		,CLI.cCodCliente AS 'CODIGO_CLIENTE'
		,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
		,GK.cCodSitCre2,CRE.cCodCtaCre , GK.cCodCuenta, GK.dFecKardex, GK.nMonTotKar
		,CRE.cCodTipCre, STC.cDesTipCre, STC.cDesSubTip, STC.cDesProCre, STC.cDesSubCre
		,GK.cCodTipOpe
FROM [GENMKardex] GK (nolock)
		inner join [KPYMCRECONVEN] CRE 		
		on  CRE.cCodCtaCre = GK.cCodCuenta
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
		INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
WHERE GK.cCodTipKar = 'KPY'
      AND GK.cCodTipOpe = '1002'
      AND GK.cCodSitCre2 = 'CA'
	  AND  GK.dFecKardex >= '2015-01-01'
	  and GK.dFecKardex <= '2015-03-31'
	  AND CRE.cCodTipCre = '03'
order by GK.dFecKardex

--(13,670 row(s) affected)

select top 2 * from [GenttipOperac]

SELECT top 1 *
FROM GentTipRep 
 
** ASI OBTIENES LOS PREPAGOS 
 
SELECT top 1 *
FROM KPYDCreRefina 
WHERE cMotCamPla = '6'
      AND cCodTipRep = '1'
      AND cCodEstRef = 'R'
ORDER BY 7
