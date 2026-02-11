	--Select * from SIPMPersonal where cNomPerson like '%huaman%ofe%'
	
	Select  
		Edad = datediff(year,dFecNacPer,getdate())
		,cCodPerson,	cCodOficin,	cNomPerson,	cCodSexo,dFecNacPer,cCodDepNac, cCodProNac
		,cCodDisNac,cCodZonNac,	cCodEstCiv,nNumHijPer,cCodProfes,cDesProfes, cCodPaiDom
		,cCodDepDom,cCodProDom,cCodDisDom,cCodZonDom,cDirDomPer,cCodCliPer,dFecIngIns
		,dFecCesIns, cCodRelIns,cCodEstPer,cCodCondPer,cCodAreaCmac,cCodGruPer
		,cCodClasPer,cCodOcupac	
	from SIPMPersonal where --cNomPerson like '%mendoza%he%'
		cCodSexo = 'F' and cCodEstCiv = '1' 
		and left(cast(dFecNacPer as date),10) >= '1985-01-01'
		and dFecCesIns is NULL 
		and nNumHijPer != '1'
		-- and cNomPerson like '%muni%isabel%'
	Order by left(cast(dFecNacPer as date),10) desc