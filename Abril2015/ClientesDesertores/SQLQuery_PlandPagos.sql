select cCodCtaCre, cNumCuoPla, dFecVenPag,dFecPagCuo, nDiaAtrCuo, nDiaVenCuo
FROM KPYDPLANPAGCRE
WHERE cCodCtaCre='107002101006515555'
 
	(select round(avg(cast(nDiaVenCuo as float)),0)
	FROM KPYDPLANPAGCRE
	WHERE cCodCtaCre= '107001031000376606')
	--'107002101006515555') --cumple

select sum(nDiaVenCuo), count(nDiaVenCuo)--,0) as 'prom01'
FROM KPYDPLANPAGCRE
WHERE cCodCtaCre='107001031000376606'
		--'107002101006515555' --cumple
		--

SELECT
	cre.cCodCtaCre
	,CRE.nDiaAtrCre as 'Nro_Dias_Atraso_Cuota'
	,CRE.nDiaAtrAcu as 'Nro_Dias_Atraso_Acumulado'
	,CRE.nDiaAtrMax as 'Nro_Dias_Atraso_Maximo'
FROM  [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK) 
where cre.cCodCtaCre='107002101006515555'
