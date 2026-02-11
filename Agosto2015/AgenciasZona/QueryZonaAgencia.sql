/*
select * 
from CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM
WHERE CcODsbs = '0009556940'
*/

select * from [GentZonas] zon --OK
select * from [Gentofizonas] goz --OK
select * from [GentZona] zo --OBS
select * from [GENTOficinas] O --ok

---------SEPARAR LAS AGEBCIAS POR ZONA 

	Select 
			CodigoZona = ZON.nCodZona, DescripcionZona = ZON.cDesZona
			,CodigoAgencia = O.cCodOficin, DescripcionOficina =O.cDesOficin
			,NombreCortoOficina = O.cNomCorOfi, NombreAbreviadoOficina =O.cAbrNomOfi
			,DireccionOficina = O.cDirOficin
			--,GOZ.*
	From [GENTOficinas] O 
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona
	where O.lConEstado = '1' AND GOZ.lEstZonOfi = '1'
			--and O.cTipOficin != '6'
	order by ZON.nCodZona, O.cCodOficin

	/*
	select O.cCodZona from [GENTOficinas] O 
	GROUP BY O.cCodZona
	*/

	select * from [GentZonas] zon where zon.nCodZona = '2'



	select O.cCodOficin, O.cDesOficin, O.cDirOficin, 
			GOZ.* , ZON.nCodZona, ZON.cDesZona
	from [GENTOficinas] O 
	INNER JOIN [GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [GentZonas] zon
		ON goz.nCodZona = zon.nCodZona
	where O.lConEstado = '1' AND GOZ.lEstZonOfi = '1'
			--and zon.nCodZona = '1'
	order by zon.nCodZona,O.cCodOficin
