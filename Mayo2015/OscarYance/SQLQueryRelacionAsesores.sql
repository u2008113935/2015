select top 5 * from [sipmpersonal] SP 
select top 5 * from CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM --cCodEmpleador
select top 5 * FROM CMACHYOCLI_MANIANA.dbo.[CLIAMPERNAT]

	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente

select top 5 * from [SIPTCARGOPER] 
		select cCodGruPer from [SIPTCARGOPER] group by cCodGruPer

Select	ROW_NUMBER() 
		OVER(PARTITION BY A.cCodOficin 
		ORDER BY A.dFecIngIns) AS Secuencia,
		A.cCodOficin, O.cDesOficin, A.cCodPerson
		,(C.cNombre + SPACE(1) + C.cApePat + SPACE(1) + C.cApeMat) as cNomPerson
		--,replace(A.cNomPerson,'/',' ') as cNomPerson		
		,A.cNumDocIde,A.cCodProfes, A.cDesProfes,A.cCodGruPer, B.cDesCarPer, A.dFecIngIns, A.dFecCesIns, A.cCodEstPer
from [sipmpersonal] A
		INNER JOIN SIPTCARGOPER B
			ON A.cCodGruPer = B.cCodGruPer 
		INNER JOIN GENTOficinas O
			ON O.cCodOficin = A.cCodOficin
		INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMPERNAT] C
			ON C.cNroDocIde = A.cNumDocIde
where A.cCodEstPer = 'A' and A.cCodGruPer in ('013','ADM','057','028','JNR')                                                               
--(989 row(s) affected)

select top 5 * from [siptcapcarorg]

/*
INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente	
inner JOIN [sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
*/