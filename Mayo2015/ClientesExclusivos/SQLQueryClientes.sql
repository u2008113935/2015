	Select -- top 5 
		dFecIniSisF , dFecIniCmac , dFecReg , * 
	From CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM (NOLOCK) 
	WHERE dFecReg <= '2015-03-31'
			AND cCodSbs IN (
					select ccodsbs from #t01															
							)
	ORDER BY CLIM.cCodCliente