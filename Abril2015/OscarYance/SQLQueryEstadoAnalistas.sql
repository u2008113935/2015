	
	select  SP.dFecCesIns, SP.cCodPerson, SP.cCodOficin, SP.cNomPerson, O.cCodOficin, O.cDesOficin
			,SP.cDesCese
	from [sipmpersonal] SP 
			inner join [GENTOficinas] O
				on  SP.cCodOficin = O.cCodOficin
	where SP.cnomperson like '%u%JUlio%'
	--SP.cNumDocIde = '47214925'
			--SP.cDesCese like '%NO%SUPERAR%PRUEBA%'
			--and dFecCesIns >= '2015-01-01'
	order by dFecCesIns

