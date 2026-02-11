--USE SOFCMACHYO_201503
--use SOFCMACHYO_DIARIO_MANIANA
SELECT * FROM [GENTOficinas] O 

--SELECT * FROM SOFCMACHYO_201503.dbo.[GENTOficinas] O 
--WHERE O.cTipOficin = '6'

select * from [Gentofizonas] goz --ON goz.cCodOficin = O.cCodOficin
WHERE nCodZona = '2'
select * from [GentZonas] zon --ON goz.nCodZona = zon.nCodZona
--select * from [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentZona] zo --	ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
--ZONA CENTRO
SELECT   ZON.nCodZona, O.cCodOficin, O.cDesOficin, O.cDirOficin, O.cNomCorOfi
		,zon.cDesZona, zon.cAbrZona 
FROM [GENTOficinas] O 
	INNER JOIN [Gentofizonas] goz 
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [GentZonas] zon
		ON goz.nCodZona = zon.nCodZona
where --cDesOficin like '%ag%jun%n%'
		ZON.nCodZona = '4'  --AND goz.nCodZona = '2'

/*
nCodZona	cDesZona	cAbrZona	lConEstado
1	ZONA LIMA SUR	LIMA SUR	1		--
2	ZONA CENTRO	CENTRO	1				--ok
3	ZONA CENTRO ORIENTE	CENTRO ORIENTE	1	--
4	ZONA LIMA NORTE	LIMA NORTE	1			--
5	ZONA SELVA CENTRAL	SELVA CENTRAL	1	--ok
*/
--AG. REAL, AG. MERCADO, AG. HUANCAVELICA, AG. CHUPACA, AG. CHILCA, AG. CONCEPCION, AG. REAL-CAJAMARCA, AG. PAMPAS, AG. CIUDAD UNIVERSITARIA
--, AG. LIRCAY, AG. SAN FRANCISCO, AG. ACOBAMBA, AG. PARQUE LOS HÉROES, AG. HUANTA, AG. HUANCAS, AG. BRUNO TERREROS - CHUPACA, AG. REAL-HUANUCO
